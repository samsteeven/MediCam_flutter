import 'package:flutter/foundation.dart';

class WebProxyService {
  // Service simple pour gérer les spécificités web si nécessaire
  // comme l'utilisation d'un proxy pour éviter les erreurs CORS

  // static const String _proxyUrl = 'https://cors-anywhere.herokuapp.com/'; // Exemple de proxy public pour dev

  String proxifyUrl(String url) {
    if (kIsWeb && !url.contains('localhost')) {
      // Sur le web, si on n'est pas en local, on peut vouloir passer par un proxy
      // Note: Pour localhost, le proxy n'est souvent pas nécessaire si le serveur configure bien le CORS
      // ou si on lance chrome avec --disable-web-security
      return url;
    }
    return url;
  }

  // Note: L'utilisateur a demandé "sans les cors", ce qui implique souvent
  // soit d'avoir réglé le backend, soit d'ignorer le proxy.
  // Je laisse la méthode pass-through pour l'instant.
}
