# 📦 Gabon Livreur

Plateforme de mise en relation entre livreurs indépendants et clients au Gabon.

## 🎯 Concept

Les livreurs sont 100% autonomes :
- Ils définissent leurs **propres tarifs**
- Ils choisissent leur **zone de livraison** (quartier, ville, province)
- Ils gèrent leur **disponibilité**

Les clients peuvent commander sans créer de compte.

## 🚀 Problème résolu

| Problème | Solution |
|:---|:---|
| Trouver un livreur fiable est un parcours du combattant | Application dédiée avec géolocalisation |
| Aucune plateforme ne respecte la liberté tarifaire des livreurs | Gabon Livreur donne le contrôle total |
| Gozem, FastBox imposent tarifs et commissions | Zéro commission, livreur touche 100% |
| Absence de solution dans certaines zones (Owendo, Ntoum) | Extension progressive couvrant tout le Gabon |

## 👥 Public cible

- **Livreurs** : Indépendants à moto, vélo ou voiture
- **Clients** : Particuliers, commerçants, PME, restaurants, pharmacies

## 💰 Modèle économique

- **Phase 1 (1 an)** : Gratuité totale pour les livreurs
- **Phase 2** : Abonnement mensuel de **1000 FCFA** par livreur
- **Clients** : Gratuit (compte optionnel)

> Ce modèle évite le contournement : le livreur paie pour être visible, donc il ne peut pas s'arranger en direct avec le client.

## 🗺️ Stratégie de lancement (dense, pas large)

| Phase | Zone | Objectif |
|:---|:---|:---|
| Mois 1 | Owendo | 30 livreurs actifs, 200 clients |
| Mois 2-3 | Ntoum (relié à Owendo) | Extension naturelle |
| Mois 4-6 | Libreville (Akébé, Lalala, Glass) | Lancement ville principale |
| Mois 6+ | Port-Gentil, Franceville | Expansion nationale |

## 🛠️ Stack technique

| Couche | Technologie |
|:---|:---|
| Backend API | Laravel (expertise maison) |
| Base de données | Supabase (PostgreSQL + Realtime) |
| Mobile App | Flutter (interface boutons d'abord, carte plus tard) |
| Dashboard Admin | Next.js |
| Notifications push | OneSignal |
| Localisation temps réel | Supabase Realtime |
| Paiement Mobile Money | Prévu Phase 2 (dans 1 an) |

## 🎨 Identité visuelle

| Élément | Valeur |
|:---|:---|
| **Nom** | Gabon Livreur |
| **Couleur primaire** | Vert forêt (`#2E7D32`) |
| **Couleur secondaire** | Orange (`#FF9800`) |

## 📱 Fonctionnalités

### Client (avec/sans compte)
- Géolocalisation automatique ou saisie manuelle
- Saisie destination + poids du colis
- Liste des livreurs disponibles (tarif, distance, véhicule)
- Sélection d'un livreur
- Appel / WhatsApp direct
- Suivi simple (étapes)
- Paiement Mobile Money (optionnel)

### Livreur
- Inscription (téléphone, nom, véhicule)
- Définition du tarif, zone, disponibilité
- Réception des demandes
- Acceptation/refus
- Gestion du statut course

### Administrateur (Dashboard Filament)
- Validation des nouveaux livreurs
- Gestion des litiges
- Statistiques (courses/jour, livreurs actifs)
- Gestion des abonnements

## 🗃️ Structure base de données (principales tables)

- `livreurs` : nom, téléphone, véhicule, tarif, zone, province, ville, disponibilité, abonnement
- `clients` : téléphone, nom, email (compte optionnel)
- `courses` : adresses, poids, prix, statut (`en_attente` → `acceptee` → `en_cours` → `livree` / `annulee`)
- `paiements` : montant, référence Mobile Money, statut
- `avis` : note, commentaire (après livraison)


## 🔐 Authentification

- Identifiant unique : **numéro de téléphone** (ni email, ni nom d'utilisateur)
- Connexion par **OTP SMS** pour tous (clients et livreurs)
- Pas de mot de passe

## 🔔 Notifications

- Livreur alerté en temps réel à chaque nouvelle course disponible
- Client notifié à chaque changement de statut (acceptée, en route, livrée)
- Provider : **OneSignal**

## 📍 Localisation temps réel

- Position du livreur partagée en cours de course via **Supabase Realtime**

## 📸 Photo de livraison

- Le livreur prend une photo comme preuve à la livraison
- Photo **non stockée** côté serveur (modèle à valider)
- CGU : la plateforme n'est pas responsable des litiges de livraison

## ⭐ Notation

- **Clients notent les livreurs** après chaque course
- **Livreurs notent les clients** (pour filtrer les mauvais payeurs / annuleurs)
- Historique des courses visible des deux côtés (client : ses courses, livreur : ses courses + gains)

## ❌ Annulation

- Pas de bouton d'annulation côté client après acceptation du livreur
- Le client doit **appeler directement le livreur** pour annuler
- Un système de notation client permet de pénaliser les annulations abusives

## 🪪 Validation des livreurs

- Pas de vérification de documents (CNI, permis) — simple mise en relation
- Validation manuelle dans le dashboard admin (profil + photo)

---

## 📱 Deux applications distinctes

- **App Client** et **App Livreur**
- Bouton manuel de passage en ligne (indicateur de disponibilité du livreur)