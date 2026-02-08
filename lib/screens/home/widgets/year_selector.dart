import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Виджет горизонтального выбора года
class YearSelector extends StatelessWidget {
  final List<int> years;
  final int? selectedYear;
  final ValueChanged<int> onYearSelected;

  const YearSelector({
    super.key,
    required this.years,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (years.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == selectedYear;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _YearChip(
              year: year,
              isSelected: isSelected,
              onTap: () => onYearSelected(year),
            ),
          );
        },
      ),
    );
  }
}

/// Чип для отображения года
class _YearChip extends StatelessWidget {
  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearChip({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.restoreBlue : AppColors.greyExtraLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.restoreBlue : AppColors.greyLight,
              width: 2,
            ),
          ),
          child: Text(
            year.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
