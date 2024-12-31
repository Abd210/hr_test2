// lib/widgets/persistent_navbar.dart

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PersistentNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onItemSelected;

  const PersistentNavbar({
    Key? key,
    required this.currentIndex,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<PersistentNavbar> createState() => _PersistentNavbarState();
}

class _PersistentNavbarState extends State<PersistentNavbar>
    with TickerProviderStateMixin { // Changed from SingleTickerProviderStateMixin
  late int _selectedIndex;

  // Animation Controllers for labels
  late List<AnimationController> _labelControllers;
  late List<Animation<double>> _labelAnimations;

  // Define navigation items
  final List<_NavItemData> _navItems = [
    _NavItemData(icon: Icons.dashboard, label: 'Dashboard'), // 0
    _NavItemData(icon: Icons.domain, label: 'Orgs'),        // 1
    _NavItemData(icon: Icons.people, label: 'Users'),       // 2
    _NavItemData(icon: Icons.assessment, label: 'Tests'),   // 3
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;

    // Initialize animation controllers for labels
    _labelControllers = List.generate(
      _navItems.length,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _labelAnimations = _labelControllers
        .map(
          (controller) => CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    )
        .toList();

    // Start animation for the initially selected index
    _labelControllers[_selectedIndex].forward();
  }

  @override
  void didUpdateWidget(covariant PersistentNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex) {
      // Reverse the previous label animation
      _labelControllers[_selectedIndex].reverse();

      // Update the selected index
      setState(() {
        _selectedIndex = widget.currentIndex;
      });

      // Forward the new label animation
      _labelControllers[_selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _labelControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Increased width to accommodate labels
      color: primaryDarkGreen,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildBrandLogo(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (ctx, index) {
                final isSelected = (index == _selectedIndex);
                return GestureDetector(
                  onTap: () {
                    if (widget.onItemSelected != null) {
                      widget.onItemSelected!(index);
                    }
                  },
                  child: _NavItem(
                    data: _navItems[index],
                    isSelected: isSelected,
                    labelAnimation: _labelAnimations[index],
                  ),
                );
              },
            ),
          ),
          // Logout Button with Animation
          GestureDetector(
            onTap: () {
              // Implement logout functionality here
              // For example:
              // Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigator.pushReplacementNamed(context, '/login');
            },
            child: _NavItem(
              data: _NavItemData(icon: Icons.exit_to_app, label: 'Logout'),
              isSelected: false,
              labelAnimation: const AlwaysStoppedAnimation(0.0),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(Icons.dashboard, color: Colors.white, size: 24), // Fixed size
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  _NavItemData({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final Animation<double> labelAnimation;

  const _NavItem({
    Key? key,
    required this.data,
    required this.isSelected,
    required this.labelAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the duration and curve for icon scaling
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: accentColor, width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 40 : 30,
            height: isSelected ? 40 : 30,
            decoration: BoxDecoration(
              color: isSelected ? accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: isSelected ? 24 : 20,
            ),
          ),
          const SizedBox(width: 12),
          // Animated label
          FadeTransition(
            opacity: labelAnimation,
            child: ScaleTransition(
              scale: labelAnimation,
              child: Text(
                data.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
