import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';

class BloodTypeSelector extends StatelessWidget {
  final String selectedBloodType;
  final Function(String) onBloodTypeSelected;
  
  const BloodTypeSelector({
    super.key,
    required this.selectedBloodType,
    required this.onBloodTypeSelected,
  });

  final List<String> bloodTypes = const [
    'A Rh+', 'A Rh-', 'B Rh+', 'B Rh-',
    'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kan Grubu Seçin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: bloodTypes.length,
          itemBuilder: (context, index) {
            final bloodType = bloodTypes[index];
            final isSelected = bloodType == selectedBloodType;
            
            return GestureDetector(
              onTap: () => onBloodTypeSelected(bloodType),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? AppTheme.primaryGradient
                      : AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected 
                      ? AppTheme.buttonShadow
                      : AppTheme.cardShadow,
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bloodtype,
                      color: isSelected 
                          ? Colors.white
                          : AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bloodType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white
                            : AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}