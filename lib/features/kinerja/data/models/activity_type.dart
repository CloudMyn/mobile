import 'package:flutter/material.dart';

class ActivityType {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const ActivityType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final id = json['id']?.toString() ?? '';

    IconData getIcon(String n) {
      final lowercaseName = n.toLowerCase();
      if (lowercaseName.contains('rapat') || lowercaseName.contains('koordinasi') || lowercaseName.contains('musyawarah')) {
        return Icons.groups_rounded;
      }
      if (lowercaseName.contains('bimtek') || lowercaseName.contains('pelatihan') || lowercaseName.contains('diklat') || lowercaseName.contains('workshop') || lowercaseName.contains('seminar')) {
        return Icons.school_rounded;
      }
      if (lowercaseName.contains('pelayanan') || lowercaseName.contains('sosial') || lowercaseName.contains('kemasyarakatan')) {
        return Icons.handshake_rounded;
      }
      if (lowercaseName.contains('apel') || lowercaseName.contains('upacara') || lowercaseName.contains('piket')) {
        return Icons.assignment_rounded;
      }
      return Icons.work_history_rounded;
    }

    return ActivityType(
      id: id,
      name: name,
      description: json['description']?.toString() ?? 'Kegiatan $name',
      icon: getIcon(name),
    );
  }
}
