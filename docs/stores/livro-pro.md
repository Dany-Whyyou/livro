# Livro Pro — fiche de publication

App des livreurs. Identifiants : Android `com.dadel.livrolivreur` · iOS `com.dadel.livro-livreur`.

C'est l'app la plus surveillée par les stores, à cause de la localisation en arrière-plan : les sections 4 et 5 sont à soigner.

---

## 1. Textes de la fiche (français)

**Nom de l'app** (30 caractères max sur les deux stores)
```
Livro Pro – Livreurs
```

**Sous-titre** (App Store, 30 max)
```
Les clients proches appellent
```

**Description courte** (Google Play, 80 max)
```
Livreur au Gabon ? Les clients proches vous trouvent et vous appellent direct.
```

**Texte promotionnel** (App Store, 170 max, modifiable sans nouvelle version)
```
Gratuit et sans commission : vous fixez votre prix au téléphone avec le client. Activez votre position pour apparaître en tête chez les clients proches.
```

**Description complète** (4000 max)
```
Livro Pro est l'application des livreurs indépendants au Gabon. Inscrivez-vous en quelques minutes : les clients qui ont besoin d'un livreur vous trouvent sur Livro et vous appellent directement.

GRATUIT ET SANS COMMISSION
Livro ne prend rien sur vos courses. Vous convenez du prix avec le client au téléphone et vous êtes payé directement par lui.

LES CLIENTS PROCHES VOUS VOIENT EN PREMIER
Activez votre localisation : les clients voient d'abord les livreurs les plus proches d'eux. Livro Pro continue de partager votre position quand l'application est en arrière-plan, pour que vous restiez visible pendant vos tournées. Vous pouvez la couper à tout moment.
Pas de localisation ? Choisissez votre quartier de base : les clients vous situent approximativement.

VOUS CHOISISSEZ QUAND VOUS TRAVAILLEZ
• Disponible : les clients peuvent vous appeler.
• Auto : disponible de 8h à 20h, sans y penser.
• Indisponible : votre numéro n'est plus affiché.
Quand vous êtes indisponible, Livro Pro n'utilise pas votre position.

UN PROFIL SIMPLE ET PROFESSIONNEL
• Votre nom, votre véhicule (moto, vélo, voiture) et votre ville
• Une photo de profil (facultative) pour inspirer confiance
• Appels classiques ou appels WhatsApp, selon votre choix

UN SERVICE DE CONFIANCE
Chaque compte est vérifié par l'équipe Livro avant d'être affiché aux clients. Les clients peuvent signaler un problème : l'équipe les examine.

Livro est un service de mise en relation entre clients et livreurs indépendants. Livro n'organise pas les livraisons et n'intervient pas dans le paiement.

Disponible à Libreville, Owendo, Ntoum et bientôt dans d'autres villes du Gabon.
```

**Mots-clés** (App Store, 100 max, séparés par des virgules, sans espace)
```
livreur,livraison,coursier,moto,Gabon,Libreville,Owendo,Ntoum,courses,colis,indépendant,taxi-moto
```

**Catégories**
- Google Play : Professionnel (Business)
- App Store : principale **Business**, secondaire **Navigation**

**Coordonnées** : e-mail d'assistance, site web, adresse de la politique de confidentialité (obligatoire, voir [confidentialite-et-cgu.md](confidentialite-et-cgu.md)).

---

## 2. Classification du contenu

- **Google Play (questionnaire IARC)** : catégorie « Utilitaires, productivité, communication ou autre ». Pas de violence, de sexualité, de langage grossier, de substances, de jeux d'argent. Les utilisateurs n'échangent pas de messages entre eux dans l'app (les appels se font par le téléphone). Partage de position : **oui** (la position du livreur sert à le classer chez les clients). → Classement attendu : Tout public / PEGI 3.
- **App Store** : 4+. Répondre « Non » à tout, sauf rien de particulier à signaler.

---

## 3. Confidentialité des données

### Google Play — Sécurité des données
Données chiffrées en transit : **oui**. Suppression du compte possible : **oui** (à prévoir : bouton ou adresse e-mail de demande de suppression, obligatoire pour Google).

| Donnée | Collectée | Partagée avec des tiers | Facultative | Finalité |
|---|---|---|---|---|
| Position précise | Oui | Non | Oui (interrupteur) | Fonctionnalités de l'app |
| Nom | Oui | Non | Non | Fonctionnalités de l'app, gestion du compte |
| Numéro de téléphone | Oui | Non | Non | Gestion du compte (connexion), fonctionnalités (affiché aux clients) |
| Photos | Oui | Non | Oui | Fonctionnalités de l'app (photo de profil) |
| Identifiants de l'appareil (jeton de notifications) | Oui | Non | Non | Fonctionnalités (notifications) |

À vérifier au moment de remplir : Google ne compte pas comme « partage » l'affichage d'une donnée à d'autres utilisateurs quand c'est le but du service et que la personne l'a choisi (ici, le numéro et le profil affichés aux clients). Le nom et le numéro sont donc déclarés « collectés », pas « partagés ».

### App Store — Confidentialité de l'app (étiquette)
Données liées à l'identité de l'utilisateur, **non utilisées pour le suivi publicitaire** :
- Coordonnées : nom, numéro de téléphone — Fonctionnalités de l'app
- Localisation : position précise — Fonctionnalités de l'app
- Contenu utilisateur : photos — Fonctionnalités de l'app
- Identifiants : identifiant de l'appareil (notifications) — Fonctionnalités de l'app

Suivi (App Tracking Transparency) : **non**.

---

## 4. Google Play — déclaration du service de premier plan « localisation »

Obligatoire car l'app déclare `FOREGROUND_SERVICE_LOCATION`. À remplir dans Play Console → Contenu de l'application → Services de premier plan. Les relecteurs de Google lisent l'anglais.

**Type** : Location

**Description of the feature (EN)**
```
Livro Pro lets independent couriers in Gabon be found by nearby customers, who then call them directly. When the courier turns on "Location" in the app, Livro Pro shares the courier's position so that customers see the closest available couriers first.

The courier keeps the app in the background while working (riding a motorbike, driving, delivering), so location updates must continue when the app is not on screen. This is why a foreground service of type "location" is used. A persistent notification ("Livro Pro partage votre position") is shown for the whole time the service runs.

The service only starts after the courier explicitly turns on the "Location" switch in the app. It stops automatically when the courier turns the switch off, sets himself "Unavailable", is outside his chosen working hours, or logs out. Updates are sent at most when the courier has moved more than 100 meters, or every 10 minutes, to limit battery use.

Location data is used only to sort couriers by distance for customers. It is not sold or used for advertising.
```

**Impact si le service est interrompu (EN)**
```
If the service is stopped, the courier's position stops being updated and, after 15 minutes, customers no longer see the courier ranked by distance. The courier then loses customers who are close to him.
```

**Vidéo de démonstration** (30 à 60 s, mise sur YouTube en « non répertoriée », lien dans le formulaire)
1. Ouvrir Livro Pro, connecté avec un compte validé.
2. Montrer la carte « Localisation désactivée », puis appuyer sur l'interrupteur.
3. Montrer la demande d'autorisation Android et choisir « Lorsque l'app est en cours d'utilisation ».
4. Montrer la carte « Localisation activée · Position envoyée à l'instant ».
5. Revenir à l'écran d'accueil du téléphone : montrer la notification permanente « Livro Pro partage votre position ».
6. Revenir dans l'app, passer en « Indisponible » : la carte passe « En pause » et la notification disparaît.
7. Couper l'interrupteur : la localisation s'arrête.

Pas de déclaration « localisation en arrière-plan » (`ACCESS_BACKGROUND_LOCATION`) : l'app ne la demande pas, le service de premier plan suffit.

---

## 5. App Store — notes pour la vérification (App Review)

À coller dans App Store Connect → Version → Informations sur la vérification de l'app → Notes. En anglais.

```
Livro Pro is the courier app of Livro, a service that connects customers in Gabon with independent couriers. Customers find nearby couriers in the separate "Livro" app and call them by phone. There are no in-app orders or payments.

BACKGROUND LOCATION (UIBackgroundModes: location)
Couriers turn on "Location" in the app so that customers see the closest couriers first. Couriers keep the app in the background while they work (riding, driving, delivering), so the app keeps sending location updates in the background. We only request "While Using the App" permission; the blue location indicator is shown while the app uses location in the background.
Location is only used after the courier turns on the "Location" switch, and stops when he turns it off, sets himself "Unavailable", is outside his working hours, or logs out. Updates are sent at most every 100 m or every 10 minutes.

HOW TO TEST
1. Log in with the demo phone number below and the code provided (no real SMS is sent for this number).
2. On the main screen, turn on "Localisation" and allow location access.
3. The card shows "Localisation activée" and the time of the last update. Put the app in the background: location keeps being shared (blue indicator).

Demo account
Phone number: +241 [NUMÉRO DE DÉMO]
Verification code: [CODE FIXE]
```

**Compte de démo pour Apple et Google** : la connexion se fait par SMS, impossible pour un relecteur. Supabase permet de déclarer des **numéros de test avec un code fixe** (Authentication → Providers → Phone → numéros de test). À créer avant la soumission, avec une fiche livreur déjà validée.

---

## 6. Visuels

- Icône : [livro-pro-icone-512.png](visuels/livro-pro-icone-512.png) (Google Play), [livro-pro-icone-1024.png](visuels/livro-pro-icone-1024.png) (App Store)
- Bannière Google Play 1024 × 500 : [livro-pro-banniere-1024x500.png](visuels/livro-pro-banniere-1024x500.png)
- Captures d'écran à produire (au moins 4) :
  1. Écran principal : fiche avec le numéro affiché aux clients
  2. Disponibilité : les 3 modes (Disponible, Auto, Indisponible)
  3. Localisation activée
  4. Inscription (étape véhicule)
  5. Photo de profil et appels WhatsApp
- Tailles : Google Play 1080 × 1920 au minimum ; App Store iPhone 6,9" (1320 × 2868) et 6,5" (1284 × 2778).
