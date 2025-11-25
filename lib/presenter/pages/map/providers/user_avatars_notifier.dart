import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/models/websocket/nearby_user_model.dart';

class UserAvatarsState {
  final Map<String, NearbyUserModel> users;
  final DateTime lastUpdate;

  const UserAvatarsState({
    this.users = const {},
    required this.lastUpdate,
  });

  UserAvatarsState copyWith({
    Map<String, NearbyUserModel>? users,
    DateTime? lastUpdate,
  }) {
    return UserAvatarsState(
      users: users ?? this.users,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  List<NearbyUserModel> get activeUsers {
    return users.values.where((user) => !user.isInactive).toList();
  }
}

class UserAvatarsNotifier extends Notifier<UserAvatarsState> {
  static const int maxVisibleUsers = 100;
  Timer? _throttleTimer;
  Timer? _cleanupTimer;

  @override
  UserAvatarsState build() {
    _startInactiveUserCleanup();
    return UserAvatarsState(lastUpdate: DateTime.now());
  }

  void updateNearbyUsers(List<NearbyUserModel> newUsers) {
    if (_throttleTimer?.isActive ?? false) return;
    
    _throttleTimer = Timer(const Duration(milliseconds: 500), () {
      try {
        final updatedUsers = Map<String, NearbyUserModel>.from(state.users);
        bool hasChanges = false;
        
        final limitedUsers = newUsers.take(maxVisibleUsers);
        
        for (final user in limitedUsers) {
          final existing = updatedUsers[user.userId];
          
          // Only update if position changed significantly (>10m ≈ 0.0001 degrees)
          if (existing == null || _hasSignificantChange(existing, user)) {
            updatedUsers[user.userId] = user;
            hasChanges = true;
          }
        }
        
        // Remove inactive users
        final before = updatedUsers.length;
        updatedUsers.removeWhere((_, user) => user.isInactive);
        if (before != updatedUsers.length) hasChanges = true;

        if (hasChanges) {
          log('${updatedUsers.values.where((u) => !u.isInactive).length} active avatars', name: 'UserAvatarsNotifier');
          state = state.copyWith(
            users: updatedUsers,
            lastUpdate: DateTime.now(),
          );
        }
      } catch (e) {
        log('Error updating nearby users: $e', name: 'UserAvatarsNotifier');
      }
    });
  }

  bool _hasSignificantChange(NearbyUserModel old, NearbyUserModel newUser) {
    const threshold = 0.0001; // ~10 meters
    final latDiff = (old.latitude - newUser.latitude).abs();
    final lngDiff = (old.longitude - newUser.longitude).abs();
    return latDiff > threshold || lngDiff > threshold;
  }

  void _startInactiveUserCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final updatedUsers = Map<String, NearbyUserModel>.from(state.users);
      updatedUsers.removeWhere((_, user) => user.isInactive);
      
      if (updatedUsers.length != state.users.length) {
        state = state.copyWith(users: updatedUsers);
      }
    });
  }

  void clear() {
    state = UserAvatarsState(lastUpdate: DateTime.now());
  }

  void removeUser(String userId) {
    final updatedUsers = Map<String, NearbyUserModel>.from(state.users);
    updatedUsers.remove(userId);
    
    state = state.copyWith(users: updatedUsers);
  }
}

final userAvatarsProvider = NotifierProvider<UserAvatarsNotifier, UserAvatarsState>(
  UserAvatarsNotifier.new,
);
