import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Presentation-only category accents (not stored on domain entities).
abstract final class FinanceCategoryColors {
  static Color forIconKey(String iconKey) {
    switch (iconKey) {
      case 'food':
        return const Color(0xFFE8501F);
      case 'transport':
        return const Color(0xFFFF7A2F);
      case 'shopping':
        return const Color(0xFFFFA51F);
      case 'bills':
        return const Color(0xFF3B82F6);
      case 'salary':
        return AppColors.ember;
      case 'income':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  static Color forCategoryId(String categoryId) {
    switch (categoryId) {
      case 'cat_food':
        return forIconKey('food');
      case 'cat_transport':
        return forIconKey('transport');
      case 'cat_shopping':
        return forIconKey('shopping');
      case 'cat_bills':
        return forIconKey('bills');
      case 'cat_salary':
        return forIconKey('salary');
      case 'cat_other_income':
        return forIconKey('income');
      default:
        return forIconKey('other');
    }
  }
}
