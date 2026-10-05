-- Photos des livreurs (facultatives), dans le stockage Supabase.
--
-- Rangement : photos-livreurs/<id du livreur>/<nom de fichier aléatoire>.jpg
-- Le bucket est public pour que Livro et la page web affichent les photos sans compte ;
-- livreurs_disponibles() ne renvoie le chemin qu'une fois la photo validée par un admin,
-- et le nom de fichier aléatoire empêche de deviner celui d'une photo non validée.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos-livreurs', 'photos-livreurs', true, 2 * 1024 * 1024, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Le livreur gère les fichiers de son propre dossier
create policy photos_livreur_soi on storage.objects for all to authenticated
using (bucket_id = 'photos-livreurs' and (storage.foldername(name))[1] = public.livreur_connecte_id()::text)
with check (bucket_id = 'photos-livreurs' and (storage.foldername(name))[1] = public.livreur_connecte_id()::text);

-- Les admins gèrent toutes les photos (retrait d'une photo refusée, par exemple)
create policy photos_admin on storage.objects for all to authenticated
using (bucket_id = 'photos-livreurs' and public.est_admin())
with check (bucket_id = 'photos-livreurs' and public.est_admin());
