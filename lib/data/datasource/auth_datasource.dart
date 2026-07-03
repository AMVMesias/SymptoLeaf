import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data model for user
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt,
  };
}

/// Authentication response model
class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['data']?['user'] != null 
          ? UserModel.fromJson(json['data']['user']) 
          : null,
      token: json['data']?['token'],
    );
  }
}

/// AuthDatasource handles all HTTP communication with the backend
class AuthDatasource {
  String? _token;
  final FirebaseAuth _firebaseAuth; // Conector para Firebase
  
  // Shared preferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _serverUrlKey = 'auth_server_url';
  
  // Constructor con Inyección de Dependencias:
  // Si se pasa un firebaseAuth (en tests), lo usa. 
  // Si no (en la app real), usa la instancia oficial.
  AuthDatasource({FirebaseAuth? firebaseAuth}) 
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  
  /// Update the server URL (for network configuration)
  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }
  
  /// Get the current server URL
  String get serverUrl => "Firebase Cloud";
  
  /// Initialize from saved preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }
  
  /// Get authorization headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        final userModel = UserModel(
          id: user.uid.hashCode, 
          name: name,
          email: email,
          createdAt: null, 
        );
        
        final authResponse = AuthResponse(
          success: true,
          message: 'Registro exitoso',
          user: userModel,
          token: await user.getIdToken(),
        );
        await _saveAuth(authResponse);
        return authResponse;
      }
      
      return AuthResponse(
        success: false,
        message: 'Error desconocido',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }
  
  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        final authResponse = AuthResponse(
          success: true,
          message: 'Login exitoso',
          user: UserModel(
            id: user.uid.hashCode,
            name: user.displayName ?? '',
            email: email,
            createdAt: null,
          ),
          token: await user.getIdToken(),
        );
        await _saveAuth(authResponse);
        return authResponse;
      }
      
      return AuthResponse(
        success: false,
        message: 'Error desconocido',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Error desconocido',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }
  
  /// Get current user profile
  Future<UserModel?> getProfile() async {
    if (_token == null) return null;
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.uid.hashCode,
          name: user.displayName ?? '',
          email: user.email ?? '',
          createdAt: null,
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      _token = await user.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      if (prefs.getString(_userKey) == null) {
        final userModel = UserModel(
          id: user.uid.hashCode,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
        await prefs.setString(_userKey, jsonEncode(userModel.toJson()));
      }
      return true;
    }

    await init();
    return _token != null;
  }
  
  /// Get saved user from preferences
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  /// Logout - clear saved data
  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    await _firebaseAuth.signOut();
  }
  
  /// Save an external auth session (like Google or Firebase)
  Future<void> saveExternalSession(UserModel user, String externalToken) async {
    _token = externalToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, externalToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  /// Save auth response to preferences
  Future<void> _saveAuth(AuthResponse response) async {
    _token = response.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token!);
    if (response.user != null) {
      await prefs.setString(_userKey, jsonEncode(response.user!.toJson()));
    }
  }
  
  /// Get current token
  String? get token => _token;
}
