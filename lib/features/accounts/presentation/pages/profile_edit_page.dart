// lib/features/account/presentation/pages/profile.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, MissingPluginException;

import 'package:amazify/features/accounts/presentation/widgets/close_button.dart';
import 'package:amazify/features/accounts/presentation/widgets/info_tile_profile_edit.dart';
import 'package:amazify/core/widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Avatar picking
import 'package:image_picker/image_picker.dart';

// Launch email/dialer
import 'package:url_launcher/url_launcher.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  bool _busy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final u = _user;
    if (u == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(u.uid);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _toast('Copied to clipboard');
  }

  // ───────────────────────── Avatar: platform-aware picker ─────────────────────────
  Future<void> _changeAvatar() async {
    final u = _user;
    if (u == null) return;
    try {
      setState(() => _busy = true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final ref = FirebaseStorage.instance.ref().child(
        'users/${u.uid}/avatar.jpg',
      );

      if (kIsWeb) {
        // Web must upload bytes
        final bytes = await picked.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        // Mobile/macOS upload file
        await ref.putFile(File(picked.path));
      } else {
        _toast('Image picking is not supported on this platform.');
        return;
      }

      final url = await ref.getDownloadURL();
      await u.updatePhotoURL(url);
      await _userDoc?.set({'photoURL': url}, SetOptions(merge: true));

      _toast('Profile photo updated');
      if (!mounted) return;
      setState(() {}); // refresh avatar
    } on MissingPluginException {
      _toast(
        'Image picker plugin not installed for this target. Add platform packages and restart.',
      );
    } catch (e) {
      _toast('Failed to update photo: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────────────────── Profile Information (editable) ─────────────────────────
  Future<void> _editName() async {
    final u = _user;
    if (u == null) return;

    final controller = TextEditingController(text: u.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _TextEditDialog(
        title: 'Edit Name',
        controller: controller,
        hint: 'Your name',
      ),
    );
    if (name == null) return;

    try {
      setState(() => _busy = true);
      await u.updateDisplayName(name.trim());
      await _userDoc?.set({
        'displayName': name.trim(),
      }, SetOptions(merge: true));
      _toast('Name updated');
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _toast('Failed to update name: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editUsername(String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final username = await showDialog<String>(
      context: context,
      builder: (_) => _TextEditDialog(
        title: 'Edit Username',
        controller: controller,
        hint: 'username',
      ),
    );
    if (username == null) return;

    try {
      setState(() => _busy = true);
      await _userDoc?.set({
        'username': username.trim(),
      }, SetOptions(merge: true));
      _toast('Username updated');
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _toast('Failed to update username: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────────────────── Personal Information (copy-only, except DOB) ─────────────────────────
  Future<void> _editDob(DateTime? current) async {
    final now = DateTime.now();
    final initial = current ?? DateTime(now.year - 18, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your Date of Birth',
    );
    if (picked == null) return;

    try {
      setState(() => _busy = true);
      await _userDoc?.set({
        'dob': Timestamp.fromDate(picked),
      }, SetOptions(merge: true));
      _toast('Date of birth updated');
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _toast('Failed to update birthday: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // helpers for icon actions
  Future<void> _dial(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast('Cannot open dialer');
    }
  }

  Future<void> _composeEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast('Cannot open email app');
    }
  }

  // ───────────────────────── Close account ─────────────────────────
  Future<void> _closeAccount() async {
    final u = _user;
    if (u == null) return;

    final passCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This cannot be undone. Enter password to confirm.'),
            const SizedBox(height: 8),
            if ((u.email?.isNotEmpty ?? false))
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      setState(() => _busy = true);
      if ((u.email?.isNotEmpty ?? false) && passCtrl.text.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
          email: u.email!,
          password: passCtrl.text.trim(),
        );
        await u.reauthenticateWithCredential(cred);
      }
      try {
        await _userDoc?.delete();
      } catch (_) {}
      try {
        final folder = FirebaseStorage.instance.ref().child('users/${u.uid}');
        final items = await folder.listAll();
        for (final f in items.items) {
          await f.delete();
        }
      } catch (_) {}

      await u.delete();
      _toast('Account deleted');
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? e.code);
    } catch (e) {
      _toast('Failed to delete account: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────────────────── UI ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final u = _user;
    if (u == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(child: Text('Not signed in', style: text.titleMedium)),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDoc?.snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final displayName = (u.displayName ?? data['displayName']) ?? '';
        final username = data['username'] as String?;
        final phone = (data['phone'] as String?) ?? (u.phoneNumber ?? '');
        final gender = data['gender'] as String?;
        final dobTs = data['dob'] as Timestamp?;
        final dob = dobTs?.toDate();
        final photoURL =
            (u.photoURL ?? data['photoURL']) ?? 'assets/icons/app_icon3.png';

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Stack(
              children: [
                if (_busy) const LinearProgressIndicator(minHeight: 2),

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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

                      // Avatar + quote/bio
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
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
                                  child: Container(
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
                                      backgroundImage:
                                          photoURL.startsWith('http')
                                          ? NetworkImage(photoURL)
                                                as ImageProvider
                                          : const AssetImage(
                                              'assets/icons/app_icon3.png',
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _changeAvatar,
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

                      // Profile Information (editable)
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
                        value: displayName.isEmpty
                            ? '(tap to set)'
                            : displayName,
                        onTap: _editName,
                      ),
                      _ListTileArrowRight(
                        title: 'Username',
                        value: (username == null || username.isEmpty)
                            ? '(tap to set)'
                            : username,
                        onTap: () => _editUsername(username),
                      ),

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Personal Information (copy-only, except DOB)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Personal Information',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // 1) User ID — copy on tap
                      InfoTile(
                        title: 'User ID',
                        value: u.uid,
                        icon: Iconsax.copy,
                        iconTooltip: 'Copy',
                        onIconPressed: () => _copy(u.uid),
                        onTap: () => _copy(u.uid), // copy on tap
                      ),

                      // 2) Email — copy on tap; icon opens composer
                      InfoTile(
                        title: 'E-mail',
                        value: u.email ?? '(not set)',
                        icon: Iconsax.arrow_right_3,
                        iconTooltip: 'Email',
                        onIconPressed: () {
                          final e = u.email;
                          if (e != null && e.isNotEmpty) _composeEmail(e);
                        },
                        onTap: () {
                          final e = u.email ?? '';
                          if (e.isNotEmpty) _copy(e); // copy on tap
                        },
                      ),

                      // 3) Phone — copy on tap; icon dials (if present)
                      InfoTile(
                        title: 'Phone Number',
                        value: (phone.isEmpty) ? '(not set)' : phone,
                        icon: Iconsax.arrow_right_3,
                        iconTooltip: (phone.isEmpty) ? 'N/A' : 'Call',
                        onIconPressed: () {
                          if (phone.isNotEmpty) _dial(phone);
                        },
                        onTap: () {
                          if (phone.isNotEmpty) _copy(phone); // copy on tap
                        },
                      ),

                      // 4) Gender — copy on tap
                      InfoTile(
                        title: 'Gender',
                        value: (gender == null || gender.isEmpty)
                            ? '(not set)'
                            : gender,
                        icon: Iconsax.arrow_right_3,
                        onIconPressed: () {
                          final g = gender ?? '';
                          if (g.isNotEmpty) _copy(g);
                        },
                        onTap: () {
                          final g = gender ?? '';
                          if (g.isNotEmpty) _copy(g); // copy on tap
                        },
                      ),

                      // 5) DOB — EDITABLE (tap or icon opens calendar)
                      InfoTile(
                        title: 'Date of Birth',
                        value: dob == null ? '(tap to set)' : _fmtDate(dob),
                        icon: Iconsax.calendar_1,
                        iconTooltip: 'Change date',
                        onIconPressed: () => _editDob(dob),
                        onTap: () => _editDob(dob),
                      ),

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      Center(
                        child: CloseAccountButton(onConfirm: _closeAccount),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
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
              Text(
                value,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Iconsax.arrow_right_3, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextEditDialog extends StatelessWidget {
  const _TextEditDialog({
    required this.title,
    required this.controller,
    required this.hint,
  });

  final String title;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: hint),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
