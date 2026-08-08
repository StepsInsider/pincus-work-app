import 'package:freezed_annotation/freezed_annotation.dart';

part 'baustelle_model.freezed.dart';
part 'baustelle_model.g.dart';

@freezed
class Baustelle with _$Baustelle {
  const factory Baustelle({
    required String id,
    @JsonKey(name: 'company_id') required String companyId,
    required String name,
    @JsonKey(name: 'client_name') required String clientName,
    required String address,
    required String status,
    required double budget,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Baustelle;

  factory Baustelle.fromJson(Map<String, dynamic> json) =>
      _$BaustelleFromJson(json);
}
