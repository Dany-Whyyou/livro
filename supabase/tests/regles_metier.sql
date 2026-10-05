-- Tests des règles métier, sur une base contenant le schéma et les villes/quartiers.
-- Tout se passe dans une transaction annulée à la fin : la base n'est pas modifiée,
-- y compris les données de démo chargées pour les tests. Utilisable sur la vraie base.
-- Lancer avec : psql "<connexion>" -v ON_ERROR_STOP=1 -f supabase/tests/regles_metier.sql
-- Chaque test lève une erreur s'il échoue ; « TOUS LES TESTS PASSENT » s'affiche à la fin.

begin;

\ir ../seeds/02_demo.sql

-- Outils : se faire passer pour un visiteur (anon) ou un utilisateur connecté
create function pg_temp.en_tant_que(p_role text, p_user uuid default null, p_phone text default null) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    case when p_user is null then '{}' else json_build_object('sub', p_user, 'phone', p_phone, 'role', p_role)::text end, true);
  execute format('set local role %I', p_role);
end;
$$;
create function pg_temp.verifier(condition boolean, message text) returns void language plpgsql as $$
begin
  if condition is not true then raise exception 'ÉCHEC : %', message; end if;
end;
$$;

-- Fixer l'heure n'est pas possible : on teste le mode Auto via livreur_est_visible(l, heure)
do $$
declare
  l public.livreurs;
begin
  select * into l from public.livreurs where nom = 'Rodrigue Nzamba';
  perform pg_temp.verifier(public.livreur_est_visible(l, '2026-10-05 08:00 Africa/Libreville'), 'Auto : visible à 8h');
  perform pg_temp.verifier(public.livreur_est_visible(l, '2026-10-05 19:59 Africa/Libreville'), 'Auto : visible à 19h59');
  perform pg_temp.verifier(not public.livreur_est_visible(l, '2026-10-05 20:00 Africa/Libreville'), 'Auto : invisible à 20h');
  perform pg_temp.verifier(not public.livreur_est_visible(l, '2026-10-05 07:59 Africa/Libreville'), 'Auto : invisible à 7h59');
end $$;

-- Liste publique : visibilité, tri par distance, distance approximative depuis le quartier
select pg_temp.en_tant_que('anon');
do $$
declare
  libreville uuid := (select id from public.villes where nom = 'Libreville');
  noms text[];
  patrick record;
begin
  select array_agg(nom order by ordre) into noms from (
    select nom, row_number() over () as ordre
    from public.livreurs_disponibles(libreville, 0.3925, 9.4536)
  ) t;
  -- Kevin (compte à valider) n'apparaît pas ; Rodrigue (Auto) dépend de l'heure
  perform pg_temp.verifier(not ('Kevin Mintsa' = any (noms)), 'compte non validé masqué');
  perform pg_temp.verifier(noms[1] = 'Jean-Pierre Moussavou', 'le plus proche en premier : ' || array_to_string(noms, ', '));
  perform pg_temp.verifier(noms[array_length(noms, 1)] = 'Christian Ondo', 'le plus lointain en dernier');

  select * into patrick from public.livreurs_disponibles(libreville, 0.3925, 9.4536) where nom = 'Patrick Mba';
  perform pg_temp.verifier(patrick.approximatif, 'Patrick : distance approximative (quartier Akébé)');
  perform pg_temp.verifier(patrick.distance_km between 2 and 2.6, 'Patrick : environ 2,3 km, obtenu ' || patrick.distance_km);
  perform pg_temp.verifier(patrick.quartier = 'Akébé', 'Patrick : quartier renvoyé');

  -- Sans position du client : pas de distance, ordre alphabétique
  perform pg_temp.verifier(
    (select bool_and(distance_km is null) from public.livreurs_disponibles(libreville)),
    'sans position client : aucune distance');
  perform pg_temp.verifier(
    (select array_agg(nom) from public.livreurs_disponibles(libreville))
      = (select array_agg(nom order by nom) from public.livreurs_disponibles(libreville)),
    'sans position client : ordre alphabétique');

  -- Suspendu : masqué
  perform pg_temp.verifier(
    not exists (select 1 from public.livreurs_disponibles((select id from public.villes where nom = 'Ntoum'))),
    'livreur suspendu masqué');
end $$;

-- Un visiteur ne lit pas la table des livreurs directement
do $$
begin
  perform pg_temp.verifier((select count(*) from public.livreurs) = 0, 'anon : table livreurs illisible');
  perform pg_temp.verifier((select count(*) from public.villes) = 8, 'anon : villes lisibles');
end $$;
reset role;

-- Position en direct périmée : on retombe sur le quartier, sinon pas de distance
update public.livreurs set position_maj_le = now() - interval '20 minutes' where nom = 'Laurent Ella';
update public.livreurs set position_maj_le = now() - interval '20 minutes', quartier_id = (select id from public.quartiers where nom = 'Okala')
where nom = 'Christian Ondo';
select pg_temp.en_tant_que('anon');
do $$
declare
  libreville uuid := (select id from public.villes where nom = 'Libreville');
  r record;
begin
  select * into r from public.livreurs_disponibles(libreville, 0.3925, 9.4536) where nom = 'Laurent Ella';
  perform pg_temp.verifier(r.distance_km is null and not r.approximatif, 'position périmée sans quartier : pas de distance');
  select * into r from public.livreurs_disponibles(libreville, 0.3925, 9.4536) where nom = 'Christian Ondo';
  perform pg_temp.verifier(r.approximatif, 'position périmée avec quartier : distance approximative');
end $$;
reset role;

-- Non-réponses : 3 clients différents dans la journée → indisponible ; un même client ne compte qu'une fois
select pg_temp.en_tant_que('anon');
select public.declarer_non_reponse((select id from public.livreurs_disponibles((select id from public.villes where nom = 'Libreville')) where nom = 'Jean-Pierre Moussavou'), 'client_aaaaaaaaaaaaaaaa');
select public.declarer_non_reponse((select id from public.livreurs_disponibles((select id from public.villes where nom = 'Libreville')) where nom = 'Jean-Pierre Moussavou'), 'client_aaaaaaaaaaaaaaaa');
select public.declarer_non_reponse((select id from public.livreurs_disponibles((select id from public.villes where nom = 'Libreville')) where nom = 'Jean-Pierre Moussavou'), 'client_bbbbbbbbbbbbbbbb');
reset role;
do $$ begin
  perform pg_temp.verifier((select mode from public.livreurs where nom = 'Jean-Pierre Moussavou') = 'disponible', '2 clients : toujours disponible');
end $$;
select pg_temp.en_tant_que('anon');
select public.declarer_non_reponse((select id from public.livreurs_disponibles((select id from public.villes where nom = 'Libreville')) where nom = 'Jean-Pierre Moussavou'), 'client_cccccccccccccccc');
reset role;
do $$ begin
  perform pg_temp.verifier((select mode from public.livreurs where nom = 'Jean-Pierre Moussavou') = 'indisponible', '3 clients : passé indisponible');
  perform pg_temp.verifier((select injoignable_le is not null from public.livreurs where nom = 'Jean-Pierre Moussavou'), 'alerte injoignable posée');
end $$;

-- Identifiant client invalide refusé
select pg_temp.en_tant_que('anon');
do $$ begin
  begin
    perform public.declarer_non_reponse((select id from public.villes limit 1), 'x');
    raise exception 'ÉCHEC : identifiant client invalide accepté';
  exception when sqlstate '22023' then null;
  end;
end $$;

-- Signalement : rattaché au livreur, limité à 5 par client et par jour
do $$
declare
  i int;
begin
  perform public.signaler_livreur('+241066223344', 'Le livreur ne répondait plus après la prise du colis.', 'client_dddddddddddddddd');
  for i in 1..4 loop
    perform public.signaler_livreur('+241062001122', 'Numéro qui se fait passer pour un livreur Livro.', 'client_dddddddddddddddd');
  end loop;
  begin
    perform public.signaler_livreur('+241062001122', 'Un sixième signalement le même jour.', 'client_dddddddddddddddd');
    raise exception 'ÉCHEC : 6e signalement accepté';
  exception when sqlstate '54000' then null;
  end;
  begin
    perform public.signaler_livreur('0771234', 'Numéro au mauvais format pour tester.', 'client_eeeeeeeeeeeeeeee');
    raise exception 'ÉCHEC : numéro invalide accepté';
  exception when check_violation then null;
  end;
end $$;
reset role;
do $$ begin
  perform pg_temp.verifier(
    (select livreur_id from public.signalements where telephone_livreur = '+241066223344') = (select id from public.livreurs where nom = 'Rodrigue Nzamba'),
    'signalement rattaché au livreur');
end $$;

-- Inscription d'un livreur depuis Livro Pro : champs protégés imposés
insert into auth.users (id, phone) values ('00000000-0000-0000-0000-00000000aaaa', '241066777888');
select pg_temp.en_tant_que('authenticated', '00000000-0000-0000-0000-00000000aaaa', '241066777888');
insert into public.livreurs (nom, telephone, vehicule, ville_id, statut_compte, suspendu, origine, user_id)
values ('Nouveau Livreur', '+241066777888', 'moto', (select id from public.villes where nom = 'Owendo'), 'valide', false, 'admin', '00000000-0000-0000-0000-00000000aaaa');
do $$
declare
  l public.livreurs;
begin
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.statut_compte = 'en_attente', 'inscription : compte en attente même si l''app envoie « valide »');
  perform pg_temp.verifier(l.origine = 'app', 'inscription : origine app imposée');
  perform pg_temp.verifier((select count(*) from public.livreurs) = 1, 'un livreur ne voit que sa fiche');

  -- Tentative de se valider soi-même ou de lever une suspension : ignorée
  update public.livreurs set statut_compte = 'valide', suspendu = false, nom = 'Nouveau Nom' where user_id = '00000000-0000-0000-0000-00000000aaaa';
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.statut_compte = 'en_attente' and l.nom = 'Nouveau Nom', 'modification : statut protégé, nom modifiable');

  -- Photo : repasse « en attente » à chaque changement, même si l'app prétend « validée »
  update public.livreurs set photo_path = 'a/photo.jpg', statut_photo = 'validee' where user_id = '00000000-0000-0000-0000-00000000aaaa';
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.statut_photo = 'en_attente', 'photo : en attente de validation');

  -- Localisation : position datée par le serveur, effacée quand on coupe
  update public.livreurs set localisation_active = true, position_lat = 0.29, position_lng = 9.50, position_maj_le = now() + interval '1 day'
  where user_id = '00000000-0000-0000-0000-00000000aaaa';
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.position_maj_le <= now(), 'position : date fixée par le serveur');
  perform public.mettre_a_jour_position(0.29, 9.50);
  update public.livreurs set localisation_active = false where user_id = '00000000-0000-0000-0000-00000000aaaa';
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.position_lat is null and l.position_maj_le is null, 'localisation coupée : position effacée');

  -- Pas d'accès aux tables réservées aux admins
  perform pg_temp.verifier((select count(*) from public.signalements) = 0, 'livreur : signalements illisibles');
  perform pg_temp.verifier((select count(*) from public.admins) = 0, 'livreur : admins illisibles');
end $$;

-- Un livreur ne peut pas s'inscrire avec le numéro de quelqu'un d'autre
do $$ begin
  begin
    insert into public.livreurs (nom, telephone, vehicule, ville_id, user_id)
    values ('Usurpateur', '+241077334455', 'moto', (select id from public.villes where nom = 'Owendo'), '00000000-0000-0000-0000-00000000aaaa');
    raise exception 'ÉCHEC : inscription avec un autre numéro acceptée';
  exception when insufficient_privilege or unique_violation then null;
  end;
end $$;
reset role;

-- Admin : accès complet, validation d'une photo, fiche « sans smartphone » validée d'office
insert into auth.users (id, phone) values ('00000000-0000-0000-0000-00000000bbbb', '241077000001');
select pg_temp.en_tant_que('authenticated', '00000000-0000-0000-0000-00000000bbbb', '241077000001');
do $$
declare
  l public.livreurs;
begin
  perform pg_temp.verifier(public.est_admin(), 'admin reconnu par son numéro');
  perform pg_temp.verifier((select count(*) from public.livreurs) >= 12, 'admin : voit tous les livreurs');
  perform pg_temp.verifier((select non_reponses_7j from public.livreurs_admin where nom = 'Jean-Pierre Moussavou') = 3, 'vue admin : 3 non-réponses');

  update public.livreurs set statut_photo = 'validee', statut_compte = 'valide' where user_id = '00000000-0000-0000-0000-00000000aaaa';
  select * into l from public.livreurs where user_id = '00000000-0000-0000-0000-00000000aaaa';
  perform pg_temp.verifier(l.statut_photo = 'validee' and l.statut_compte = 'valide', 'admin : valide photo et compte');

  insert into public.livreurs (nom, telephone, vehicule, ville_id, origine)
  values ('Marc Essono', '+241062778899', 'moto', (select id from public.villes where nom = 'Ntoum'), 'admin');
  perform pg_temp.verifier((select statut_compte from public.livreurs where nom = 'Marc Essono') = 'valide', 'fiche admin validée d''office');

  -- Quartier d'une autre ville refusé
  begin
    update public.livreurs set quartier_id = (select id from public.quartiers where nom = 'Akébé') where nom = 'Marc Essono';
    raise exception 'ÉCHEC : quartier d''une autre ville accepté';
  exception when foreign_key_violation then null;
  end;

  -- Ville avec des livreurs : suppression refusée
  begin
    delete from public.villes where nom = 'Owendo';
    raise exception 'ÉCHEC : ville avec livreurs supprimée';
  exception when foreign_key_violation then null;
  end;

  -- Se retirer soi-même : refusé
  begin
    delete from public.admins where telephone = '+241077000001';
    raise exception 'ÉCHEC : un admin s''est retiré lui-même';
  exception when insufficient_privilege then null;
  end;

  insert into public.notifications (cible, titre, message) values ('livreurs', 'Test', 'Message de test');
end $$;
reset role;

-- Le livreur repassé disponible efface l'alerte « injoignable »
update public.livreurs set mode = 'disponible' where nom = 'Jean-Pierre Moussavou';
do $$ begin
  perform pg_temp.verifier((select injoignable_le is null from public.livreurs where nom = 'Jean-Pierre Moussavou'), 'remis disponible : alerte effacée');
end $$;

-- Notifications : un client (anon) ne voit pas celles des livreurs
select pg_temp.en_tant_que('anon');
do $$ begin
  perform pg_temp.verifier((select count(*) from public.notifications where cible = 'livreurs') = 0, 'anon : notifications livreurs masquées');
end $$;
reset role;

do $$ begin raise notice 'TOUS LES TESTS PASSENT'; end $$;
rollback;
