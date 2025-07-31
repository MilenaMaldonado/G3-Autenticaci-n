import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G3 Autenticación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/welcome': (context) => const WelcomeView(),
        '/forgot-password': (context) => const ForgotPasswordView(),
        '/profile': (context) => const ProfileView(),
        '/custom-menu': (context) => const CustomMenuView(),
        '/admin-users': (context) => const AdminUsersView(),
        '/logout': (context) => const LogoutView(),
      },
    );
  }
}