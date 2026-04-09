import 'package:flutter/material.dart';
import '../../domain/entities/intake.dart';

class IntakeCard extends StatelessWidget {
  final Intake intake;
  final VoidCallback? onTaken;
  final VoidCallback? onSkipped;
  final VoidCallback? onTap;

  const IntakeCard({
    super.key,
    required this.intake,
    this.onTaken,
    this.onSkipped,
    this.onTap,
  });

  bool get _done => intake.status.toUpperCase() == 'TAKEN';
  bool get _skipped => intake.status.toUpperCase() == 'SKIPPED';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pill icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _done
                    ? const Color(0xFFEAF9F0)
                    : _skipped
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _formEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intake.medicationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intake.dosageLabel ?? _formatQuantity(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        intake.scheduledTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (intake.medicationForm != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            intake.medicationForm!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action buttons
            if (_done)
              _statusBadge('Pris', const Color(0xFF34C759), const Color(0xFFE8FFF0))
            else if (_skipped)
              _statusBadge('Ignore', const Color(0xFFEF4444), const Color(0xFFFEE2E2))
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionBtn(
                    Icons.close_rounded,
                    const Color(0xFFEF4444),
                    onSkipped,
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    Icons.check_rounded,
                    const Color(0xFF34C759),
                    onTaken,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _formatQuantity() {
    if (intake.quantity == null) return intake.unit ?? '';
    final q = intake.quantity!;
    final value = q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toString();
    return '$value${intake.unit != null ? ' ${intake.unit}' : ''}';
  }

  String get _formEmoji {
    final form = (intake.medicationForm ?? '').toLowerCase();
    if (form.contains('comprime') || form.contains('tablet')) return '💊';
    if (form.contains('gelule') || form.contains('capsule')) return '💊';
    if (form.contains('sirop') || form.contains('solution') || form.contains('buvable')) return '🧴';
    if (form.contains('injection') || form.contains('injectable')) return '💉';
    if (form.contains('creme') || form.contains('pommade') || form.contains('gel')) return '🧴';
    if (form.contains('collyre') || form.contains('goutte')) return '💧';
    if (form.contains('inhal') || form.contains('spray')) return '🌬️';
    if (form.contains('patch') || form.contains('timbre')) return '🩹';
    if (form.contains('suppo')) return '💊';
    return '💊';
  }
}
