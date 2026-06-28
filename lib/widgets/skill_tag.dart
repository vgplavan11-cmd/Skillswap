import 'package:flutter/material.dart';

class SkillTag extends StatelessWidget {
  final String label;
  final String? level;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;

  const SkillTag({
    super.key,
    required this.label,
    this.level,
    this.onDeleted,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color tagColor = backgroundColor ?? _getLevelColor(level, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: tagColor.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: tagColor,
            ),
          ),
          if (level != null) ...[
            const SizedBox(width: 4.0),
            Text(
              '• $level',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: tagColor.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (onDeleted != null) ...[
            const SizedBox(width: 6.0),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 14.0,
                color: tagColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLevelColor(String? level, ThemeData theme) {
    if (level == null) return theme.colorScheme.primary;
    switch (level.toLowerCase()) {
      case 'expert':
        return const Color(0xFF10B981); // Emerald Green
      case 'advanced':
        return const Color(0xFF3B82F6); // Blue
      case 'intermediate':
        return const Color(0xFFF59E0B); // Amber
      case 'beginner':
      default:
        return const Color(0xFF64748B); // Slate Grey
    }
  }
}
