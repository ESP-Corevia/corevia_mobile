import 'package:flutter/material.dart';

import '../assets/color/color.dart';

// Widget personnalisé qui combine en-tête et gestion des couleurs
class HeaderToggle extends StatelessWidget {
  final Function onBackPressed;
  final String pageTitle;
  final List<String>? toggleItems;
  final String? selectedTab; // Nouveau paramètre pour l'onglet sélectionné
  final Function(String)? onToggleSelected;

  const HeaderToggle({
    required this.onBackPressed,
    required this.pageTitle,
    this.toggleItems,
    this.selectedTab,
    this.onToggleSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentToggleItems = toggleItems ?? [];
    return Container(
      color: Color(0xFFF5F5F5),
      child: 

      Container(
      padding: const EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 0),
      decoration: const BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Titre et bouton retour
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => onBackPressed(),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  pageTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            // Toggle Items
            Row(
              children: currentToggleItems.map((item) {
                return Expanded(
                  child: _buildToggleButton(item),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildToggleButton(String text) {
    bool isSelected = selectedTab == text;
    return GestureDetector(
      onTap: () {
        if (onToggleSelected != null) {
          onToggleSelected!(text); // Appeler la fonction si elle est définie
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),

          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF34C759) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}