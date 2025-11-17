import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';

class DeviceIdManager {
  static const String _deviceIdKey = 'device_id';
  static const Uuid _uuid = Uuid();
  
  String? _cachedDeviceId;
  
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await prefs.setString(_deviceIdKey, deviceId);
      log('🆔 New device_id generated: $deviceId', name: 'DeviceIdManager');
    } else {
      log('🆔 Device_id retrieved: $deviceId', name: 'DeviceIdManager');
    }
    
    _cachedDeviceId = deviceId;
    return deviceId;
  }
  
  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
    log('🗑️ Device_id cleared', name: 'DeviceIdManager');
  }
}
