import 'package:flutter/material.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({Key? key}) : super(key: key);

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final List<Map<String, dynamic>> _users = [
    {
      'uid': '1',
      'email': 'usuario1@ejemplo.com',
      'displayName': 'Usuario Uno',
      'role': 'usuario',
      'isEmailVerified': true,
      'phoneNumber': '+1234567890',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'uid': '2',
      'email': 'admin@ejemplo.com',
      'displayName': 'Administrador',
      'role': 'admin',
      'isEmailVerified': true,
      'phoneNumber': '+0987654321',
      'createdAt': DateTime.now().subtract(const Duration(days: 60)),
      'lastLogin': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'uid': '3',
      'email': 'usuario2@ejemplo.com',
      'displayName': 'Usuario Dos',
      'role': 'usuario',
      'isEmailVerified': false,
      'phoneNumber': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'lastLogin': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user['role'] == 'admin'
                    ? Colors.red
                    : Colors.blue,
                child: Icon(
                  user['role'] == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text(user['displayName'] ?? 'Sin nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          user['role'].toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: user['role'] == 'admin'
                            ? Colors.red
                            : Colors.blue,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      if (user['isEmailVerified'])
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16,
                        )
                      else
                        const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Eliminar'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditUserDialog(user, index);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(user, index);
                  }
                },
              ),
              onTap: () {
                _showUserDetails(user);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['displayName'] ?? 'Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Rol: ${user['role']}'),
            Text('Teléfono: ${user['phoneNumber'] ?? 'No especificado'}'),
            Text('Email verificado: ${user['isEmailVerified'] ? 'Sí' : 'No'}'),
            Text('Creado: ${_formatDate(user['createdAt'])}'),
            Text(
              'Último acceso: ${user['lastLogin'] != null ? _formatDate(user['lastLogin']) : 'Nunca'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user, int index) {
    final nameController = TextEditingController(text: user['displayName']);
    final phoneController = TextEditingController(
      text: user['phoneNumber'] ?? '',
    );
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (value) {
                selectedRole = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users[index]['displayName'] = nameController.text;
                _users[index]['phoneNumber'] = phoneController.text.isEmpty
                    ? null
                    : phoneController.text;
                _users[index]['role'] = selectedRole;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${user['displayName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'usuario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (value) {
                selectedRole = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                setState(() {
                  _users.add({
                    'uid': DateTime.now().millisecondsSinceEpoch.toString(),
                    'email': emailController.text,
                    'displayName': nameController.text,
                    'role': selectedRole,
                    'isEmailVerified': false,
                    'phoneNumber': phoneController.text.isEmpty
                        ? null
                        : phoneController.text,
                    'createdAt': DateTime.now(),
                    'lastLogin': null,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario agregado')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
