import 'package:flutter/material.dart';

class InformasiCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const InformasiCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory InformasiCategory.fromJson(Map<String, dynamic> json) {
    return InformasiCategory(
      id: '${json['id']}',
      name: json['name']?.toString() ?? '',
      color: _parseColor(json['color']?.toString()),
      icon: _mapIcon(json['icon']?.toString()),
    );
  }

  static Color _parseColor(String? raw) {
    if (raw == null || raw.isEmpty) return const Color(0xFF1565C0);
    final hex = raw.replaceFirst('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    return Color(int.tryParse(normalized, radix: 16) ?? 0xFF1565C0);
  }

  static IconData _mapIcon(String? raw) {
    switch (raw) {
      case 'policy':
      case 'policy_rounded':
        return Icons.policy_rounded;
      case 'event':
      case 'event_rounded':
        return Icons.event_rounded;
      case 'newspaper':
      case 'newspaper_rounded':
        return Icons.newspaper_rounded;
      case 'campaign':
      case 'campaign_rounded':
      default:
        return Icons.campaign_rounded;
    }
  }
}
