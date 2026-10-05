-- Tests des notifications : les bons messages arrivent dans la file d'envoi.
-- Transaction annulée à la fin : rien n'est envoyé (pg_net n'envoie qu'après validation).
-- Lancer avec : psql "<connexion>" -v ON_ERROR_STOP=1 -f supabase/tests/notifications.sql

begin;

\ir ../seeds/02_demo.sql

create function pg_temp.verifier(condition boolean, message text) returns void language plpgsql as $$
begin
  if condition is not true then raise exception 'ÉCHEC : %', message; end if;
end;
$$;

-- Les livreurs de démo « à valider » ont prévenu les admins
do $$ begin
  perform pg_temp.verifier(
    (select count(*) from public.file_push where sujet = 'admins' and donnees ->> 'type' = 'compte_a_valider') >= 2,
    'nouveaux comptes : admins prévenus');
end $$;

delete from public.file_push;

-- Décisions de l'équipe : le livreur est prévenu
update public.livreurs set statut_compte = 'valide' where nom = 'Kevin Mintsa';
update public.livreurs set statut_compte = 'refuse' where nom = 'Estelle Bouanga';
update public.livreurs set suspendu = true where nom = 'Rodrigue Nzamba';
update public.livreurs set photo_path = 'x/p.jpg' where nom = 'Aline Ondo';
update public.livreurs set statut_photo = 'validee' where nom = 'Aline Ondo';
update public.livreurs set nom = 'Christian Ondo' where nom = 'Christian Ondo'; -- sans changement utile : rien

do $$
begin
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Kevin Mintsa' and f.donnees ->> 'type' = 'compte_valide') = 1, 'compte validé : livreur prévenu');
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Estelle Bouanga' and f.donnees ->> 'type' = 'compte_refuse') = 1, 'compte refusé : livreur prévenu');
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Rodrigue Nzamba' and f.donnees ->> 'type' = 'compte_suspendu') = 1, 'suspension : livreur prévenu');
  perform pg_temp.verifier((select count(*) from public.file_push where sujet = 'admins' and donnees ->> 'type' = 'photo_a_valider') = 1,
    'nouvelle photo : admins prévenus');
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Aline Ondo' and f.donnees ->> 'type' = 'photo_validee') = 1, 'photo validée : livreur prévenu');
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Christian Ondo') = 0, 'modification sans effet : pas de notification');
end $$;

-- Injoignable : 3 clients répondent « non »
select public.declarer_non_reponse((select id from public.livreurs where nom = 'Laurent Ella'), 'client_aaaaaaaaaaaaaaaa');
select public.declarer_non_reponse((select id from public.livreurs where nom = 'Laurent Ella'), 'client_bbbbbbbbbbbbbbbb');
select public.declarer_non_reponse((select id from public.livreurs where nom = 'Laurent Ella'), 'client_cccccccccccccccc');
do $$ begin
  perform pg_temp.verifier((select count(*) from public.file_push f join public.livreurs l on l.id = f.livreur_id
    where l.nom = 'Laurent Ella' and f.donnees ->> 'type' = 'injoignable') = 1, 'injoignable : livreur prévenu');
end $$;

-- Signalement : admins prévenus, avec le nom du livreur
select public.signaler_livreur('+241066223344', 'Le livreur ne répondait plus après la prise du colis.', 'client_dddddddddddddddd');
do $$ begin
  perform pg_temp.verifier((select count(*) from public.file_push where sujet = 'admins' and donnees ->> 'type' = 'signalement'
    and message like 'Rodrigue Nzamba%') = 1, 'signalement : admins prévenus');
end $$;

-- Message envoyé depuis Livro Admin : vers le sujet choisi
insert into public.notifications (cible, titre, message) values ('livreurs', 'Réunion', 'Samedi 9h à Owendo');
do $$ begin
  perform pg_temp.verifier((select count(*) from public.file_push where sujet = 'livreurs' and titre = 'Réunion') = 1, 'annonce : sujet livreurs');
end $$;

-- Enregistrement d'un téléphone, sans compte puis rattaché au livreur connecté
insert into auth.users (id, phone) values ('00000000-0000-0000-0000-00000000cccc', '241077000001');
update public.livreurs set user_id = '00000000-0000-0000-0000-00000000cccc' where telephone = '+241077000001';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000cccc","phone":"241077000001"}', true);
set local role authenticated;
select public.enregistrer_appareil('jeton-de-test-0123456789abcdef', 'livreur', 'android');
reset role;
do $$ begin
  perform pg_temp.verifier((select livreur_id from public.appareils where token = 'jeton-de-test-0123456789abcdef')
    = (select id from public.livreurs where telephone = '+241077000001'), 'appareil rattaché au livreur connecté');
end $$;
-- Le même numéro est aussi admin dans la démo : un téléphone de Livro Admin est rattaché à l'admin
set local role authenticated;
select public.enregistrer_appareil('jeton-admin-0123456789abcdef', 'admin', 'ios');
reset role;
do $$ begin
  perform pg_temp.verifier((select admin_id is not null and livreur_id is null from public.appareils where token = 'jeton-admin-0123456789abcdef'),
    'appareil rattaché à l''admin connecté');
end $$;
-- Un visiteur ne peut ni lire les appareils ni la file
select set_config('request.jwt.claims', '{}', true);
set local role anon;
do $$ begin
  perform pg_temp.verifier((select count(*) from public.appareils) = 0, 'anon : appareils illisibles');
  perform pg_temp.verifier((select count(*) from public.file_push) = 0, 'anon : file illisible');
  begin
    perform public.pousser('tous', null, 'Pirate', 'Message non autorisé');
    raise exception 'ÉCHEC : un visiteur a pu envoyer une notification';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;

do $$ begin raise notice 'TOUS LES TESTS DE NOTIFICATIONS PASSENT'; end $$;
rollback;
