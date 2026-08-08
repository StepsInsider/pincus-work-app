// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baustelle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Baustelle _$BaustelleFromJson(Map<String, dynamic> json) => _Baustelle(
  id: json['id'] as String,
  companyId: json['company_id'] as String,
  name: json['name'] as String,
  clientName: json['client_name'] as String,
  address: json['address'] as String,
  status: json['status'] as String,
  budget: (json['budget'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BaustelleToJson(_Baustelle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'name': instance.name,
      'client_name': instance.clientName,
      'address': instance.address,
      'status': instance.status,
      'budget': instance.budget,
      'created_at': instance.createdAt.toIso8601String(),
    };
