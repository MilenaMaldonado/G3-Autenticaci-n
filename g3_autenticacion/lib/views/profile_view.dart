import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Actualizar estado de verificación al abrir la pantalla
    _authViewModel.refreshEmailVerification();
  }
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthViewModel _authViewModel = AuthViewModel();
  final UserViewModel _userViewModel = UserViewModel();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  try {
                    UserModel? user = await _userViewModel.currentUserStream.first;
                    if (user != null) {
                      user = user.copyWith(
                        displayName: _displayNameController.text.trim(),
                        phoneNumber: _phoneController.text.isEmpty
                            ? null
                            : _phoneController.text.trim(),
                      );
                      await _authViewModel.updateUser(user);
                      setState(() {
                        _isEditing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: _userViewModel.currentUserStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No hay usuario logueado'));
          }
          final user = snapshot.data!;
          _displayNameController.text = user.displayName ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Email'),
                            subtitle: Text(user.email),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Nombre'),
                            subtitle: _isEditing
                                ? TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El nombre no puede estar vacío';
                                }
                                return null;
                              },
                            )
                                : Text(user.displayName ?? 'Sin nombre'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Teléfono'),
                            subtitle: _isEditing
                                ? TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              keyboardType: TextInputType.phone,
                            )
                                : Text(user.phoneNumber ?? 'No especificado'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Rol'),
                            subtitle: Text(user.role),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.verified),
                            title: const Text('Email Verificado'),
                            subtitle: Text(user.isEmailVerified ? 'Sí' : 'No'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.isEmailVerified
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: user.isEmailVerified ? Colors.green : Colors.orange,
                                ),
                                if (!user.isEmailVerified)
                                  IconButton(
                                    icon: const Icon(Icons.email),
                                    tooltip: 'Enviar verificación',
                                    onPressed: () async {
                                      await _authViewModel.sendEmailVerification();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Correo de verificación enviado'),
                                        ),
                                      );
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Refrescar estado',
                                  onPressed: () async {
                                    final verified = await _authViewModel.refreshEmailVerification();
                                    if (verified) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Email verificado!'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('El email aún no está verificado'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                UserModel? updatedUser = await _userViewModel.currentUserStream.first;
                                if (updatedUser != null) {
                                  updatedUser = updatedUser.copyWith(
                                    displayName: _displayNameController.text.trim(),
                                    phoneNumber: _phoneController.text.isEmpty
                                        ? null
                                        : _phoneController.text.trim(),
                                  );
                                  await _authViewModel.updateUser(updatedUser);
                                  setState(() {
                                    _isEditing = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Perfil actualizado')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
