import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/meter_reading.dart';
import 'dashboard/home_screen.dart';
import 'readings/readings_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/login_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  final List<MeterReading> _readings = MeterReading.getInitialMockData();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addReading(MeterReading reading) {
    setState(() {
      _readings.insert(0, reading);
    });
  }

  void _editReading(MeterReading reading) {
    setState(() {
      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = reading;
      }
    });
  }

  void _deleteReading(String id) {
    setState(() {
      _readings.removeWhere((r) => r.id == id);
    });
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Монітор комунальних витрат';
      case 1:
        return 'Показники лічильників';
      case 2:
        return 'Профіль';
      default:
        return 'Монітор комунальних витрат';
    }
  }

  List<Widget> _buildAppBarActions() {
    switch (_currentIndex) {
      case 0:
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Сповіщення: термін передачі показників за вересень спливає 20-го числа!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  tooltip: 'Сповіщення',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Пошук показників активний'),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Пошук',
          ),
          const SizedBox(width: 8),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            onPressed: _handleLogout,
            tooltip: 'Вийти з акаунта',
          ),
          const SizedBox(width: 8),
        ];
      default:
        return [];
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          readings: _readings,
          onViewAllReadings: () => _onTabSelected(1),
        );
      case 1:
        return ReadingsScreen(
          readings: _readings,
          onAddReading: _addReading,
          onEditReading: _editReading,
          onDeleteReading: _deleteReading,
        );
      case 2:
        return ProfileScreen(
          onLogout: _handleLogout,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          // Desktop Layout with Sidebar Navigation Rail
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                // Custom Sidebar Navigation
                _buildDesktopSidebar(),
                // Main content with top Teal AppBar
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        color: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _appBarTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _buildAppBarActions(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildBody(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout with Top AppBar and Bottom Navigation Bar
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(
                _appBarTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0,
              actions: _buildAppBarActions(),
            ),
            body: _buildBody(),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabSelected,
                backgroundColor: Colors.white,
                elevation: 0,
                indicatorColor: const Color(0xFFD8EFEA),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: AppColors.primary),
                    label: 'Головна',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.speed_outlined),
                    selectedIcon: Icon(Icons.speed, color: AppColors.primary),
                    label: 'Показники',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: AppColors.primary),
                    label: 'Профіль',
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSidebarItem(
            index: 0,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Головна',
          ),
          const SizedBox(height: 16),
          _buildSidebarItem(
            index: 1,
            icon: Icons.speed_outlined,
            selectedIcon: Icons.speed,
            label: 'Показники',
          ),
          const SizedBox(height: 16),
          _buildSidebarItem(
            index: 2,
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Профіль',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD8EFEA) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
