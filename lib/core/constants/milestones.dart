import 'package:flutter/material.dart';
import 'sections.dart';

class MilestoneDef {
  final String id;
  final String label;
  final IconData icon;
  final bool Function(Map<String, Map<String, dynamic>> data) test;

  const MilestoneDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.test,
  });
}

bool _hasMedia(Map<String, dynamic> e) {
  if (e.isEmpty) return false;
  if (e['photo'] != null || e['avatar'] != null) return true;
  if ((e['media'] as List?)?.isNotEmpty ?? false) return true;
  if ((e['photos'] as List?)?.any((p) => p != null) ?? false) return true;
  if (e['months'] is List &&
      ((e['months'] as List).any((p) => p != null))) return true;
  if (e['months'] is Map &&
      (e['months'] as Map).values.any((a) => (a as List?)?.isNotEmpty ?? false)) {
    return true;
  }
  if ((e['items'] as List?)?.any((i) => i['photo'] != null) ?? false) return true;
  if ((e['memories'] as List?)?.any((m) =>
          (m['media'] as List?)?.isNotEmpty ?? false) ??
      false) return true;
  if ((e['members'] as List?)?.any((m) => m['photo'] != null) ?? false) {
    return true;
  }
  if ((e['notes'] as List?)?.any((n) => n['photo'] != null) ?? false) return true;
  if ((e['tree'] as Map?)?.values.any((n) => n != null && n['photo'] != null) ??
      false) return true;
  return false;
}

final List<MilestoneDef> milestones = [
  MilestoneDef(
    id: 'ilk',
    label: 'İlk Anı',
    icon: Icons.favorite,
    test: (d) => filledUnits(d) >= 1,
  ),
  MilestoneDef(
    id: 'aile',
    label: 'Aile Tamam',
    icon: Icons.people,
    test: (d) =>
        sectionFilled('aile', d) >= (sectionTotal('aile') * 0.7).floor(),
  ),
  MilestoneDef(
    id: 'hamile',
    label: 'Hamilelik',
    icon: Icons.child_care,
    test: (d) =>
        sectionFilled('beklerken', d) >=
        (sectionTotal('beklerken') * 0.5).floor(),
  ),
  MilestoneDef(
    id: 'dogum',
    label: 'Doğum Hikayesi',
    icon: Icons.star,
    test: (d) =>
        (d['dogum-hikaye']?['text']?.toString().trim().isNotEmpty ?? false),
  ),
  MilestoneDef(
    id: 'foto',
    label: 'İlk Fotoğraf',
    icon: Icons.camera_alt,
    test: (d) => d.values.any(_hasMedia),
  ),
  MilestoneDef(
    id: 'yarisi',
    label: '%50 Doldu',
    icon: Icons.emoji_events,
    test: (d) => filledUnits(d) >= (kTotalUnits * 0.5).floor(),
  ),
  MilestoneDef(
    id: 'tamam',
    label: 'Defter Tamam',
    icon: Icons.auto_awesome,
    test: (d) => filledUnits(d) >= (kTotalUnits * 0.9).floor(),
  ),
];
