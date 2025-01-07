import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PersistentNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onItemSelected;
  final bool isAdmin;

  const PersistentNavbar({
    Key? key,
    required this.currentIndex,
    this.onItemSelected,
    this.isAdmin = true,
  }) : super(key: key);

  @override
  State<PersistentNavbar> createState() => _PersistentNavbarState();
}

class _PersistentNavbarState extends State<PersistentNavbar>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<AnimationController> _labelControllers;
  late List<Animation<double>> _labelAnimations;
  late List<_NavItemData> _navItems;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _initNavItems();
    _initAnimations();
    _labelControllers[_selectedIndex].forward();
  }

  void _initNavItems() {
    if (widget.isAdmin) {
      _navItems = [
        _NavItemData(icon: Icons.dashboard, label: 'Dashboard'),    // 0
        _NavItemData(icon: Icons.apartment, label: 'Organizations'),// 1
        _NavItemData(icon: Icons.people, label: 'Users'),           // 2
        _NavItemData(icon: Icons.assessment, label: 'Domains'),     // 3 (changed label)
      ];
    } else {
      _navItems = [
        _NavItemData(icon: Icons.dashboard, label: 'Dashboard'), // 0
        _NavItemData(icon: Icons.people, label: 'Users'),        // 1
        _NavItemData(icon: Icons.assessment, label: 'Domains'),  // 2 (changed label)
      ];
    }
  }

  void _initAnimations() {
    _labelControllers = List.generate(
      _navItems.length,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _labelAnimations = _labelControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      );
    }).toList();
  }

  @override
  void didUpdateWidget(covariant PersistentNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex || widget.isAdmin != oldWidget.isAdmin) {
      if (widget.isAdmin != oldWidget.isAdmin) {
        _initNavItems();
        for (var c in _labelControllers) {
          c.dispose();
        }
        _initAnimations();
        if (_selectedIndex >= _navItems.length) {
          _selectedIndex = 0;
          widget.onItemSelected?.call(_selectedIndex);
        }
        _labelControllers[_selectedIndex].forward();
      }
      if (widget.currentIndex != _selectedIndex) {
        _labelControllers[_selectedIndex].reverse();
        setState(() {
          _selectedIndex = widget.currentIndex;
        });
        _labelControllers[_selectedIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _labelControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
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
      child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
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
          Text(
            data.label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
