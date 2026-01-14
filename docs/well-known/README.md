## /.well-known files (App Links / Universal Links)

Fichiers exemples à placer sur votre backend à l'emplacement `https://<votre-domaine>/.well-known/` :

- `assetlinks.json` (Android)
- `apple-app-site-association` (iOS) — servir avec `Content-Type: application/json`

Étapes rapides :

1. Remplir les placeholders :
   - `com.example.easypharma` : package name de l'app (vérifier `android/app/src/main/kotlin/.../MainActivity.kt`).
   - `REPLACE_WITH_DEBUG_SHA256` / `REPLACE_WITH_RELEASE_SHA256` : empreintes SHA‑256 des clés (Android). Exemple pour debug :
     ```bash
     keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     Récupérez la valeur `SHA256` et collez-la dans `assetlinks.json`.

   - `REPLACE_WITH_TEAM_ID` : votre Team ID Apple (ex : ABCDE12345). Utilisez votre `Bundle ID` (ex: `com.example.easypharma`).

2. Héberger les fichiers (HTTPS, pas de redirection) :
   - `https://<votre-domaine>/.well-known/assetlinks.json`
   - `https://<votre-domaine>/.well-known/apple-app-site-association`

3. Vérifier :
   - Android : `https://developers.google.com/digital-asset-links/tools/generator` ou `adb shell am start` pour tester l'intent.
   - iOS : vérifier dans Xcode (Associated Domains) et tester le lien sur un appareil.

4. Conseils :
   - Inclure empreintes debug + release pour tests faciles.
   - Assurer `Content-Type: application/json` et code HTTP 200 sans redirection.

Si tu veux, je peux générer les versions finales en remplaçant les placeholders si tu fournis :
- la/les empreinte(s) SHA256 (debug/release),
- ton Apple Team ID.
