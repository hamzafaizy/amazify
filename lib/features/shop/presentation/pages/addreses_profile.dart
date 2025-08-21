// lib/features/shop/presentation/pages/orders.dart
import 'package:amazify/features/shop/presentation/pages/add_new_address_profile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddresesPage extends StatefulWidget {
  const AddresesPage({super.key});

  @override
  State<AddresesPage> createState() => _AddresesPageState();
}

class _AddresesPageState extends State<AddresesPage> {
  final List<Address> _items = [
    Address(
      name: 'Hamza Faizi',
      phone: '+92 300 0000000',
      street: 'Street 12, Model Town',
      postalCode: '54000',
      city: 'Lahore',
      state: 'Punjab',
      country: 'Pakistan',
    ),
    Address(
      name: 'Hamza Faizi',
      phone: '+92 333 1111111',
      street: 'House 24, Block A',
      postalCode: '75000',
      city: 'Karachi',
      state: 'Sindh',
      country: 'Pakistan',
    ),
  ];

  final Set<int> _selected = {};
  bool get _selectionMode => _selected.isNotEmpty;

  void _toggleSelect(int index) {
    setState(
      () => _selected.contains(index)
          ? _selected.remove(index)
          : _selected.add(index),
    );
  }

  void _clearSelection() => setState(_selected.clear);

  Future<bool> _onWillPop() async {
    if (_selectionMode) {
      _clearSelection();
      return false; // consume back to exit selection mode
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              if (_selectionMode) {
                _clearSelection();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _selectionMode ? "${_selected.length} selected" : "My Addresses",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_selectionMode)
              IconButton(
                tooltip: 'Clear',
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              ),
          ],
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push<Address>(
              context,
              MaterialPageRoute(builder: (_) => const AddNewAddressPage()),
            );
            if (result != null) {
              setState(() => _items.add(result));
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Address added')));
              }
            }
          },
          child: const Icon(Icons.add),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final a = _items[i];
            final selected = _selected.contains(i);
            return GestureDetector(
              onLongPress: () => _toggleSelect(i),
              onTap: () => _selectionMode ? _toggleSelect(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primaryContainer.withOpacity(.35)
                      : cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? cs.primary : cs.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: const Icon(Iconsax.box, size: 20),
                  ),
                  title: Text(
                    a.name,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.phone, style: text.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          a.fullAddress,
                          style: text.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selected
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('on'),
                            color: cs.primary,
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            key: const ValueKey('off'),
                            color: cs.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ---------- Simple model ---------- */
class Address {
  final String name, phone, street, postalCode, city, state, country;
  Address({
    required this.name,
    required this.phone,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.country,
  });

  String get fullAddress => "$street, $city, $state $postalCode, $country";
}
