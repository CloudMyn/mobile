import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_bottom_nav_bar.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import '../../../informasi/presentation/pages/informasi_page.dart';
import 'tabs/activity_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _navItems = [
    AppBottomNavBarItem(icon: Icons.home_rounded, label: 'Home'),
    AppBottomNavBarItem(icon: Icons.newspaper_rounded, label: 'Informasi'),
    AppBottomNavBarItem(icon: Icons.history_rounded, label: 'Kinerja'),
    AppBottomNavBarItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  static final _tabs = <Widget>[
    const HomeTab(),
    const InformasiPage(),
    const ActivityTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Register controllers if not already registered
    Get.put(HomeController(), permanent: true);
    final navController = Get.put(NavigationController());

    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: navController.currentIndex.value,
            children: _tabs,
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: navController.currentIndex.value,
          items: _navItems,
          onTap: (index) => navController.changeIndex(index),
        ),
      ),
    );
  }
}
