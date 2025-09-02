import 'package:flutter/material.dart';
import '../widgets/auth_card.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, this.closeModal});
  final VoidCallback? closeModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor.withOpacity(0.7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: AuthCard(onClose: closeModal)),
        ),
      ),
    );
  }
}
