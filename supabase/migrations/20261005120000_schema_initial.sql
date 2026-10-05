-- Livro : schéma initial
--
-- Trois apps lisent et écrivent ici : Livro (clients, sans compte), Livro Pro (livreurs,
-- connexion par SMS) et Livro Admin (administrateurs, connexion par SMS).
-- Les règles métier (visibilité des livreurs, distance, livreurs injoignables) sont
-- appliquées ici, pas dans les apps, pour qu'aucune app ne puisse les contourner.
--
-- Heure de référence : Africa/Libreville (UTC+1).

-- ─── Types ────────────────────────────────────────────────────────────────

create type public.vehicule as enum ('moto', 'velo', 'voiture');
create type public.mode_disponibilite as enum ('disponible', 'auto', 'indisponible');
create type public.statut_compte as enum ('en_attente', 'valide', 'refuse');
create type public.statut_photo as enum ('en_attente', 'validee', 'refusee');
-- app : le livreur s'est inscrit dans Livro Pro ; admin : fiche créée par un admin (livreur sans smartphone)
create type public.origine_fiche as enum ('app', 'admin');
create type public.statut_signalement as enum ('nouveau', 'traite', 'classe');
create type public.cible_notification as enum ('tous', 'clients', 'livreurs', 'admins');

-- ─── Réglages métier ──────────────────────────────────────────────────────

-- Mode Auto : disponible de 8h à 20h (heure de Libreville)
create function public.heure_debut_auto() returns int language sql immutable as 'select 8';
create function public.heure_fin_auto() returns int language sql immutable as 'select 20';
-- Au-delà, une position n'est plus considérée comme « en direct »
create function public.fraicheur_position() returns interval language sql immutable as $$ select interval '15 minutes' $$;
-- Nombre de clients différents ne pouvant pas joindre un livreur dans la journée avant de le passer indisponible
create function public.seuil_non_reponses() returns int language sql immutable as 'select 3';
-- Signalements autorisés par client et par jour
create function public.max_signalements_par_jour() returns int language sql immutable as 'select 5';

create function public.aujourdhui_libreville() returns date language sql stable as $$
  select (now() at time zone 'Africa/Libreville')::date
$$;

-- ─── Géographie ───────────────────────────────────────────────────────────

create table public.villes (
  id uuid primary key default gen_random_uuid(),
  nom text not null unique check (length(trim(nom)) > 0),
  province text not null check (province in (
    'Estuaire', 'Haut-Ogooué', 'Moyen-Ogooué', 'Ngounié', 'Nyanga',
    'Ogooué-Ivindo', 'Ogooué-Lolo', 'Ogooué-Maritime', 'Woleu-Ntem'
  )),
  cree_le timestamptz not null default now()
);

-- Quartier de rattachement : son point central situe approximativement les livreurs
-- qui n'ont pas de localisation en direct.
create table public.quartiers (
  id uuid primary key default gen_random_uuid(),
  ville_id uuid not null references public.villes (id) on delete cascade,
  nom text not null check (length(trim(nom)) > 0),
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  unique (ville_id, nom),
  unique (id, ville_id)
);

-- Distance à vol d'oiseau en kilomètres (haversine)
create function public.distance_km(lat1 double precision, lng1 double precision, lat2 double precision, lng2 double precision)
returns double precision language sql immutable parallel safe as $$
  select 2 * 6371 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2)
    + cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
  ))
$$;

-- ─── Comptes ──────────────────────────────────────────────────────────────

-- Numéro gabonais au format international : +241 suivi de 9 chiffres
create domain public.telephone_gabon as text check (value ~ '^\+241[0-9]{9}$');

-- Seuls ces numéros peuvent se connecter à Livro Admin
create table public.admins (
  id uuid primary key default gen_random_uuid(),
  nom text not null check (length(trim(nom)) > 0),
  telephone public.telephone_gabon not null unique,
  cree_le timestamptz not null default now()
);

create table public.livreurs (
  id uuid primary key default gen_random_uuid(),
  -- null pour une fiche créée par un admin (livreur sans smartphone)
  user_id uuid unique references auth.users (id) on delete set null,
  nom text not null check (length(trim(nom)) > 0),
  telephone public.telephone_gabon not null unique,
  vehicule public.vehicule not null,
  ville_id uuid not null references public.villes (id) on delete restrict,
  quartier_id uuid,
  whatsapp boolean not null default false,
  mode public.mode_disponibilite not null default 'auto',
  statut_compte public.statut_compte not null default 'en_attente',
  suspendu boolean not null default false,
  origine public.origine_fiche not null default 'app',
  -- Photo facultative, montrée aux clients une fois validée par un admin
  photo_path text,
  statut_photo public.statut_photo,
  -- Localisation en direct, envoyée par Livro Pro
  localisation_active boolean not null default false,
  position_lat double precision check (position_lat between -90 and 90),
  position_lng double precision check (position_lng between -180 and 180),
  position_maj_le timestamptz,
  -- Passé indisponible automatiquement car injoignable (remis à null quand il se remet disponible)
  injoignable_le timestamptz,
  cree_le timestamptz not null default now(),
  maj_le timestamptz not null default now(),
  -- Le quartier doit appartenir à la ville du livreur
  foreign key (quartier_id, ville_id) references public.quartiers (id, ville_id) on delete set null (quartier_id),
  check ((photo_path is null) = (statut_photo is null)),
  check ((position_lat is null) = (position_lng is null))
);
create index livreurs_ville_idx on public.livreurs (ville_id);

-- ─── Signalements, non-réponses, notifications ────────────────────────────

create table public.signalements (
  id uuid primary key default gen_random_uuid(),
  telephone_livreur public.telephone_gabon not null,
  -- Rempli si le numéro appartient à un livreur inscrit
  livreur_id uuid references public.livreurs (id) on delete set null,
  message text not null check (length(trim(message)) between 10 and 500),
  -- Identifiant anonyme de l'appareil du client (pas de compte client)
  client_id text not null,
  statut public.statut_signalement not null default 'nouveau',
  cree_le timestamptz not null default now(),
  traite_le timestamptz
);
create index signalements_statut_idx on public.signalements (statut, cree_le desc);

-- Réponse « Non » à la question posée au client après un appel
create table public.non_reponses (
  id uuid primary key default gen_random_uuid(),
  livreur_id uuid not null references public.livreurs (id) on delete cascade,
  client_id text not null,
  jour date not null default public.aujourdhui_libreville(),
  cree_le timestamptz not null default now(),
  -- Un même client ne compte qu'une fois par livreur et par jour
  unique (livreur_id, client_id, jour)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  cible public.cible_notification not null,
  titre text not null check (length(trim(titre)) between 1 and 60),
  message text not null check (length(trim(message)) between 1 and 240),
  envoye_par uuid default auth.uid(),
  envoyee_le timestamptz not null default now()
);

-- ─── Qui est connecté ─────────────────────────────────────────────────────

-- Supabase enregistre le téléphone sans « + » : on le remet pour comparer.
create function public.telephone_connecte() returns text language sql stable as $$
  select nullif('+' || coalesce(auth.jwt() ->> 'phone', ''), '+')
$$;

create function public.est_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where telephone = public.telephone_connecte())
$$;

-- ─── Règles des livreurs ──────────────────────────────────────────────────

-- Visible des clients : compte validé, pas suspendu, et disponible selon son mode.
create function public.livreur_est_visible(l public.livreurs, a timestamptz default now())
returns boolean language sql stable as $$
  select l.statut_compte = 'valide'
     and not l.suspendu
     and case l.mode
           when 'disponible' then true
           when 'indisponible' then false
           else extract(hour from a at time zone 'Africa/Libreville') >= public.heure_debut_auto()
            and extract(hour from a at time zone 'Africa/Libreville') < public.heure_fin_auto()
         end
$$;

-- Les champs que seul un admin peut changer sont protégés ici, quelle que soit l'app.
-- Pas de security definer : current_user doit rester le rôle de l'appelant.
create function public.livreurs_avant_ecriture() returns trigger
language plpgsql set search_path = public as $$
declare
  admin boolean := public.est_admin() or current_user in ('postgres', 'service_role');
begin
  if tg_op = 'INSERT' then
    if not admin then
      -- Inscription depuis Livro Pro : compte à valider, lié au numéro connecté
      new.user_id := auth.uid();
      new.telephone := public.telephone_connecte();
      new.origine := 'app';
      new.statut_compte := 'en_attente';
      new.suspendu := false;
      new.injoignable_le := null;
    elsif new.origine = 'admin' and new.statut_compte = 'en_attente' then
      -- Fiche créée par un admin : validée d'office
      new.statut_compte := 'valide';
    end if;
  else
    if not admin then
      new.user_id := old.user_id;
      new.telephone := old.telephone;
      new.origine := old.origine;
      new.statut_compte := old.statut_compte;
      new.suspendu := old.suspendu;
      new.statut_photo := old.statut_photo;
    end if;
    new.cree_le := old.cree_le;
  end if;

  -- Toute nouvelle photo repasse par la validation ; pas de photo, pas de statut
  if new.photo_path is null then
    new.statut_photo := null;
  elsif tg_op = 'INSERT' or new.photo_path is distinct from old.photo_path then
    new.statut_photo := case when admin and new.statut_photo is not null then new.statut_photo else 'en_attente' end;
  end if;

  -- Localisation coupée (ou pas encore de position) : on efface la dernière position
  if not new.localisation_active or new.position_lat is null then
    new.position_lat := null;
    new.position_lng := null;
    new.position_maj_le := null;
  elsif tg_op = 'INSERT' or new.position_lat is distinct from old.position_lat or new.position_lng is distinct from old.position_lng then
    new.position_maj_le := now();
  elsif new.position_maj_le is distinct from old.position_maj_le then
    -- Rafraîchissement sans déplacement : jamais dans le futur
    new.position_maj_le := least(coalesce(new.position_maj_le, now()), now());
  end if;

  -- Se remettre disponible efface l'alerte « injoignable »
  if new.mode <> 'indisponible' then
    new.injoignable_le := null;
  end if;

  new.maj_le := now();
  return new;
end;
$$;

create trigger livreurs_avant_ecriture
before insert or update on public.livreurs
for each row execute function public.livreurs_avant_ecriture();

-- Le livreur du compte connecté
create function public.livreur_connecte_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from public.livreurs where user_id = auth.uid()
$$;

-- Livro Pro envoie régulièrement la position du livreur (même s'il n'a pas bougé),
-- sinon elle n'est plus considérée comme en direct au bout de fraicheur_position().
create function public.mettre_a_jour_position(p_lat double precision, p_lng double precision)
returns void language sql set search_path = public as $$
  update public.livreurs
  set position_lat = p_lat, position_lng = p_lng, position_maj_le = now()
  where user_id = auth.uid() and localisation_active
$$;

-- ─── Liste publique des livreurs (apps et page web client) ────────────────

-- Livreurs visibles d'une ville, du plus proche au plus lointain.
-- Sans position du client (p_lat/p_lng null) : pas de distance, ordre alphabétique.
-- distance_km est approximative (approximatif = true) quand elle vient du quartier de base,
-- faute de position en direct récente.
create function public.livreurs_disponibles(
  p_ville_id uuid,
  p_lat double precision default null,
  p_lng double precision default null,
  p_vehicule public.vehicule default null
)
returns table (
  id uuid,
  nom text,
  telephone text,
  vehicule public.vehicule,
  ville text,
  quartier text,
  whatsapp boolean,
  photo_path text,
  distance_km double precision,
  approximatif boolean
)
language sql stable security definer set search_path = public as $$
  with base as (
    select
      l.*,
      v.nom as ville_nom,
      q.nom as quartier_nom,
      (l.localisation_active and l.position_maj_le > now() - public.fraicheur_position()) as en_direct,
      q.lat as q_lat,
      q.lng as q_lng
    from public.livreurs l
    join public.villes v on v.id = l.ville_id
    left join public.quartiers q on q.id = l.quartier_id
    where l.ville_id = p_ville_id
      and (p_vehicule is null or l.vehicule = p_vehicule)
      and public.livreur_est_visible(l)
  ),
  calcul as (
    select
      b.*,
      case
        when p_lat is null or p_lng is null then null
        when b.en_direct then public.distance_km(p_lat, p_lng, b.position_lat, b.position_lng)
        when b.q_lat is not null then public.distance_km(p_lat, p_lng, b.q_lat, b.q_lng)
      end as d
    from base b
  )
  select
    c.id,
    c.nom,
    c.telephone::text,
    c.vehicule,
    c.ville_nom,
    c.quartier_nom,
    c.whatsapp,
    case when c.statut_photo = 'validee' then c.photo_path end,
    c.d,
    (c.d is not null and not c.en_direct)
  from calcul c
  order by c.d asc nulls last, c.nom asc
$$;

-- ─── Actions des clients (sans compte) ────────────────────────────────────

-- Identifiant anonyme d'appareil : tiré au hasard et gardé sur le téléphone ou le navigateur
create function public.verifier_client_id(p_client_id text) returns void language plpgsql immutable as $$
begin
  if p_client_id is null or p_client_id !~ '^[A-Za-z0-9_-]{16,64}$' then
    raise exception 'Identifiant client invalide' using errcode = '22023';
  end if;
end;
$$;

-- Le client dit qu'il n'a pas pu joindre le livreur. Au-delà du seuil de clients différents
-- dans la journée, le livreur passe indisponible (il est prévenu dans Livro Pro).
create function public.declarer_non_reponse(p_livreur_id uuid, p_client_id text)
returns void language plpgsql security definer set search_path = public as $$
declare
  nb int;
begin
  perform public.verifier_client_id(p_client_id);

  insert into public.non_reponses (livreur_id, client_id)
  values (p_livreur_id, p_client_id)
  on conflict (livreur_id, client_id, jour) do nothing;

  select count(*) into nb
  from public.non_reponses
  where livreur_id = p_livreur_id and jour = public.aujourdhui_libreville();

  if nb >= public.seuil_non_reponses() then
    update public.livreurs
    set mode = 'indisponible', injoignable_le = now()
    where id = p_livreur_id and mode <> 'indisponible';
  end if;
end;
$$;

-- Signaler un livreur : son numéro, puis un message. Limité par client et par jour.
create function public.signaler_livreur(p_telephone text, p_message text, p_client_id text)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  nouveau uuid;
begin
  perform public.verifier_client_id(p_client_id);

  if (select count(*) from public.signalements
      where client_id = p_client_id
        and (cree_le at time zone 'Africa/Libreville')::date = public.aujourdhui_libreville())
     >= public.max_signalements_par_jour() then
    raise exception 'Trop de signalements aujourd''hui' using errcode = '54000';
  end if;

  insert into public.signalements (telephone_livreur, livreur_id, message, client_id)
  values (
    p_telephone::public.telephone_gabon,
    (select id from public.livreurs where telephone = p_telephone),
    trim(p_message),
    p_client_id
  )
  returning id into nouveau;
  return nouveau;
end;
$$;

-- ─── Vues pour Livro Admin ────────────────────────────────────────────────

-- Livreurs avec leur ville, quartier, et le nombre de clients n'ayant pas pu les joindre sur 7 jours.
-- security_invoker : les droits de la personne connectée s'appliquent (admins seulement).
create view public.livreurs_admin with (security_invoker = true) as
select
  l.*,
  v.nom as ville,
  q.nom as quartier,
  public.livreur_est_visible(l) as visible,
  (select count(distinct (n.client_id, n.jour))
     from public.non_reponses n
    where n.livreur_id = l.id and n.jour > public.aujourdhui_libreville() - 7) as non_reponses_7j
from public.livreurs l
join public.villes v on v.id = l.ville_id
left join public.quartiers q on q.id = l.quartier_id;

-- ─── Admins : garde-fous ──────────────────────────────────────────────────

-- On ne peut pas se retirer soi-même : il reste donc toujours au moins un admin.
create function public.admins_avant_suppression() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.telephone = public.telephone_connecte() then
    raise exception 'Vous ne pouvez pas vous retirer vous-même' using errcode = '42501';
  end if;
  if (select count(*) from public.admins) <= 1 then
    raise exception 'Il doit rester au moins un administrateur' using errcode = '42501';
  end if;
  return old;
end;
$$;

create trigger admins_avant_suppression
before delete on public.admins
for each row execute function public.admins_avant_suppression();

-- Rattache un signalement au livreur dont le numéro a changé ou qui s'inscrit après coup
create function public.signalements_rattacher() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  update public.signalements set livreur_id = new.id
  where telephone_livreur = new.telephone and livreur_id is distinct from new.id;
  return null;
end;
$$;

create trigger livreurs_rattacher_signalements
after insert or update of telephone on public.livreurs
for each row execute function public.signalements_rattacher();

-- ─── Droits d'accès (Row Level Security) ──────────────────────────────────

alter table public.villes enable row level security;
alter table public.quartiers enable row level security;
alter table public.admins enable row level security;
alter table public.livreurs enable row level security;
alter table public.signalements enable row level security;
alter table public.non_reponses enable row level security;
alter table public.notifications enable row level security;

-- Villes et quartiers : lisibles par tous (listes de choix), modifiables par les admins
create policy villes_lecture on public.villes for select using (true);
create policy villes_admin on public.villes for all using (public.est_admin()) with check (public.est_admin());
create policy quartiers_lecture on public.quartiers for select using (true);
create policy quartiers_admin on public.quartiers for all using (public.est_admin()) with check (public.est_admin());

-- Admins : réservé aux admins
create policy admins_admin on public.admins for all using (public.est_admin()) with check (public.est_admin());

-- Livreurs : le livreur voit et modifie sa fiche (champs protégés par le trigger),
-- les admins voient et modifient tout. Les clients passent par livreurs_disponibles().
create policy livreurs_soi_lecture on public.livreurs for select using (user_id = auth.uid());
create policy livreurs_soi_inscription on public.livreurs for insert to authenticated
  with check (user_id = auth.uid() and telephone = public.telephone_connecte());
create policy livreurs_soi_modification on public.livreurs for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy livreurs_admin on public.livreurs for all using (public.est_admin()) with check (public.est_admin());

-- Signalements et non-réponses : écrits via les fonctions ci-dessus, lus par les admins
create policy signalements_admin on public.signalements for all using (public.est_admin()) with check (public.est_admin());
create policy non_reponses_admin on public.non_reponses for select using (public.est_admin());

-- Notifications : envoyées par les admins ; chacun lit celles qui le concernent
create policy notifications_admin on public.notifications for all using (public.est_admin()) with check (public.est_admin());
create policy notifications_lecture on public.notifications for select using (
  cible = 'tous'
  or cible = 'clients'
  or (cible = 'livreurs' and public.livreur_connecte_id() is not null)
);

-- Fonctions appelables sans compte
revoke execute on function public.declarer_non_reponse(uuid, text) from public;
revoke execute on function public.signaler_livreur(text, text, text) from public;
grant execute on function public.livreurs_disponibles(uuid, double precision, double precision, public.vehicule) to anon, authenticated;
grant execute on function public.declarer_non_reponse(uuid, text) to anon, authenticated;
grant execute on function public.signaler_livreur(text, text, text) to anon, authenticated;
revoke execute on function public.mettre_a_jour_position(double precision, double precision) from public, anon;
grant execute on function public.mettre_a_jour_position(double precision, double precision) to authenticated;
