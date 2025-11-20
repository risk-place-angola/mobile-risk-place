import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/services/profile.service.dart';
import 'package:rpa/data/models/safe_route.dart';

final navigateToHomeUseCaseProvider = Provider<NavigateToHomeUseCase>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return NavigateToHomeUseCase(profileService: profileService);
});

class NavigateToHomeUseCase {
  final ProfileService _profileService;

  NavigateToHomeUseCase({required ProfileService profileService})
      : _profileService = profileService;

  Future<SafeRoute> execute({
    required double currentLat,
    required double currentLon,
  }) async {
    try {
      log('Executing navigate to home use case...',
          name: 'NavigateToHomeUseCase');

      final homeAddress = await _profileService.getHomeAddress();
      if (homeAddress == null) {
        throw Exception('Endereço de casa não configurado');
      }

      final response = await _profileService.navigateToHome(
        currentLat: currentLat,
        currentLon: currentLon,
      );

      log('Home navigation completed successfully',
          name: 'NavigateToHomeUseCase');
      return response.route;
    } catch (e) {
      log('Error in navigate to home use case: $e',
          name: 'NavigateToHomeUseCase');
      rethrow;
    }
  }
}
