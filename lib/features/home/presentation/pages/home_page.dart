import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_bottom_nav_bar.dart';
import '../controllers/navigation_controller.dart';
import '../../../informasi/presentation/pages/informasi_page.dart';
// import 'tabs/activity_tab.dart'; // Disabled for now (Kinerja)
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import '../../../skp/presentation/pages/skp_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _navItems = [
    AppBottomNavBarItem(icon: Icons.home_rounded, label: 'Home'),
    AppBottomNavBarItem(icon: Icons.newspaper_rounded, label: 'Informasi'),
    AppBottomNavBarItem(icon: Icons.assignment_turned_in_rounded, label: 'SKP'),
    AppBottomNavBarItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  static final _tabs = <Widget>[
    const HomeTab(),
    const InformasiPage(),
    const SkpListPage(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
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
