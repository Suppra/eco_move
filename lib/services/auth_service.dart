import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear usuario
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password, String name, String document) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Guardar información adicional en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'document': document,
        });

        return UserModel(
          id: user.uid,
          name: name,
          email: email,
          document: document,
        );
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Iniciar sesión
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Obtener usuario actual
  Stream<UserModel?> get currentUser {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    });
  }
}