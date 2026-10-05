-- Notifications push (Firebase Cloud Messaging)
--
-- - Chaque app enregistre son téléphone (jeton FCM) dans `appareils`.
-- - Tout envoi passe par la file `file_push` : soit vers un sujet FCM (« tous »,
--   « clients », « livreurs », « admins », auxquels les apps s'abonnent), soit vers
--   les téléphones d'un livreur précis.
-- - Les envois automatiques (compte validé, photo, injoignable, nouveaux signalements…)
--   sont créés par des triggers : aucune app ne peut les oublier.
-- - Chaque ajout dans la file appelle la fonction Edge `envoyer-push`, qui transmet
--   à Firebase. Adresse et secret d'appel sont dans Vault (`livro_projet_url`,
--   `livro_push_secret`) ; s'ils manquent, rien n'est appelé (tests locaux).

-- pg_net est fourni par Supabase ; absent d'une base PostgreSQL ordinaire (tests locaux)
do $$
begin
  create extension if not exists pg_net with schema extensions;
exception when feature_not_supported or undefined_file then
  raise notice 'pg_net indisponible : les envois ne seront pas déclenchés';
end $$;

create type public.app_livro as enum ('client', 'livreur', 'admin');

-- ─── Téléphones abonnés ───────────────────────────────────────────────────

create table public.appareils (
  token text primary key check (length(token) between 20 and 4096),
  app public.app_livro not null,
  plateforme text not null check (plateforme in ('android', 'ios', 'web')),
  livreur_id uuid references public.livreurs (id) on delete cascade,
  admin_id uuid references public.admins (id) on delete cascade,
  maj_le timestamptz not null default now()
);
create index appareils_livreur_idx on public.appareils (livreur_id) where livreur_id is not null;
alter table public.appareils enable row level security;
-- Pas de policy : lecture et écriture uniquement via les fonctions ci-dessous et le serveur.

-- Enregistre (ou met à jour) le téléphone ; le rattache au livreur ou à l'admin connecté.
create function public.enregistrer_appareil(p_token text, p_app public.app_livro, p_plateforme text)
returns void language plpgsql security definer set search_path = public as $$
declare
  livreur uuid := case when p_app = 'livreur' then public.livreur_connecte_id() end;
  admin uuid := case when p_app = 'admin' then (select id from public.admins where telephone = public.telephone_connecte()) end;
begin
  insert into public.appareils (token, app, plateforme, livreur_id, admin_id)
  values (p_token, p_app, p_plateforme, livreur, admin)
  on conflict (token) do update
    set app = excluded.app, plateforme = excluded.plateforme,
        livreur_id = excluded.livreur_id, admin_id = excluded.admin_id, maj_le = now();
end;
$$;

-- À la déconnexion : le téléphone ne reçoit plus les notifications personnelles.
create function public.oublier_appareil(p_token text)
returns void language sql security definer set search_path = public as $$
  delete from public.appareils where token = p_token
$$;

grant execute on function public.enregistrer_appareil(text, public.app_livro, text) to anon, authenticated;
grant execute on function public.oublier_appareil(text) to anon, authenticated;

-- ─── File d'envoi ─────────────────────────────────────────────────────────

create table public.file_push (
  id uuid primary key default gen_random_uuid(),
  -- Soit un sujet (tous les abonnés), soit un livreur précis
  sujet text check (sujet in ('tous', 'clients', 'livreurs', 'admins')),
  livreur_id uuid references public.livreurs (id) on delete cascade,
  titre text not null check (length(titre) between 1 and 120),
  message text not null check (length(message) between 1 and 500),
  -- Infos pour l'app (type d'événement, identifiants…)
  donnees jsonb not null default '{}',
  cree_le timestamptz not null default now(),
  envoye_le timestamptz,
  tentatives int not null default 0,
  erreur text,
  check ((sujet is null) <> (livreur_id is null))
);
create index file_push_a_envoyer_idx on public.file_push (cree_le) where envoye_le is null;
alter table public.file_push enable row level security;
create policy file_push_admin on public.file_push for select using (public.est_admin());

create function public.pousser(p_sujet text, p_livreur uuid, p_titre text, p_message text, p_donnees jsonb default '{}')
returns void language sql security definer set search_path = public as $$
  insert into public.file_push (sujet, livreur_id, titre, message, donnees)
  values (p_sujet, p_livreur, p_titre, p_message, p_donnees)
$$;
revoke execute on function public.pousser(text, uuid, text, text, jsonb) from public, anon, authenticated;

-- Appelle la fonction d'envoi après chaque ajout (une fois par requête, pas par ligne)
create function public.declencher_envoi_push() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  url text;
  secret text;
begin
  select decrypted_secret into url from vault.decrypted_secrets where name = 'livro_projet_url';
  select decrypted_secret into secret from vault.decrypted_secrets where name = 'livro_push_secret';
  if url is null or secret is null then
    return null;
  end if;
  perform net.http_post(
    url := url || '/functions/v1/envoyer-push',
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-push-secret', secret),
    body := '{}'::jsonb
  );
  return null;
end;
$$;

create trigger file_push_envoyer
after insert on public.file_push
for each statement execute function public.declencher_envoi_push();

-- ─── Envois automatiques ──────────────────────────────────────────────────

-- Messages envoyés depuis Livro Admin
create function public.notifications_vers_file() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.pousser(new.cible::text, null, new.titre, new.message, jsonb_build_object('type', 'annonce'));
  return null;
end;
$$;

create trigger notifications_envoyer
after insert on public.notifications
for each row execute function public.notifications_vers_file();

-- Livreurs : décisions de l'équipe et alertes, vers le livreur ; travail à faire, vers les admins
create function public.livreurs_notifications() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    if new.statut_compte = 'en_attente' then
      perform public.pousser('admins', null, 'Nouveau livreur à valider',
        new.nom || ' s''est inscrit sur Livro Pro.', jsonb_build_object('type', 'compte_a_valider', 'livreur_id', new.id));
    end if;
    return null;
  end if;

  if new.statut_compte is distinct from old.statut_compte then
    if new.statut_compte = 'valide' then
      perform public.pousser(null, new.id, 'Votre compte est validé',
        'Les clients peuvent maintenant vous trouver et vous appeler.', jsonb_build_object('type', 'compte_valide'));
    elsif new.statut_compte = 'refuse' then
      perform public.pousser(null, new.id, 'Votre compte n''a pas été validé',
        'Contactez l''équipe Livro pour en savoir plus.', jsonb_build_object('type', 'compte_refuse'));
    end if;
  end if;

  if new.suspendu and not old.suspendu then
    perform public.pousser(null, new.id, 'Votre compte est suspendu',
      'Vous n''êtes plus affiché aux clients. Contactez l''équipe Livro.', jsonb_build_object('type', 'compte_suspendu'));
  elsif old.suspendu and not new.suspendu then
    perform public.pousser(null, new.id, 'Votre compte est réactivé',
      'Vous êtes de nouveau affiché aux clients selon votre disponibilité.', jsonb_build_object('type', 'compte_reactive'));
  end if;

  if new.statut_photo is distinct from old.statut_photo then
    if new.statut_photo = 'validee' then
      perform public.pousser(null, new.id, 'Photo validée', 'Votre photo est maintenant visible des clients.', jsonb_build_object('type', 'photo_validee'));
    elsif new.statut_photo = 'refusee' then
      perform public.pousser(null, new.id, 'Photo refusée', 'Choisissez une autre photo dans Livro Pro.', jsonb_build_object('type', 'photo_refusee'));
    elsif new.statut_photo = 'en_attente' then
      perform public.pousser('admins', null, 'Photo à valider',
        new.nom || ' a envoyé une photo de profil.', jsonb_build_object('type', 'photo_a_valider', 'livreur_id', new.id));
    end if;
  end if;

  if new.injoignable_le is not null and old.injoignable_le is null then
    perform public.pousser(null, new.id, 'Vous êtes passé en indisponible',
      'Plusieurs clients n''ont pas pu vous joindre aujourd''hui. Remettez-vous disponible quand vous pouvez répondre.',
      jsonb_build_object('type', 'injoignable'));
  end if;

  return null;
end;
$$;

create trigger livreurs_notifications
after insert or update on public.livreurs
for each row execute function public.livreurs_notifications();

-- Nouveau signalement, vers les admins
create function public.signalements_notifications() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.pousser('admins', null, 'Nouveau signalement',
    coalesce((select nom from public.livreurs where id = new.livreur_id), 'Numéro non inscrit') || ' a été signalé par un client.',
    jsonb_build_object('type', 'signalement', 'signalement_id', new.id));
  return null;
end;
$$;

create trigger signalements_notifications
after insert on public.signalements
for each row execute function public.signalements_notifications();
