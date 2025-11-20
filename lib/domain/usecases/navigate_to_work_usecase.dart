import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/profile.service.dart';
import 'package:rpa/data/models/safe_route.dart';

final navigateToWorkUseCaseProvider = Provider<NavigateToWorkUseCase>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return NavigateToWorkUseCase(profileService: profileService);
});

class NavigateToWorkUseCase {
  final ProfileService _profileService;

  NavigateToWorkUseCase({required ProfileService profileService})
      : _profileService = profileService;

  Future<SafeRoute> execute({
    required double currentLat,
    required double currentLon,
  }) async {
    try {
      log('Executing navigate to work use case...',
          name: 'NavigateToWorkUseCase');

      final workAddress = await _profileService.getWorkAddress();
      if (workAddress == null) {
        throw Exception('Endereço de trabalho não configurado');
      }

      final response = await _profileService.navigateToWork(
        currentLat: currentLat,
        currentLon: currentLon,
      );

      log('Work navigation completed successfully',
          name: 'NavigateToWorkUseCase');
      return response.route;
    } catch (e) {
      log('Error in navigate to work use case: $e',
          name: 'NavigateToWorkUseCase');
      rethrow;
    }
  }
}
