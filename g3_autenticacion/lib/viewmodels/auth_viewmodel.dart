import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class AuthViewModel {
  // Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Refresh and return email verification status
  Future<bool> refreshEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      final isVerified = _auth.currentUser!.emailVerified;
      // Actualizar el campo en Firestore si está verificado
      if (isVerified) {
        await _firestore.collection('users').doc(user.uid).update({
          'isEmailVerified': true,
        });
      }
      return isVerified;
    }
    return false;
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Login with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateLastLogin(userCredential.user!.uid);
      return await _getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register new user
  Future<UserModel?> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = userCredential.user!;
      await user.updateDisplayName(displayName);
      UserModel userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: 'usuario',
        isEmailVerified: user.emailVerified,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get user data from Firestore
  Future<UserModel?> _getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all users (for admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Update user data (for admin or profile)
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // Delete user (for admin)
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
    // Note: Deleting Firebase Auth user requires Admin SDK
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con ese email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El email ya está registrado.';
      case 'invalid-email':
        return 'El email no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return e.message ?? 'Ocurrió un error.';
    }
  }
}