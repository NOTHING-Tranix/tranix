import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// 6-digit OTP field (one box per digit look, single input underneath so SMS autofill works). Calls
/// [onCompleted] when 6 digits are entered. Never log the value.
class OtpInput extends StatefulWidget {
  const OtpInput({super.key, required this.onCompleted, this.length = 6, this.errorText});

  final ValueChanged<String> onCompleted;
  final int length;
  final String? errorText;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofillHints: const [AutofillHints.oneTimeCode],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: widget.length,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 16, fontWeight: FontWeight.bold),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(counterText: '', errorText: widget.errorText),
      onChanged: (v) {
        if (v.length == widget.length) widget.onCompleted(v);
      },
    );
  }
}
