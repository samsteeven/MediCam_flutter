// import 'package:flutter/material.dart';
// import 'package:easypharma_flutter/presentation/screens/auth/login_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/auth/register_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/auth/forgot_password_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/auth/reset_password_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/home/patient_home_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/home/pharmacist_home_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/home/delivery_home_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/profile/profile_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/profile/edit_profile_screen.dart';
// import 'package:easypharma_flutter/presentation/screens/splash_screen.dart';

// class AppRouter {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case SplashScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
      
//       case LoginScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
      
//       case RegisterScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
//       case ForgotPasswordScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
//       case ResetPasswordScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      
//       case PatientHomeScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const PatientHomeScreen());
      
//       case PharmacistHomeScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const PharmacistHomeScreen());
      
//       case DeliveryHomeScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());
      
//       case ProfileScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
//       case EditProfileScreen.routeName:
//         return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('Route not found: ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }