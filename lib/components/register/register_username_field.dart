import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo `fan/` + username.
class RegisterUsernameField extends StatefulWidget {
  const RegisterUsernameField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<RegisterUsernameField> createState() => _RegisterUsernameFieldState();
}

class _RegisterUsernameFieldState extends State<RegisterUsernameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(RegisterUsernameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.inputBorder),
      ),
      child: SizedBox(
        height: 57,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              'fan/',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Expanded(
              child: TextField(
                key: const Key('register-username-input'),
                controller: _controller,
                onChanged: widget.onChanged,
                autocorrect: false,
                maxLength: 20,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Username',
                  hintStyle: TextStyle(color: colors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
