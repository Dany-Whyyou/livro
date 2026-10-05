-- Données de référence : villes et quartiers. À charger aussi en production.
-- Rejouable sans risque (les lignes déjà présentes sont ignorées).

insert into public.villes (nom, province) values
  ('Libreville', 'Estuaire'),
  ('Owendo', 'Estuaire'),
  ('Ntoum', 'Estuaire'),
  ('Port-Gentil', 'Ogooué-Maritime'),
  ('Franceville', 'Haut-Ogooué'),
  ('Lambaréné', 'Moyen-Ogooué'),
  ('Oyem', 'Woleu-Ntem'),
  ('Mouila', 'Ngounié')
on conflict (nom) do nothing;

-- Points centraux approximatifs, à vérifier sur le terrain
insert into public.quartiers (ville_id, nom, lat, lng)
select v.id, q.nom, q.lat, q.lng
from (values
  ('Libreville', 'Centre-ville', 0.3920, 9.4540),
  ('Libreville', 'Louis', 0.4080, 9.4430),
  ('Libreville', 'Glass', 0.3800, 9.4460),
  ('Libreville', 'Akébé', 0.3800, 9.4700),
  ('Libreville', 'Lalala', 0.3650, 9.4600),
  ('Libreville', 'Nzeng-Ayong', 0.4150, 9.4900),
  ('Libreville', 'Okala', 0.4880, 9.4880),
  ('Libreville', 'Angondjé', 0.5300, 9.4500),
  ('Owendo', 'Owendo Centre', 0.2850, 9.5000),
  ('Owendo', 'Akournam', 0.2950, 9.5050),
  ('Owendo', 'Alénakiri', 0.3050, 9.5150),
  ('Owendo', 'Barracuda', 0.2750, 9.4950),
  ('Ntoum', 'Ntoum Centre', 0.3906, 9.7611),
  ('Ntoum', 'Bikélé', 0.4100, 9.6200)
) as q (ville, nom, lat, lng)
join public.villes v on v.nom = q.ville
on conflict (ville_id, nom) do nothing;

