import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';

// ============================================================================
// USER STATE PROVIDERS
// ============================================================================
// Provides current logged-in user information from local storage
// Uses Riverpod 2.0+ AsyncNotifier pattern for reactive state management
//
// IMPLEMENTATION NOTES:
// - Reads user data from the 'users' collection saved during login
// - This is where AuthService stores the AuthTokenResponseDTO
// - Extracts user ID from the nested user object in the auth response
// - Follows Single Source of Truth principle
// ============================================================================

/// Provider for UserBox (legacy Hive storage)
final userBoxProvider = Provider<UserBox>((ref) {
  return UserBox();
});

/// Provider for DBHelper (primary storage for auth data)
final dbHelperAuthProvider = Provider<IDBHelper>((ref) {
  return ref.watch(dbHelperProvider);
});

/// Provider for current user from auth data
final currentUserFromAuthProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final dbHelper = ref.watch(dbHelperAuthProvider);
  try {
    final authData = await dbHelper.getData(
      collection: BDCollections.USERS,
      key: 'user',
    );

    if (authData != null && authData is Map) {
      // Extract the user object from the auth response
      final userData = authData['user'];
      if (userData != null && userData is Map) {
        return Map<String, dynamic>.from(userData);
      }
    }
    return null;
  } catch (e) {
    return null;
  }
});

/// Provider for current user - tries auth data first, then falls back to UserBox
final currentUserProvider = FutureProvider<User?>((ref) async {
  // Try to get user from auth data first (more reliable)
  final authUser = await ref.watch(currentUserFromAuthProvider.future);

  if (authUser != null && authUser['id'] != null) {
    // Convert auth user data to User model
    return User(
      id: authUser['id'] as String?,
      name: authUser['name'] as String?,
      email: authUser['email'] as String?,
      phoneNumber: authUser['phone'] as String?,
    );
  }

  // Fallback to UserBox (legacy)
  final userBox = ref.watch(userBoxProvider);
  return await userBox.getUser();
});

/// Provider to get current user ID
/// Returns null if user is not logged in or still loading
final currentUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      final userId = user?.id;
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null && userId.isNotEmpty;
});
