import 'package:material_ui/material_ui.dart';

/// One large primary action per screen (≥ 48 dp, full width). Shows a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Text(label);
    return SizedBox(
      width: double.infinity,
      child: icon == null || loading
          ? FilledButton(onPressed: loading ? null : onPressed, child: child)
          : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child),
    );
  }
}

/// A button used as `ListTile.trailing`: capped width and scaled down so long Tamil/Hindi labels at large text
/// never take the whole tile (A-1005).
class TileAction extends StatelessWidget {
  const TileAction({super.key, required this.child, this.maxWidth = 140});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      );
}
