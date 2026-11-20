import 'package:material_ui/material_ui.dart';

/// Profile completion circle (0–100) from `Me.profileCompletion`.
class CompletionRing extends StatelessWidget {
  const CompletionRing({super.key, required this.percent, this.size = 72});

  final int percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: p / 100,
            strokeWidth: 6,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Center(child: Text('$p%', style: Theme.of(context).textTheme.titleMedium)),
        ],
      ),
    );
  }
}
