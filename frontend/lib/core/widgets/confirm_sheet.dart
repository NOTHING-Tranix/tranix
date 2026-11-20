import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'primary_button.dart';

/// Confirmation before anything that costs money or can't be undone (ui-guidelines). Returns true on confirm.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final l = AppLocalizations.of(context);
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            PrimaryButton(label: confirmLabel ?? l.actionConfirm, onPressed: () => Navigator.pop(context, true)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.actionCancel)),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
