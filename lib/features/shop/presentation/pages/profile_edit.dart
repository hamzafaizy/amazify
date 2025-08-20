// lib/features/account/presentation/pages/profile.dart
import 'package:amazify/features/shop/presentation/widgets/clos_button.dart';
import 'package:amazify/features/shop/presentation/widgets/info_tile_prfl_eidt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import 'package:amazify/features/shop/presentation/widgets/custom_appbar.dart';

class ProfileEdit extends StatelessWidget {
  const ProfileEdit({super.key});

  void _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App bar
              CustomAppBar(
                showBackArrow: true,
                title: Text(
                  'Profile',
                  style: text.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),

              const SizedBox(height: 12),

              // Avatar + description
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Positioned(
                        top: 170,
                        left: 50,
                        right: 50,
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 0.05,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.shadow.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage(
                                    'assets/icons/app_icon3.png', // replace if you have a user photo
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    // TODO: pick image
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.edit,
                                      size: 16,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '“Shop smart. Live better.”',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Profile Information
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Profile Information',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ListTileArrowRight(
                title: 'Name',
                value: 'Hamza Faizi',
                onTap: () {
                  // TODO: Navigate to edit name
                },
              ),
              _ListTileArrowRight(
                title: 'Username',
                value: 'hamzafaizi',
                onTap: () {
                  // TODO: Navigate to edit username
                },
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // Personal Information
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Personal Information',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // 1) Copyable User ID
              InfoTile(
                title: 'User ID',
                value: '#AF-102938',
                icon: Iconsax.copy,
                iconTooltip: 'Copy',
                onIconPressed: () => _copy(context, '#AF-102938'),
              ),

              // 2) Email with mail action
              InfoTile(
                title: 'E-mail',
                value: 'hamza@example.com',
                icon: Iconsax.arrow_right_3,
                iconTooltip: 'Email',
                onIconPressed: () {
                  /* open composer / edit */
                },
              ),

              // 3) Phone with call action
              InfoTile(
                title: 'Phone Number',
                value: '+92 300 0000000',
                icon: Iconsax.arrow_right_3,
                iconTooltip: 'Call',
                onIconPressed: () {
                  /* dial or edit */
                },
              ),

              // 4) Gender (no action → static icon)
              InfoTile(
                title: 'Gender',
                value: 'Male',
                icon: Iconsax
                    .arrow_right_3, // no onIconPressed → rendered as plain Icon
              ),

              // 5) DOB with date picker
              InfoTile(
                title: 'Date of Birth',
                value: '01 Jan 2000',
                icon: Iconsax.arrow_right_3,
                iconTooltip: 'Change date',
                onIconPressed: () {
                  /* showDatePicker(...) */
                },
              ),

              const SizedBox(height: 8),
              const Divider(),

              const SizedBox(height: 8),
              Center(
                child: CloseAccountButton(
                  onConfirm: () {
                    // TODO: perform destructive action
                    // e.g., auth.signOut(); accountService.closeAccount();
                  },
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Helpers ----------

class _ListTileArrowRight extends StatelessWidget {
  const _ListTileArrowRight({
    required this.title,
    required this.value,
    this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              // Leftward arrow on the right side (as requested)
              Text(
                value,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Icon(Iconsax.arrow_right_3, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),

          Text(
            value,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Spacer(),
          Icon(Iconsax.copy, size: 18, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
