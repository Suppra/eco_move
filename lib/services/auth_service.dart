import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache para evitar consultas excesivas
  UserModel? _cachedUser;
  String? _lastKnownUid;

  // Obtener usuario actual una sola vez (para uso en HomeTab)
  Future<UserModel?> getCurrentUserOnce() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Si ya tenemos el usuario cached y es el mismo UID, devolverlo
        if (_cachedUser != null && _lastKnownUid == firebaseUser.uid) {
          return _cachedUser;
        }

        // Si no, cargar desde Firestore y cachear
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          _cachedUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
          _lastKnownUid = firebaseUser.uid;
          return _cachedUser;
        }
      }
      return null;
    } catch (e) {
      print('AuthService - Error getting current user: $e');
      return null;
    }
  }

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

        final newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          document: document,
        );
        
        // Cachear el nuevo usuario
        _cachedUser = newUser;
        _lastKnownUid = user.uid;
        
        return newUser;
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
          final userData = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
          
          // Cachear el usuario al loguearse
          _cachedUser = userData;
          _lastKnownUid = user.uid;
          
          return userData;
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
    _cachedUser = null;
    _lastKnownUid = null;
    return await _auth.signOut();
  }

  // Obtener usuario actual
  Stream<UserModel?> get currentUser {
    return _auth.authStateChanges().asyncMap((User? user) async {
      try {
        if (user != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userData = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
            return userData;
          }
        }
        return null;
      } catch (e) {
        print('AuthService - Error in currentUser stream: $e');
        return null;
      }
    });
  }
}