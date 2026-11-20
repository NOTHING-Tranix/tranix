import 'package:material_ui/material_ui.dart';

/// Explains why something is blocked ("Top up ₹50 to post") with a button to fix it.
class BlockingReasonCard extends StatelessWidget {
  const BlockingReasonCard({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.info_outline,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(color: scheme.onSecondaryContainer))),
            const SizedBox(width: 8),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
