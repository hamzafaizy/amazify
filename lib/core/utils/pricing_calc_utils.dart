// lib/utils/pricing_calculator.dart
import 'dart:math';

/// Simple location model used for tax & shipping rules.
class Location {
  final String countryCode; // e.g. "PK", "US", "GB"
  final String? stateCode; // optional, e.g. "CA" for US-California
  final String? postalCode; // optional

  const Location({required this.countryCode, this.stateCode, this.postalCode});

  String key() => [
    countryCode.toUpperCase(),
    stateCode?.toUpperCase(),
  ].where((e) => e != null && e.isNotEmpty).join(':');
}

/// Delivery speed options (affects shipping pricing via multipliers).
enum DeliverySpeed { standard, express, priority }

/// All tunable knobs for pricing.
/// - taxRates: map of "COUNTRY[:STATE]" -> rate (0.0..1.0)
/// - shippingZones: list of rules matched in order; first match wins.
class PricingRules {
  final Map<String, double> taxRates;
  final List<ShippingRule> shippingZones;

  /// Free shipping thresholds by key "COUNTRY[:STATE]".
  final Map<String, double> freeShippingThresholds;

  /// Optional handling fee applied on every order (before tax).
  final double handlingFee;

  /// Optional cash-on-delivery fee.
  final double codFee;

  /// Whether product prices already include tax (VAT/GST inclusive).
  final bool pricesIncludeTax;

  const PricingRules({
    this.taxRates = const {},
    this.shippingZones = const [],
    this.freeShippingThresholds = const {},
    this.handlingFee = 0.0,
    this.codFee = 0.0,
    this.pricesIncludeTax = false,
  });

  /// Helper to read a rate by the most specific key first.
  double taxRateFor(Location loc) {
    final specific = taxRates[loc.key()];
    if (specific != null) return specific;
    return taxRates[loc.countryCode.toUpperCase()] ?? 0.0;
  }

  /// Helper to get free-shipping threshold (if any) for a location.
  double? freeShippingThresholdFor(Location loc) {
    return freeShippingThresholds[loc.key()] ??
        freeShippingThresholds[loc.countryCode.toUpperCase()];
  }

  /// Find first matching shipping rule for this location.
  ShippingRule? shippingRuleFor(Location loc) {
    for (final r in shippingZones) {
      if (r.matches(loc)) return r;
    }
    return null;
  }
}

/// One shipping rule, e.g. for a country/state.
/// Shipping = base + (perKg * weightKg) then multiplied by speedFactor.
class ShippingRule {
  final String countryCode; // required
  final String? stateCode; // optional
  final double base; // base shipping fee
  final double perKg; // price per kg
  final double expressFactor; // multiplier for express
  final double priorityFactor; // multiplier for priority

  const ShippingRule({
    required this.countryCode,
    this.stateCode,
    required this.base,
    required this.perKg,
    this.expressFactor = 1.5,
    this.priorityFactor = 2.0,
  });

  bool matches(Location loc) {
    final cc = loc.countryCode.toUpperCase();
    final sc = loc.stateCode?.toUpperCase();
    if (cc != countryCode.toUpperCase()) return false;
    if (stateCode == null) return true;
    return sc == stateCode!.toUpperCase();
  }

  double cost({
    required double weightKg,
    DeliverySpeed speed = DeliverySpeed.standard,
  }) {
    final raw = base + (max(0, weightKg) * perKg);
    switch (speed) {
      case DeliverySpeed.standard:
        return raw;
      case DeliverySpeed.express:
        return raw * expressFactor;
      case DeliverySpeed.priority:
        return raw * priorityFactor;
    }
  }
}

/// Input container to compute totals.
class PricingInput {
  final double productPrice; // subtotal of items (before tax/shipping)
  final double weightKg; // total cart weight for shipping
  final Location location; // destination
  final DeliverySpeed speed; // shipping speed
  final bool cashOnDelivery; // add COD fee if enabled
  final double? discountAmount; // fixed discount (applied before tax)
  final double? discountPercent; // e.g. 0.10 for 10% (applied before tax)
  final bool roundToTwoDecimals; // final rounding for currency display

  const PricingInput({
    required this.productPrice,
    required this.weightKg,
    required this.location,
    this.speed = DeliverySpeed.standard,
    this.cashOnDelivery = false,
    this.discountAmount,
    this.discountPercent,
    this.roundToTwoDecimals = true,
  });
}

/// Detailed result you can render in UI.
class PricingBreakdown {
  final double itemsSubtotal;
  final double discount;
  final double handlingFee;
  final double shipping;
  final double codFee;
  final double tax;
  final double total;

  const PricingBreakdown({
    required this.itemsSubtotal,
    required this.discount,
    required this.handlingFee,
    required this.shipping,
    required this.codFee,
    required this.tax,
    required this.total,
  });

  Map<String, double> toMap() => {
    'itemsSubtotal': itemsSubtotal,
    'discount': discount,
    'handlingFee': handlingFee,
    'shipping': shipping,
    'codFee': codFee,
    'tax': tax,
    'total': total,
  };
}

/// The main calculator.
class PricingCalculator {
  final PricingRules rules;

  const PricingCalculator(this.rules);

  /// Calculate shipping cost based on rules, weight, speed, and free threshold.
  double calculateShippingCost({
    required double itemsSubtotal,
    required double weightKg,
    required Location location,
    DeliverySpeed speed = DeliverySpeed.standard,
  }) {
    // Free shipping?
    final threshold = rules.freeShippingThresholdFor(location);
    if (threshold != null && itemsSubtotal >= threshold) return 0.0;

    final rule = rules.shippingRuleFor(location);
    if (rule == null) {
      return 0.0; // default to 0 if no rule (or handle as needed)
    }

    return _round(rule.cost(weightKg: weightKg, speed: speed));
  }

  /// Calculate discount total (fixed + percent). Capped at itemsSubtotal.
  double calculateDiscount({
    required double itemsSubtotal,
    double? discountAmount,
    double? discountPercent, // 0..1
  }) {
    final pct = (discountPercent ?? 0).clamp(0.0, 1.0);
    final fixed = (discountAmount ?? 0).clamp(0.0, double.infinity);
    final value = (itemsSubtotal * pct) + fixed;
    return _round(value.clamp(0.0, itemsSubtotal));
  }

  /// Calculate tax. If prices already include tax, we extract the portion.
  /// Otherwise, we apply tax on (items - discount + handling + shipping + codFee).
  double calculateTax({
    required double taxableBase,
    required Location location,
  }) {
    final rate = rules.taxRateFor(location).clamp(0.0, 1.0);
    return _round(taxableBase * rate);
  }

  /// Grand total with a complete breakdown.
  PricingBreakdown calculateTotalPrice(PricingInput input) {
    // 1) Items subtotal
    double itemsSubtotal = _round(input.productPrice);

    // 2) Discounts (before tax)
    final discount = calculateDiscount(
      itemsSubtotal: itemsSubtotal,
      discountAmount: input.discountAmount,
      discountPercent: input.discountPercent,
    );
    final afterDiscount = _round(itemsSubtotal - discount);

    // 3) Handling + shipping + COD (all pre-tax)
    final handling = _round(rules.handlingFee);
    final shipping = calculateShippingCost(
      itemsSubtotal: afterDiscount,
      weightKg: input.weightKg,
      location: input.location,
      speed: input.speed,
    );
    final codFee = _round(input.cashOnDelivery ? rules.codFee : 0.0);

    // 4) Tax
    double tax;
    if (rules.pricesIncludeTax) {
      // Extract tax only on the portion of items (assuming included VAT on items only).
      final rate = rules.taxRateFor(input.location).clamp(0.0, 1.0);
      final netItems = rate > 0 ? afterDiscount / (1 + rate) : afterDiscount;
      tax = _round(afterDiscount - netItems);
    } else {
      final taxableBase = _round(afterDiscount + handling + shipping + codFee);
      tax = calculateTax(taxableBase: taxableBase, location: input.location);
    }

    // 5) Total
    double total = _round(afterDiscount + handling + shipping + codFee + tax);

    if (input.roundToTwoDecimals) {
      itemsSubtotal = _round(itemsSubtotal);
      total = _round(total);
    }

    return PricingBreakdown(
      itemsSubtotal: itemsSubtotal,
      discount: discount,
      handlingFee: handling,
      shipping: shipping,
      codFee: codFee,
      tax: tax,
      total: total,
    );
  }

  // ───────────────────────── helpers ─────────────────────────

  double _round(double v) => (v * 100).roundToDouble() / 100.0;
}
