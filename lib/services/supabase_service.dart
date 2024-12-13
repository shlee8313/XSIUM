// lib\services\supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get instance {
    if (_client == null) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null || anonKey == null) {
        throw Exception('Supabase configuration missing in .env file');
      }

      await Supabase.initialize(url: url, anonKey: anonKey, debug: true);
      _client = Supabase.instance.client;
      await _testConnection();

      developer.log('Supabase initialized successfully');
    } catch (e, stackTrace) {
      developer.log('Failed to initialize Supabase',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> _testConnection() async {
    try {
      developer.log('Testing Supabase connection...');

      if (_client == null) {
        throw Exception('Supabase client is null');
      }

      // users 테이블로 테스트 쿼리 변경
      final response = await _client?.from('users').select('id').limit(1);
      developer.log('Database query test response: $response');

      developer.log('Supabase connection test successful');
    } catch (e) {
      developer.log('Supabase connection test failed: $e');
      rethrow;
    }
  }

  // 사용자 조회 메서드 (profile -> user로 변경)
  static Future<Map<String, dynamic>?> getUser(String xummAddress) async {
    try {
      final response = await _client
          ?.from('users')
          .select()
          .eq('xumm_address', xummAddress)
          .single();
      return response;
    } catch (e) {
      developer.log('Error fetching user: $e');
      return null;
    }
  }

  // 사용자 존재 여부 확인 (profile -> user로 변경)
  static Future<bool> hasUser(String xummAddress) async {
    try {
      final response = await _client
          ?.from('users')
          .select('xumm_address')
          .eq('xumm_address', xummAddress)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 새 사용자 생성 메서드 (createProfile -> createUser로 변경)
  static Future<bool> createUser({
    required String displayName,
    required String xummAddress,
    required String xummUuid,
    required String avatarPath,
  }) async {
    try {
      developer.log('Creating new user...');

      final userData = {
        'display_name': displayName,
        'xumm_address': xummAddress,
        'xumm_uuid': xummUuid,
        'avatar_url': avatarPath,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client?.from('users').insert(userData).select();

      developer.log('User created successfully: $response');
      return true;
    } catch (e, stackTrace) {
      developer.log('Error creating user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // 사용자 정보 업데이트 (profile -> user로 변경)
  static Future<bool> updateUser({
    required String xummAddress,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final updates = {
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (updates.isEmpty) return true;

      await _client
          ?.from('users')
          .update(updates)
          .eq('xumm_address', xummAddress);
      return true;
    } catch (e) {
      developer.log('Error updating user: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }
}
