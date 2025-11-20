import '../models/saved_address.dart';

class UpdateProfileRequestDTO {
  final SavedAddress? homeAddress;
  final SavedAddress? workAddress;

  const UpdateProfileRequestDTO({
    this.homeAddress,
    this.workAddress,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (homeAddress != null) {
      json['home_address'] = homeAddress!.toJson();
    }
    if (workAddress != null) {
      json['work_address'] = workAddress!.toJson();
    }
    return json;
  }
}
