// lib/features/shop/presentation/pages/add_new_address.dart
import 'package:amazify/features/shop/presentation/pages/addreses_profile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressPage extends StatefulWidget {
  const AddNewAddressPage({super.key});

  @override
  State<AddNewAddressPage> createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _postal = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _street.dispose();
    _postal.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState?.validate() ?? false) {
      Navigator.pop(
        context,
        Address(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          street: _street.text.trim(),
          postalCode: _postal.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          country: _country.text.trim(),
        ),
      );
    }
  }

  InputDecoration _dec(IconData icon, String label) => InputDecoration(
    prefixIcon: Icon(icon),
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          "Add new address",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: _dec(Iconsax.user, "Name"),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Required" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: _dec(Iconsax.call, "Phone number"),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().length < 7)
                  ? "Enter valid phone"
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _street,
                    decoration: _dec(Iconsax.location, "Street"),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postal,
                    decoration: _dec(Iconsax.tag, "Postal code"),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _city,
                    decoration: _dec(Iconsax.building, "City"),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _state,
                    decoration: _dec(Iconsax.map, "State"),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _country,
              decoration: _dec(Iconsax.flag, "Country"),
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Required" : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Iconsax.save_2),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
