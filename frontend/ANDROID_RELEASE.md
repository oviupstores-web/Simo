# Construire et publier Menoo sur Android

Le projet Android natif se trouve dans `frontend/android` et utilise l'identifiant
définitif `com.oviupstores.menoo`.

## Tester dans Android Studio

1. Installer les dépendances depuis `frontend` avec `corepack yarn install`.
2. Ouvrir le dossier `frontend/android` dans Android Studio.
3. Attendre la fin de la synchronisation Gradle.
4. Démarrer un émulateur dans **Device Manager**.
5. Sélectionner le module `app`, puis cliquer sur **Run**.

On peut aussi lancer la version Android depuis `frontend` :

```powershell
corepack yarn android
```

## Créer le fichier AAB pour Google Play

1. Dans Android Studio, choisir **Build > Generate Signed Bundle / APK**.
2. Choisir **Android App Bundle**.
3. Créer une clé d'upload, ou sélectionner la clé d'upload existante.
4. Conserver le fichier de clé en dehors du dépôt Git.
5. Choisir la variante `release`, puis terminer l'assistant.
6. Envoyer le fichier `.aab` produit dans Google Play Console.

## Sécurité de la signature

- Ne jamais committer un fichier `.jks`, `.keystore`, `.p12`, `.pem` ou `.key`.
- Ne jamais écrire les mots de passe de signature dans un fichier suivi par Git.
- Sauvegarder la clé d'upload et ses mots de passe dans deux emplacements sûrs.
- La configuration `release` du dépôt est volontairement non signée. La signature
  est réalisée localement par Android Studio.

## Mises à jour Google Play

Avant chaque nouvel envoi, augmenter `versionCode` dans
`android/app/build.gradle`. Mettre aussi à jour `versionName` pour la version
visible par les utilisateurs.

Le dossier Android est maintenant suivi comme projet natif. Les réglages Android
doivent donc être vérifiés dans les fichiers natifs après toute nouvelle exécution
de `expo prebuild`.
