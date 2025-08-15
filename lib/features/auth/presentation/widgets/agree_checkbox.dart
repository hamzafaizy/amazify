import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreeToPolicies extends StatefulWidget {
  const AgreeToPolicies({
    super.key,
    this.initialValue = false,
    this.privacyUrl = 'https://example.com/privacy',
    this.termsUrl = 'https://example.com/terms',
    this.onChanged,
  });

  final bool initialValue;
  final String privacyUrl;
  final String termsUrl;
  final ValueChanged<bool>? onChanged;

  @override
  State<AgreeToPolicies> createState() => _AgreeToPoliciesState();
}

class _AgreeToPoliciesState extends State<AgreeToPolicies> {
  late bool _checked = widget.initialValue;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodySmall;
    final link = text?.copyWith(
      decoration: TextDecoration.underline,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox.adaptive(
          value: _checked,
          onChanged: (v) {
            setState(() => _checked = v ?? false);
            widget.onChanged?.call(_checked);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            children: [
              Text('I agree to the ', style: text),
              InkWell(
                onTap: () => _open(widget.privacyUrl),
                child: Text('Privacy Policy', style: link),
              ),
              Text(' and ', style: text),
              InkWell(
                onTap: () => _open(widget.termsUrl),
                child: Text('Terms of Use', style: link),
              ),
              Text('.', style: text),
            ],
          ),
        ),
      ],
    );
  }
}
