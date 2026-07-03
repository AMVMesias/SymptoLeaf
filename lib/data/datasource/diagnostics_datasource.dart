import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for diagnostic data
class DiagnosticModel {
  final String? id;
  final String? userId;
  final String plantName;
  final String diseaseName;
  final double? confidence;
  final String? treatment;
  final String? imageBase64;
  final String? imageUrl;
  final String? createdAt;

  DiagnosticModel({
    this.id,
    this.userId,
    required this.plantName,
    required this.diseaseName,
    this.confidence,
    this.treatment,
    this.imageBase64,
    this.imageUrl,
    this.createdAt,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      plantName: json['plant_name'] ?? '',
      diseaseName: json['disease_name'] ?? '',
      confidence: json['confidence']?.toDouble(),
      treatment: json['treatment'],
      imageBase64: json['image_base64'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'plant_name': plantName,
      'disease_name': diseaseName,
      'confidence': confidence,
      'treatment': treatment,
      'image_url': imageUrl,
      // No mandamos image_base64 a Firestore si ya tenemos URL
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt;
    } else {
      map['created_at'] = DateTime.now().toIso8601String();
    }
    if (imageBase64 != null && imageUrl == null) {
      map['image_base64'] = imageBase64;
    }
    return map;
  }
}

/// Model for chat message
class ChatMessageModel {
  final String? id;
  final String content;
  final bool isUser;
  final String? timestamp;

  ChatMessageModel({
    this.id,
    required this.content,
    required this.isUser,
    this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString(),
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp ?? DateTime.now().toIso8601String(),
  };
}

/// DiagnosticsDatasource handles diagnostic history with the backend
class DiagnosticsDatasource {
  // IP FIJA del Hotspot Móvil de Windows (siempre es 192.168.137.1)
  static const String _defaultBaseUrl = 'Firebase Cloud';

  String _baseUrl;
  String? _token;
  
  static const String _tokenKey = 'auth_token';
  static const String _serverUrlKey = 'auth_server_url';
  
  DiagnosticsDatasource({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;
  
  /// Initialize from saved preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }
  
  /// Get authorization headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Save a new diagnostic
  Future<DiagnosticModel?> saveDiagnostic(DiagnosticModel diagnostic) async {
    try {
      await init();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final docRef = FirebaseFirestore.instance.collection('diagnostics').doc();

      final Map<String, dynamic> data = diagnostic.toJson();
      data['id'] = docRef.id;
      data['user_id'] = uid;

      // Opción 2 (Plan 100% Gratis - Spark):
      // Guardamos la imagen codificada como texto Base64 directo a Firestore
      // en vez de usar Firebase Storage.
      await docRef.set(data);
      data['id'] = docRef.id;

      return DiagnosticModel.fromJson(data);
    } catch (e) {
      print('Error saving diagnostic: $e');
      return null;
    }
  }

  /// Get all diagnostics for the user
  Future<List<DiagnosticModel>> getDiagnostics({int limit = 50, int offset = 0}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      if (uid == null) return [];

      print('🔎 Firebase current uid: $uid');
      print('🔎 Firebase current email: ${user?.email}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('diagnostics')
          .where('user_id', isEqualTo: uid)
          .get();

      final docs = querySnapshot.docs;
      print('🔎 Diagnostics docs for current user: ${docs.length}');

      final results = docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print(
          '🔎 Diagnostic ${doc.id}: user_id=${data['user_id']}, '
          'has_base64=${(data['image_base64'] as String?)?.isNotEmpty == true}, '
          'has_url=${(data['image_url'] as String?)?.isNotEmpty == true}',
        );
        return DiagnosticModel.fromJson(data);
      }).toList();

      // Ordenar localmente por fecha de creación (descendente)
      results.sort((a, b) {
        final dateA = a.createdAt != null ? DateTime.tryParse(a.createdAt!) ?? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt != null ? DateTime.tryParse(b.createdAt!) ?? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      // Aplicar límite
      if (results.length > limit) {
        return results.sublist(0, limit);
      }
      return results;
    } catch (e) {
      print('Error getting diagnostics: $e');
      return [];
    }
  }

  /// Get a specific diagnostic by ID
  Future<DiagnosticModel?> getDiagnostic(String id) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('diagnostics').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return DiagnosticModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting diagnostic: $e');
      return null;
    }
  }

  /// Delete a diagnostic
  Future<bool> deleteDiagnostic(String id) async {
    try {
      await FirebaseFirestore.instance.collection('diagnostics').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting diagnostic: $e');
      return false;
    }
  }

  /// Save chat history
  Future<bool> saveChatHistory({
    required String? userId,
    String? diagnosticId,
    required List<ChatMessageModel> messages,
  }) async {
    try {
      if (diagnosticId == null) return false;

      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      for (var msg in messages) {
        final docRef = db.collection('diagnostics').doc(diagnosticId).collection('chats').doc();
        final data = msg.toJson();
        data['id'] = docRef.id;
        batch.set(docRef, data);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Error saving chat history: $e');
      return false;
    }
  }

  /// Get chat history for a diagnostic
  Future<List<ChatMessageModel>> getChatHistory(String diagnosticId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('diagnostics')
          .doc(diagnosticId)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessageModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }
}
