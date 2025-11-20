import 'package:rpa/data/models/saved_address.dart';
import 'package:rpa/data/dtos/safe_route_response_dto.dart';

abstract class IProfileService {
  Future<void> updateProfile({
    SavedAddress? homeAddress,
    SavedAddress? workAddress,
  });

  Future<SavedAddress?> getHomeAddress();

  Future<SavedAddress?> getWorkAddress();

  Future<SafeRouteResponseDTO> navigateToHome({
    required double currentLat,
    required double currentLon,
  });

  Future<SafeRouteResponseDTO> navigateToWork({
    required double currentLat,
    required double currentLon,
  });
}
