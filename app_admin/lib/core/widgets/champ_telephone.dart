import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/gabon_phone_formatter.dart';
import 'brand.dart';

/// Champ de numéro gabonais (+241, 9 chiffres, groupes 3-2-2-2).
class ChampTelephone extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const ChampTelephone({super.key, required this.controller, this.errorText, this.onChanged});

  /// "077 12 34 56" -> "+241077123456"
  static String numeroComplet(TextEditingController controller) => '+241${controller.text.replaceAll(' ', '')}';

  static bool estComplet(TextEditingController controller) => controller.text.replaceAll(' ', '').length == 9;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, GabonPhoneFormatter()],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.ink),
      decoration: InputDecoration(
        hintText: '077 12 34 56',
        errorText: errorText,
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppTheme.line)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GabonFlag(),
              SizedBox(width: 8),
              Text(
                '+241',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
