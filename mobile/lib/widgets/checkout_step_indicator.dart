// lib/widgets/checkout_step_indicator.dart
import 'package:flutter/material.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Barre de progression
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;
              
              return Expanded(
                child: Column(
                  children: [
                    // Ligne entre les cercles
                    if (index > 0)
                      Container(
                        height: 2,
                        color: isActive ? const Color(0xFF8B0000) : Colors.grey[300],
                      ),
                    
                    // Cercle d'étape
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF8B0000) : Colors.grey[300],
                        shape: BoxShape.circle,
                        border: isCurrent ? Border.all(
                          color: Colors.white,
                          width: 3,
                        ) : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Labels des étapes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              final index = steps.indexOf(step);
              final isActive = index <= currentStep;
              
              return Expanded(
                child: Center(
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? const Color(0xFF8B0000) : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}