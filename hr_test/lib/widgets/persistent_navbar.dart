// lib/widgets/persistent_navbar.dart

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PersistentNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onItemSelected;

  const PersistentNavbar({
    Key? key,
    required this.currentIndex,
    this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(icon: Icons.dashboard, label: 'Dashboard'),   // 0
      _NavItemData(icon: Icons.domain, label: 'Orgs'),          // 1
      _NavItemData(icon: Icons.people, label: 'Users'),         // 2
      _NavItemData(icon: Icons.assessment, label: 'Tests'),     // 3
    ];

    return Container(
      width: 80,
      color: primaryDarkGreen,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildBrandLogo(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final isSelected = (index == currentIndex);
                return IconButton(
                  icon: Icon(
                    items[index].icon,
                    color: isSelected ? accentColor : backgroundLight,
                  ),
                  onPressed: () {
                    if (onItemSelected != null) {
                      onItemSelected!(index);
                    }
                  },
                  tooltip: items[index].label,
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              // e.g. implement logout or something else
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.dashboard, color: Colors.white),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  _NavItemData({required this.icon, required this.label});
}
