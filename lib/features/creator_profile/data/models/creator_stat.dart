import 'package:flutter/foundation.dart';

@immutable
class CreatorStat {
  final String id;
  final String label;
  final String value;

  const CreatorStat({
    this.id = '',
    required this.label,
    required this.value,
  });

  factory CreatorStat.fromJson(Map<String, dynamic> json) {
    return CreatorStat(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'value': value,
      };
}
