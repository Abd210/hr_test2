import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/auth_provider.dart';

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
  late List<_NavItemData> _navItems;
  late List<AnimationController> _labelControllers;
  late List<Animation<double>> _labelAnimations;

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
      // e.g. Admin => 5 items
      _navItems = [
        _NavItemData(icon: Icons.dashboard, label: 'Dashboard'),     // index 0
        _NavItemData(icon: Icons.apartment, label: 'Organizations'), // index 1
        _NavItemData(icon: Icons.people, label: 'Users'),            // index 2
        _NavItemData(icon: Icons.assessment, label: 'Domains'),      // index 3
        _NavItemData(icon: Icons.list_alt, label: 'All Tests'),      // index 4
      ];
    } else {
      // org => fewer items: dashboard, users, domain
      _navItems = [
        _NavItemData(icon: Icons.dashboard, label: 'Dashboard'),  // index 0
        _NavItemData(icon: Icons.people, label: 'Users'),         // index 1
        _NavItemData(icon: Icons.assessment, label: 'Domains'),   // index 2
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
    _labelAnimations = _labelControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeIn);
    }).toList();
  }

  @override
  void didUpdateWidget(covariant PersistentNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex || widget.isAdmin != oldWidget.isAdmin) {
      // If user role changed or index changed
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
    for (var c in _labelControllers) {
      c.dispose();
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
          const SizedBox(height:24),
          _buildBrandLogo(),
          const SizedBox(height:24),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (ctx, i) {
                final isSelected = (i == _selectedIndex);
                return GestureDetector(
                  onTap: () => widget.onItemSelected?.call(i),
                  child: _NavItem(
                    data: _navItems[i],
                    isSelected: isSelected,
                    labelAnimation: _labelAnimations[i],
                  ),
                );
              },
            ),
          ),
          // we can do a logout item here if we want
          GestureDetector(
            onTap: () {
              // calling logout from here is optional,
              // or you can rely on the top bar logout
              final auth = Provider.of<AuthProvider>(context, listen:false);
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: _NavItem(
              data: _NavItemData(icon: Icons.exit_to_app, label: 'Logout'),
              isSelected: false,
              labelAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
          const SizedBox(height:24),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width:60, height:60,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(Icons.dashboard, color: Colors.white, size:24),
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
      duration: const Duration(milliseconds:300),
      margin: const EdgeInsets.symmetric(vertical:8, horizontal:12),
      padding: const EdgeInsets.symmetric(vertical:12, horizontal:8),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: accentColor, width:2)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds:300),
            width: isSelected ? 40 :30,
            height: isSelected ? 40:30,
            decoration: BoxDecoration(
              color: isSelected ? accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                data.icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: isSelected ?24:20
            ),
          ),
          const SizedBox(width:12),
          Text(
            data.label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize:16
            ),
          ),
        ],
      ),
    );
  }
}
