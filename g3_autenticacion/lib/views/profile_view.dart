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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Mi Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_isEditing) {
                          if (_formKey.currentState!.validate()) {
                            try {
                              UserModel? user =
                                  await _userViewModel.currentUserStream.first;
                              if (user != null) {
                                user = user.copyWith(
                                  displayName: _displayNameController.text
                                      .trim(),
                                  phoneNumber: _phoneController.text.isEmpty
                                      ? null
                                      : _phoneController.text.trim(),
                                );
                                await _authViewModel.updateUser(user);
                                setState(() {
                                  _isEditing = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Perfil actualizado'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('Error: $e')),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
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
              ),

              // Content
              Expanded(
                child: StreamBuilder<UserModel?>(
                  stream: _userViewModel.currentUserStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'No hay usuario logueado',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }
                    final user = snapshot.data!;
                    _displayNameController.text = user.displayName ?? '';
                    _phoneController.text = user.phoneNumber ?? '';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile Avatar
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Profile Card
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    _buildProfileField(
                                      icon: Icons.email,
                                      label: 'Email',
                                      value: user.email,
                                      isEditable: false,
                                    ),

                                    const SizedBox(height: 20),

                                    _buildProfileField(
                                      icon: Icons.person,
                                      label: 'Nombre',
                                      value: user.displayName ?? 'Sin nombre',
                                      isEditable: _isEditing,
                                      controller: _displayNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El nombre no puede estar vacío';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    _buildProfileField(
                                      icon: Icons.phone,
                                      label: 'Teléfono',
                                      value:
                                          user.phoneNumber ?? 'No especificado',
                                      isEditable: _isEditing,
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                    ),

                                    const SizedBox(height: 20),

                                    _buildProfileField(
                                      icon: Icons.admin_panel_settings,
                                      label: 'Rol',
                                      value: user.role.toUpperCase(),
                                      isEditable: false,
                                      roleColor: user.role == 'admin'
                                          ? Colors.red
                                          : Colors.blue,
                                    ),

                                    const SizedBox(height: 20),

                                    // Email Verification Section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: user.isEmailVerified
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: user.isEmailVerified
                                              ? Colors.green.shade200
                                              : Colors.orange.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                user.isEmailVerified
                                                    ? Icons.verified
                                                    : Icons.warning,
                                                color: user.isEmailVerified
                                                    ? Colors.green.shade600
                                                    : Colors.orange.shade600,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Email Verificado',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            user.isEmailVerified
                                                            ? Colors
                                                                  .green
                                                                  .shade700
                                                            : Colors
                                                                  .orange
                                                                  .shade700,
                                                      ),
                                                    ),
                                                    Text(
                                                      user.isEmailVerified
                                                          ? 'Verificado'
                                                          : 'Pendiente',
                                                      style: TextStyle(
                                                        color:
                                                            user.isEmailVerified
                                                            ? Colors
                                                                  .green
                                                                  .shade600
                                                            : Colors
                                                                  .orange
                                                                  .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (!user.isEmailVerified) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      await _authViewModel
                                                          .sendEmailVerification();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.email,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Correo de verificación enviado',
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor:
                                                              Colors.blue,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.email,
                                                      size: 16,
                                                    ),
                                                    label: const Text('Enviar'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors
                                                          .orange
                                                          .shade600,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final verified =
                                                        await _authViewModel
                                                            .refreshEmailVerification();
                                                    if (verified) {
                                                      setState(() {});
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                '¡Email verificado!',
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.info,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'El email aún no está verificado',
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor:
                                                              Colors.orange,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                    size: 16,
                                                  ),
                                                  label: const Text(
                                                    'Verificar',
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue.shade600,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Edit Action Buttons
                            if (_isEditing)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          try {
                                            UserModel? updatedUser =
                                                await _userViewModel
                                                    .currentUserStream
                                                    .first;
                                            if (updatedUser != null) {
                                              updatedUser = updatedUser
                                                  .copyWith(
                                                    displayName:
                                                        _displayNameController
                                                            .text
                                                            .trim(),
                                                    phoneNumber:
                                                        _phoneController
                                                            .text
                                                            .isEmpty
                                                        ? null
                                                        : _phoneController.text
                                                              .trim(),
                                                  );
                                              await _authViewModel.updateUser(
                                                updatedUser,
                                              );
                                              setState(() {
                                                _isEditing = false;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Perfil actualizado',
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text('Error: $e'),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Guardar'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Color? roleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: roleColor?.withOpacity(0.1) ?? Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: roleColor ?? Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditable && controller != null)
                  TextFormField(
                    controller: controller,
                    validator: validator,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: roleColor ?? Colors.grey.shade800,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
