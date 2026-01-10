import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔄 Diagnostic backend EasyPharma...\n');

  await testDatabaseDetails();
  await testHealthWithDetails();
  await testUniqueRegistration();
  await testLoginWithExistingUser();
}

Future<void> testDatabaseDetails() async {
  print('🗄️ Détails base de données...');

  final url = 'http://localhost:8080/actuator/health';

  try {
    final response = await http
        .get(Uri.parse(url), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    print('📊 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📋 Analyse complète:');
      print('- Status général: ${data['status']}');

      if (data['components'] != null) {
        final components = data['components'] as Map;
        print('\n🔧 Composants:');

        components.forEach((key, value) {
          if (value is Map) {
            final status = value['status'] ?? 'UNKNOWN';
            final details = value['details'] ?? {};

            print('\n  ┌─ $key: $status');

            if (status != 'UP') {
              print('  │  ❌ PROBLÈME DÉTECTÉ');
            }

            details.forEach((detailKey, detailValue) {
              if (detailValue is Map) {
                print('  │  ├─ $detailKey:');
                detailValue.forEach((k, v) => print('  │  │    $k: $v'));
              } else {
                print('  │  ├─ $detailKey: $detailValue');
              }
            });
          }
        });
      }
    } else {
      print('📦 Réponse complète:');
      print(response.body);
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }
  print('');
}

Future<void> testHealthWithDetails() async {
  print('🏥 Test approfondi santé...\n');

  final endpoints = [
    {
      'name': 'Health API (App)',
      'url': 'http://localhost:8080/api/v1/auth/health',
      'method': 'GET',
    },
    {
      'name': 'Health Actuator',
      'url': 'http://localhost:8080/actuator/health',
      'method': 'GET',
    },
    {
      'name': 'Info Actuator',
      'url': 'http://localhost:8080/actuator/info',
      'method': 'GET',
    },
    {
      'name': 'Metrics Actuator',
      'url': 'http://localhost:8080/actuator/metrics',
      'method': 'GET',
    },
  ];

  for (var endpoint in endpoints) {
    final name = endpoint['name']!;
    final url = endpoint['url']!;
    final method = endpoint['method']!;

    print('🔗 $name');
    print('   URL: $url');

    try {
      final response =
          method == 'GET'
              ? await http.get(
                Uri.parse(url),
                headers: {'Accept': 'application/json'},
              )
              : await http.post(
                Uri.parse(url),
                headers: {'Accept': 'application/json'},
              );

      print('   ✅ Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        print('   ⚠️ Problème détecté');

        try {
          final errorData = jsonDecode(response.body);
          print('   📄 Message: ${errorData['message']}');

          if (errorData['timestamp'] != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              errorData['timestamp'],
            );
            print('   🕐 Timestamp: $date');
          }

          if (errorData['path'] != null) {
            print('   🚦 Path: ${errorData['path']}');
          }
        } catch (e) {
          if (response.body.length < 500) {
            print('   📄 Body: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('   ❌ Erreur: $e');
    }
    print('');
  }
}

Future<Map<String, dynamic>?> testUniqueRegistration() async {
  print('🧪 Test d\'inscription avec email unique...\n');

  // Email vraiment unique
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'test${timestamp}_${timestamp % 1000}@example.com';
  final phone = '0${timestamp % 1000000000}'.padLeft(10, '0');

  print('📧 Email: $email');
  print('📱 Téléphone: $phone');

  final url = 'http://localhost:8080/api/v1/auth/register';
  final body = jsonEncode({
    'email': email,
    'password': 'Password123!',
    'firstName': 'Test',
    'lastName': 'User',
    'phone': phone.substring(0, 10), // 10 chiffres
    'role': 'PATIENT',
  });

  try {
    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 20));

    print('📊 Status: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('✅ INSCRIPTION RÉUSSIE !');
        print('🎉 Message: ${data['message']}');

        final userData = data['data']['user'];
        print('👤 User créé:');
        print('   - Email: ${userData['email']}');
        print('   - Nom: ${userData['firstName']} ${userData['lastName']}');
        print('   - Rôle: ${userData['role']}');

        // Retourne les infos pour le test de login
        return {'email': email, 'password': 'Password123!', 'user': userData};
      } else {
        print('⚠️ Réponse: ${data['message']}');
        if (data['data'] != null) {
          print('📋 Erreurs: ${jsonEncode(data['data'])}');
        }
      }
    } else {
      final errorData = jsonDecode(response.body);
      print('❌ Échec: ${errorData['message']}');
      if (errorData['data'] != null) {
        print('📋 Détails: ${jsonEncode(errorData['data'])}');
      }
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
  print('');
  return null;
}

Future<void> testLoginWithExistingUser() async {
  print('🔐 Test connexion utilisateur existant...\n');

  // Essaie avec l'email qui a marché précédemment
  final testEmails = [
    'test@example.com', // Celui qui existe déjà
    'admin@example.com', // Peut-être un admin
    'pharmacist@example.com',
    'patient@example.com',
  ];

  for (var email in testEmails) {
    print('📧 Tentative avec: $email');

    final url = 'http://localhost:8080/api/v1/auth/login';
    final body = jsonEncode({
      'email': email,
      'password': 'Password123!', // Essaie le mot de passe par défaut
    });

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ LOGIN RÉUSSI !');
          final accessToken = data['data']['access_token'];
          if (accessToken != null && accessToken is String) {
            print('🔑 Token reçu: ${accessToken.substring(0, 30)}...');
          } else {
            print('⚠️ Token non reçu ou format incorrect');
          }
          print('👤 User: ${data['data']['user']['email']}');
          print('🎯 Rôle: ${data['data']['user']['role']}');
          return;
        }
      } else if (response.statusCode == 401) {
        print('❌ Email/mot de passe incorrect');
      } else {
        final errorData = jsonDecode(response.body);
        print('⚠️ Erreur: ${errorData['message']}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
    print('');
  }

  print('💡 Conseil: Essaie de créer un utilisateur via Swagger UI');
  print('🌐 http://localhost:8080/swagger-ui.html');
}

// Test rapide
void testQuick() async {
  print('🚀 Test rapide du backend...');

  final health = await http.get(
    Uri.parse('http://localhost:8080/actuator/health'),
    headers: {'Accept': 'application/json'},
  );

  print('Health Status: ${health.statusCode}');

  if (health.statusCode == 200) {
    final data = jsonDecode(health.body);
    print('Status: ${data['status']}');

    final components = data['components'] as Map;
    components.forEach((key, value) {
      if (value is Map && value['status'] != null && value['status'] != 'UP') {
        print('❌ $key: ${value['status']}');
        if (value['details'] != null) {
          print('   Détails: ${value['details']}');
        }
      }
    });
  }
}
