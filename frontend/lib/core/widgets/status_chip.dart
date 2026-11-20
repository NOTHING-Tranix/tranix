import 'package:material_ui/material_ui.dart';

import '../../shared/models/enums.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// Status as coloured chip + text, never colour alone (ui-guidelines "Status chips").
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.filled = false});

  factory StatusChip.load(BuildContext context, LoadStatus status) {
    final l = AppLocalizations.of(context);
    final c = context.statusColors;
    return switch (status) {
      LoadStatus.notAccepted => StatusChip(label: l.loadStatusNotAccepted, color: c.neutral),
      LoadStatus.accepted => StatusChip(label: l.loadStatusAccepted, color: c.info),
      LoadStatus.waitingForPickup => StatusChip(label: l.loadStatusWaitingForPickup, color: c.info),
      LoadStatus.amountNegotiation => StatusChip(label: l.loadStatusAmountNegotiation, color: c.warning),
      LoadStatus.locationReached => StatusChip(label: l.loadStatusLocationReached, color: c.info, filled: true),
      LoadStatus.pickedUp => StatusChip(label: l.loadStatusPickedUp, color: c.info, filled: true),
      LoadStatus.traveling => StatusChip(label: l.loadStatusTraveling, color: c.info, filled: true),
      LoadStatus.arrivedDestination =>
        StatusChip(label: l.loadStatusArrivedDestination, color: c.info, filled: true),
      LoadStatus.delivered => StatusChip(label: l.loadStatusDelivered, color: c.success),
      LoadStatus.cancelled => StatusChip(label: l.loadStatusCancelled, color: c.error),
      LoadStatus.unknown => StatusChip(label: l.statusUnknown, color: c.neutral),
    };
  }

  factory StatusChip.payment(BuildContext context, PaymentStatus status) {
    final l = AppLocalizations.of(context);
    final c = context.statusColors;
    return switch (status) {
      PaymentStatus.pending => StatusChip(label: l.paymentStatusPending, color: c.neutral),
      PaymentStatus.paid => StatusChip(label: l.paymentStatusPaid, color: c.info),
      PaymentStatus.confirmed => StatusChip(label: l.paymentStatusConfirmed, color: c.success),
      PaymentStatus.disputed => StatusChip(label: l.paymentStatusDisputed, color: c.error),
      PaymentStatus.unknown => StatusChip(label: l.statusUnknown, color: c.neutral),
    };
  }

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: filled ? Colors.white : color),
      ),
    );
  }
}
