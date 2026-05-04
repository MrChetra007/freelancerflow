import 'package:flutter/material.dart';

enum ExpenseCategory {
  software,
  hardware,
  travel,
  accommodation,
  meals,
  marketing,
  freelancer,
  office,
  other;

  String get label => name[0].toUpperCase() + name.substring(1);

  Color get color => switch (this) {
        ExpenseCategory.software => const Color(0xFF6366F1),
        ExpenseCategory.travel => const Color(0xFFF59E0B),
        ExpenseCategory.hardware => const Color(0xFF3B82F6),
        ExpenseCategory.accommodation => const Color(0xFFEC4899),
        ExpenseCategory.meals => const Color(0xFF10B981),
        ExpenseCategory.marketing => const Color(0xFF8B5CF6),
        ExpenseCategory.freelancer => const Color(0xFFF97316),
        ExpenseCategory.office => const Color(0xFF6B7280),
        ExpenseCategory.other => const Color(0xFF94A3B8),
      };

  IconData get icon => switch (this) {
        ExpenseCategory.software => Icons.computer_rounded,
        ExpenseCategory.hardware => Icons.memory_rounded,
        ExpenseCategory.travel => Icons.flight_rounded,
        ExpenseCategory.accommodation => Icons.hotel_rounded,
        ExpenseCategory.meals => Icons.restaurant_rounded,
        ExpenseCategory.marketing => Icons.campaign_rounded,
        ExpenseCategory.freelancer => Icons.people_rounded,
        ExpenseCategory.office => Icons.business_rounded,
        ExpenseCategory.other => Icons.category_rounded,
      };
}
