# Base de données Livro (Supabase)

Une seule base pour les trois apps et la page web :

| Qui | Accès | Comment |
|---|---|---|
| Clients (Livro, page web) | sans compte | fonctions `livreurs_disponibles`, `declarer_non_reponse`, `signaler_livreur` |
| Livreurs (Livro Pro) | connexion par SMS | leur fiche dans `livreurs`, `mettre_a_jour_position` |
| Admins (Livro Admin) | connexion par SMS, numéro présent dans `admins` | tout |

Les règles métier sont dans la base, pas dans les apps :

- **Visibilité** (`livreur_est_visible`) : compte validé, pas suspendu, et disponible selon son mode (Auto = 8h–20h, heure de Libreville).
- **Distance** (`livreurs_disponibles`) : depuis la position en direct si elle a moins de 15 minutes, sinon depuis le centre du quartier de base (`approximatif = true`), sinon aucune.
- **Injoignable** (`declarer_non_reponse`) : 3 clients différents dans la journée → le livreur passe indisponible (`injoignable_le` renseigné, effacé quand il se remet disponible).
- **Champs protégés** (trigger `livreurs_avant_ecriture`) : un livreur ne peut ni valider son compte, ni lever une suspension, ni valider sa photo, ni changer de numéro.
- **Signalements** : 5 au maximum par client et par jour.

Les réglages (heures du mode Auto, 15 minutes, seuil de 3, limite de 5) sont des petites fonctions en tête de la migration initiale.

Les clients n'ont pas de compte : chaque appareil envoie un identifiant anonyme tiré au hasard (16 à 64 caractères `A-Z a-z 0-9 _ -`), gardé sur le téléphone ou dans le navigateur.

## Mise en route

1. Créer un projet sur [supabase.com](https://supabase.com) (région la plus proche du Gabon).
2. Relier ce dossier au projet, puis envoyer le schéma :
   ```sh
   supabase login
   supabase link --project-ref <référence du projet>
   supabase db push
   ```
3. Charger les villes et quartiers : exécuter `seeds/01_villes_quartiers.sql` (aussi en production). `seeds/02_demo.sql` (admin et livreurs fictifs) est réservé au développement.
4. Activer la connexion par téléphone (Authentication → Providers → Phone) et y brancher un fournisseur de SMS qui livre au Gabon.

## Tests

```sh
psql "<chaîne de connexion>" -v ON_ERROR_STOP=1 -f supabase/tests/regles_metier.sql
```

Les tests tournent dans une transaction annulée à la fin et affichent « TOUS LES TESTS PASSENT ». Ils supposent les villes et quartiers chargés, et chargent eux-mêmes les données de démo le temps du test. Les règles de stockage des photos (`20261005120100_photos_livreurs.sql`) ne sont pas couvertes par ces tests.
