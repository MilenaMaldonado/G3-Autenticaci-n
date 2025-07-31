import 'package:flutter/material.dart';

class CustomMenuView extends StatelessWidget {
  const CustomMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener rol del usuario actual desde Firebase/SharedPreferences
    final bool isAdmin = true; // Cambiar según el usuario logueado

    return Scaffold(
      appBar: AppBar(title: const Text('Menú')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Opciones Disponibles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            icon: Icons.home,
            title: 'Inicio',
            subtitle: 'Pantalla principal',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
          ),
          _buildMenuCard(
            icon: Icons.person,
            title: 'Mi Perfil',
            subtitle: 'Ver y editar información personal',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            const Text(
              'Opciones de Administrador',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuCard(
              icon: Icons.group,
              title: 'Gestión de Usuarios',
              subtitle: 'Administrar todos los usuarios',
              onTap: () {
                Navigator.pushNamed(context, '/admin-users');
              },
              isAdminOption: true,
            ),
            _buildMenuCard(
              icon: Icons.settings,
              title: 'Configuración del Sistema',
              subtitle: 'Ajustes avanzados',
              onTap: () {
                // TODO: Implementar vista de configuración
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función en desarrollo')),
                );
              },
              isAdminOption: true,
            ),
          ],
          const SizedBox(height: 24),
          _buildMenuCard(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de la aplicación',
            onTap: () {
              _showLogoutDialog(context);
            },
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isAdminOption = false,
    bool isDanger = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDanger
              ? Colors.red
              : isAdminOption
              ? Colors.orange
              : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDanger ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
