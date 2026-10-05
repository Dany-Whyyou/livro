# Livro Admin — distribution

App interne de l'équipe. Identifiants : Android `com.dadel.livroadmin` · iOS `com.dadel.livro-admin`.

**Recommandation : ne pas la publier en public.** Seuls les numéros déclarés comme administrateurs peuvent se connecter ; une fiche publique attirerait des téléchargements inutiles et des questions des relecteurs (Apple refuse souvent les apps « réservées à une équipe » sur l'App Store public).

## Options de distribution

| Plateforme | Option recommandée | Remarques |
|---|---|---|
| Android | Google Play → **Test interne** (jusqu'à 100 testeurs, par e-mail Google) | Pas de vérification complète, mise à disposition en quelques minutes |
| iPhone | **TestFlight** (testeurs internes : membres de ton équipe App Store Connect) | Builds valables 90 jours, à renouveler |
| Alternative | Page web Livro Admin (Flutter web) | Aucun store ; à héberger derrière une adresse non publique |

Si une publication sur les stores devient nécessaire plus tard : Google Play en « app privée » (Google Workspace) ou App Store en **distribution non répertoriée** (« unlisted »), sur demande à Apple.

## Informations minimales (TestFlight / test interne)

**Nom** : `Livro Admin`

**Description pour les testeurs**
```
Application interne de l'équipe Livro : validation des comptes et des photos des livreurs, traitement des signalements, gestion des villes et des administrateurs, envoi de notifications. Connexion par SMS, réservée aux numéros administrateurs.
```

**Notes de test (anglais, si Apple vérifie le build TestFlight externe)**
```
Internal back-office app for the Livro team (Gabon). Only phone numbers registered as administrators can log in (SMS code). Demo admin account: +241 [NUMÉRO DE TEST] / code [CODE FIXE].
```

**Confidentialité** : même étiquette que Livro Pro, sans la localisation (nom et numéro de téléphone des administrateurs, identifiant de l'appareil pour les notifications).

**Icône** : [livro-admin-icone-512.png](visuels/livro-admin-icone-512.png), [livro-admin-icone-1024.png](visuels/livro-admin-icone-1024.png)
