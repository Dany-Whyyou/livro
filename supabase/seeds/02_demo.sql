-- Données de démo (développement seulement) : premier admin et livreurs fictifs.
-- Ne pas charger en production. Rejouable sans risque.

-- À remplacer par le vrai numéro du premier administrateur
insert into public.admins (nom, telephone) values ('Administrateur principal', '+241077000001')
on conflict (telephone) do nothing;

-- Livreurs de démo (fiches sans compte : user_id null). Les positions en direct
-- ne restent « fraîches » que 15 minutes après le chargement.
insert into public.livreurs (nom, telephone, vehicule, ville_id, quartier_id, whatsapp, mode, statut_compte, origine, localisation_active, position_lat, position_lng)
select d.nom, d.telephone, d.vehicule::public.vehicule, v.id, q.id, d.whatsapp, d.mode::public.mode_disponibilite,
       d.statut::public.statut_compte, d.origine::public.origine_fiche, d.position_lat is not null, d.position_lat, d.position_lng
from (values
  ('Jean-Pierre Moussavou', '+241077000001', 'moto', 'Libreville', null, true, 'disponible', 'valide', 'app', 0.4005, 9.4576),
  ('Rodrigue Nzamba', '+241066223344', 'moto', 'Libreville', null, true, 'auto', 'valide', 'app', 0.4175, 9.4436),
  ('Christian Ondo', '+241077334455', 'voiture', 'Libreville', null, false, 'disponible', 'valide', 'app', 0.4525, 9.4836),
  ('Patrick Mba', '+241062445566', 'velo', 'Libreville', 'Akébé', false, 'disponible', 'valide', 'admin', null, null),
  ('Laurent Ella', '+241074220011', 'moto', 'Libreville', null, true, 'disponible', 'valide', 'app', 0.3805, 9.4596),
  ('Kevin Mintsa', '+241074998877', 'moto', 'Libreville', null, false, 'auto', 'en_attente', 'app', null, null),
  ('Aline Ondo', '+241066123456', 'voiture', 'Owendo', null, true, 'disponible', 'valide', 'app', 0.3150, 9.5000),
  ('Brice Nzoghe', '+241074556677', 'moto', 'Owendo', 'Akournam', false, 'disponible', 'valide', 'admin', null, null),
  ('Sophie Mba', '+241077889900', 'moto', 'Owendo', null, false, 'indisponible', 'valide', 'app', null, null),
  ('Paul Obame', '+241076112233', 'moto', 'Ntoum', null, false, 'disponible', 'valide', 'app', 0.3956, 9.7631),
  ('Estelle Bouanga', '+241066554433', 'voiture', 'Port-Gentil', null, false, 'auto', 'en_attente', 'app', null, null)
) as d (nom, telephone, vehicule, ville, quartier, whatsapp, mode, statut, origine, position_lat, position_lng)
join public.villes v on v.nom = d.ville
left join public.quartiers q on q.ville_id = v.id and q.nom = d.quartier
on conflict (telephone) do nothing;

update public.livreurs set suspendu = true where nom = 'Paul Obame';
