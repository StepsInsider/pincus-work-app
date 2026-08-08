import 'package:flutter/foundation.dart';

@immutable
class KundeModel {
  final String id;
  final String firmenname;
  final String ansprechpartner;
  final String strasse;
  final String plz;
  final String ort;
  final String telefon;
  final String email;
  final DateTime erstelltAm;

  const KundeModel({
    required this.id,
    required this.firmenname,
    required this.ansprechpartner,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.telefon,
    required this.email,
    required this.erstelltAm,
  });

  factory KundeModel.fromJson(Map<String, dynamic> json) {
    return KundeModel(
      id: json['id'] as String,
      firmenname: json['firmenname'] as String? ?? '',
      ansprechpartner: json['ansprechpartner'] as String? ?? '',
      strasse: json['strasse'] as String? ?? '',
      plz: json['plz'] as String? ?? '',
      ort: json['ort'] as String? ?? '',
      telefon: json['telefon'] as String? ?? '',
      email: json['email'] as String? ?? '',
      erstelltAm: json['erstellt_am'] != null
          ? DateTime.parse(json['erstellt_am'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firmenname': firmenname,
      'ansprechpartner': ansprechpartner,
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
      'telefon': telefon,
      'email': email,
      'erstellt_am': erstelltAm.toIso8601String(),
    };
  }
}
