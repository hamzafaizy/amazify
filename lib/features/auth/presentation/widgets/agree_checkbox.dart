import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AgreeToPolicies extends StatefulWidget {
  const AgreeToPolicies({
    super.key,
    required this.initialValue,
    required this.privacyUrl,
    required this.termsUrl,
    required this.onChanged,
  });

  final bool initialValue;
  final String privacyUrl;
  final String termsUrl;
  final ValueChanged<bool> onChanged;

  @override
  State<AgreeToPolicies> createState() => _AgreeToPoliciesState();
}

class _AgreeToPoliciesState extends State<AgreeToPolicies> {
  late bool _checked = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall;

    return Row(
      children: [
        Checkbox(
          value: _checked,
          onChanged: (v) {
            setState(() => _checked = v ?? false);
            widget.onChanged(_checked);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: style?.copyWith(color: cs.onSurface),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms',
                  style: style?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      /* open terms url */
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: style?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      /* open privacy url */
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
