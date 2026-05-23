import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AddressForm extends StatelessWidget {
  const AddressForm({
    super.key,
    required this.fullNameController,
    required this.phoneController,
    required this.cityController,
    required this.addressLineController,
    required this.notesController,
  });

  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController addressLineController;
  final TextEditingController notesController;

  Map<String, dynamic> toAddressMap() => {
        'full_name': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'address_line': addressLineController.text.trim(),
      };

  String get notes => notesController.text.trim();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.isRtl ? 'عنوان الشحن' : 'Shipping address',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: fullNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.isRtl ? 'الاسم الكامل' : 'Full name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          validator: (value) => _requiredValidator(
            context,
            value,
            context.isRtl ? 'الاسم الكامل' : 'full name',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.isRtl ? 'رقم الهاتف' : 'Phone number',
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            final message = _requiredValidator(
              context,
              value,
              context.isRtl ? 'رقم الهاتف' : 'phone number',
            );
            if (message != null) return message;

            final digits = value!.replaceAll(RegExp(r'\D'), '');
            if (digits.length < 7) {
              return context.isRtl
                  ? 'أدخل رقم هاتف صحيح'
                  : 'Enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: cityController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.isRtl ? 'المدينة' : 'City',
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
          validator: (value) => _requiredValidator(
            context,
            value,
            context.isRtl ? 'المدينة' : 'city',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: addressLineController,
          textInputAction: TextInputAction.next,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.isRtl ? 'العنوان' : 'Address line',
            prefixIcon: const Icon(Icons.home_outlined),
            alignLabelWithHint: true,
          ),
          validator: (value) => _requiredValidator(
            context,
            value,
            context.isRtl ? 'العنوان' : 'address line',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: notesController,
          textInputAction: TextInputAction.done,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: context.isRtl ? 'ملاحظات اختيارية' : 'Optional notes',
            prefixIcon: const Icon(Icons.sticky_note_2_outlined),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(
    BuildContext context,
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return context.isRtl ? 'هذا الحقل مطلوب' : 'Enter your $fieldName';
    }
    return null;
  }
}
