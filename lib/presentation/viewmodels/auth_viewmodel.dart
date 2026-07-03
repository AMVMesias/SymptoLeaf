import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/datasource/auth_datasource.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthDatasource _authDatasource;
  final FirebaseAuth _firebaseAuth; // Conector para Firebase
  final GoogleSignIn _googleSignIn; // Conector para Google Sign-In
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  
  // Constructor con Inyección de Dependencias
  // El operador ?? asegura que si no pasamos nada (App real), use las instancias oficiales.
  AuthViewModel({
    AuthDatasource? authDatasource, 
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _authDatasource = authDatasource ?? AuthDatasource(),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();
  
  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  String get serverUrl => _authDatasource.serverUrl;
  
  /// Initialize - check if user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final loggedIn = await _authDatasource.isLoggedIn();
      if (loggedIn) {
        _user = await _authDatasource.getSavedUser();
        _isLoggedIn = _user != null;
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Update server URL for network configuration
  Future<void> setServerUrl(String url) async {
    await _authDatasource.setServerUrl(url);
    notifyListeners();
  }
  
  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authDatasource.register(
        name: name,
        email: email,
        password: password,
      );
      
      if (response.success && response.user != null) {
        _user = response.user;
        _isLoggedIn = true;
        _error = null;
      } else {
        _error = response.message;
      }
      
      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authDatasource.login(
        email: email,
        password: password,
      );
      
      if (response.success && response.user != null) {
        _user = response.user;
        _isLoggedIn = true;
        _error = null;
      } else {
        _error = response.message;
      }
      
      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    // 1. Limpiar sesión en SharedPreferences
    await _authDatasource.logout();
    
    // 2. Limpiar sesión en Firebase y Google usando nuestros conectores
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignorar si no estaba logueado de Google
    }
    
    _user = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }
  
  /// Refresh user profile from server
  Future<void> refreshProfile() async {
    try {
      final user = await _authDatasource.getProfile();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors during refresh
    }
  }
  
   /// Clear error
   void clearError() {
     _error = null;
     notifyListeners();
   }

   /// Login con Google
   Future<bool> loginWithGoogle() async {
     _isLoading = true;
     _error = null;
     notifyListeners();

     try {
       // Usamos el conector _googleSignIn en lugar de crear uno nuevo
       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

       if (googleUser == null) {
         _error = 'El usuario canceló el inicio de sesión';
         _isLoading = false;
         notifyListeners();
         return false;
       }

       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

       // Crear credencial con el token de Google
       final credential = GoogleAuthProvider.credential(
         accessToken: googleAuth.accessToken,
         idToken: googleAuth.idToken,
       );

       // Iniciar sesión con Firebase usando nuestro conector _firebaseAuth
       final userCredential = await _firebaseAuth.signInWithCredential(credential);

       if (userCredential.user != null) {
         // Convertir el User de Firebase a nuestro UserModel local
         final newUser = UserModel(
           id: userCredential.user!.uid.hashCode,
           name: userCredential.user!.displayName ?? 'Usuario',
           email: userCredential.user!.email ?? '',
         );
         
         // Persistir la sesión en caché (SharedPreferences)
         final tkn = googleAuth.idToken ?? userCredential.user!.uid;
         await _authDatasource.saveExternalSession(newUser, tkn);
         
         _user = newUser;
         _isLoggedIn = true;
         _error = null;
       } else {
         _error = 'No se pudo crear la sesión';
       }

       _isLoading = false;
       notifyListeners();
       return _isLoggedIn;
     } catch (e) {
       _error = 'Error en Google Sign-In: $e';
       _isLoading = false;
       notifyListeners();
       return false;
     }
   }

 }
