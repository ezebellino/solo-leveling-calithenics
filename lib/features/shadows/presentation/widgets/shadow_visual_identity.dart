import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';

class ShadowVisualIdentity {
  const ShadowVisualIdentity({
    required this.surfaceTop,
    required this.surfaceMid,
    required this.surfaceBottom,
    required this.frameColor,
    required this.glowColor,
    required this.accentColor,
    required this.smokeColor,
    required this.borderWidth,
    required this.glowOpacity,
  });

  final Color surfaceTop;
  final Color surfaceMid;
  final Color surfaceBottom;
  final Color frameColor;
  final Color glowColor;
  final Color accentColor;
  final Color smokeColor;
  final double borderWidth;
  final double glowOpacity;

  static ShadowVisualIdentity resolve({
    required ShadowEntity shadow,
    required SectionPalette fallback,
  }) {
    final primary = colorFromHex(shadow.borderTheme.primaryHex, fallback.primary);
    final secondary = colorFromHex(shadow.borderTheme.secondaryHex, fallback.secondary);
    final accent = colorFromHex(shadow.borderTheme.accentHex, fallback.highlight);

    final rarityBoost = switch (shadow.rarity) {
      ShadowRarity.rare => (1.2, 0.20),
      ShadowRarity.epic => (1.45, 0.26),
      ShadowRarity.legendary => (1.7, 0.32),
      ShadowRarity.mythic => (1.95, 0.38),
    };

    return ShadowVisualIdentity(
      surfaceTop: Color.lerp(const Color(0xFF08111A), primary, 0.22)!,
      surfaceMid: Color.lerp(const Color(0xFF071019), secondary, 0.18)!,
      surfaceBottom: Color.lerp(const Color(0xFF04070D), primary, 0.08)!,
      frameColor: Color.lerp(secondary, accent, 0.34)!,
      glowColor: Color.lerp(primary, secondary, 0.2)!,
      accentColor: accent,
      smokeColor: Color.lerp(primary, accent, 0.3)!,
      borderWidth: rarityBoost.$1,
      glowOpacity: rarityBoost.$2,
    );
  }

  static Color colorFromHex(String hex, Color fallback) {
    final sanitized = hex.replaceFirst('#', '');
    if (sanitized.length != 6 && sanitized.length != 8) {
      return fallback;
    }

    final normalized = sanitized.length == 6 ? 'FF$sanitized' : sanitized;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) {
      return fallback;
    }

    return Color(value);
  }
}
