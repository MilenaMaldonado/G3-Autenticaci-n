import 'package:flutter/material.dart';
import '../viewmodels/user_viewmodel.dart';
import '../model/user_model.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserViewModel userViewModel = UserViewModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: userViewModel.currentUserStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No hay usuario logueado'));
          }
          final user = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  '¡Bienvenido, ${user.displayName ?? user.email}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Has iniciado sesión exitosamente como ${user.role}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StreamBuilder<UserModel?>(
              stream: userViewModel.currentUserStream,
              builder: (context, snapshot) {
                final user = snapshot.data;
                return DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Menú - ${user?.displayName ?? user?.email ?? 'Usuario'}',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu),
              title: const Text('Menú Personalizado'),
              onTap: () {
                Navigator.pushNamed(context, '/custom-menu');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushNamed(context, '/logout');
              },
            ),
          ],
        ),
      ),
    );
  }
}