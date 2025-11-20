import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/models/user_settings_dto.dart';
import 'package:rpa/domain/entities/user_settings.dart';
import 'package:rpa/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final IHttpClient _httpClient;

  SettingsRepositoryImpl({required IHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<UserSettings> getSettings() async {
    log('[SettingsRepository] Fetching user settings');
    try {
      final response = await _httpClient.get('/users/me/settings');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch settings',
          statusCode: response.statusCode,
        );
      }

      final settingsDto =
          UserSettingsDto.fromJson(response.data as Map<String, dynamic>);
      log('[SettingsRepository] Settings fetched successfully');
      return settingsDto.toEntity();
    } catch (e) {
      log('[SettingsRepository] Error fetching settings: $e');
      rethrow;
    }
  }

  @override
  Future<UserSettings> updateSettings(Map<String, dynamic> updates) async {
    log('[SettingsRepository] Updating settings');
    try {
      final body = _convertToSnakeCase(updates);

      final response = await _httpClient.put(
        '/users/me/settings',
        data: body,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update settings',
          statusCode: response.statusCode,
        );
      }

      final settingsDto =
          UserSettingsDto.fromJson(response.data as Map<String, dynamic>);
      log('[SettingsRepository] Settings updated successfully');
      return settingsDto.toEntity();
    } catch (e) {
      log('[SettingsRepository] Error updating settings: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertToSnakeCase(Map<String, dynamic> updates) {
    final Map<String, dynamic> snakeCaseMap = {};

    updates.forEach((key, value) {
      final snakeKey = _toSnakeCase(key);

      if (value is List) {
        if (value.isNotEmpty && value.first is Enum) {
          snakeCaseMap[snakeKey] = value.map((e) => (e as Enum).name).toList();
        } else {
          snakeCaseMap[snakeKey] = value;
        }
      } else if (value is Enum) {
        snakeCaseMap[snakeKey] = value.name;
      } else {
        snakeCaseMap[snakeKey] = value;
      }
    });

    return snakeCaseMap;
  }

  String _toSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return SettingsRepositoryImpl(httpClient: httpClient);
});
