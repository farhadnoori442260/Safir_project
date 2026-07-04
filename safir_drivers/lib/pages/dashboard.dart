import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/pages/earnings/earning_page.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/home/home_page.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/profile/profile_page.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/trips/trips_page.dart'; // اصلاح نام پکیج سفیر
import '../providers/dashboard_provider.dart'; // اصلاح مسیر پرووایدر

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    const Color brandColor = Color(0xFF145A41); // رنگ سبز برند سفیر

    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            const HomePage(),
            const EarningsPage(),
            const TripsPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), 
              activeIcon: Icon(Icons.home), 
              label: "خانه",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined), 
              activeIcon: Icon(Icons.credit_card), 
              label: "درآمدها",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined), 
              activeIcon: Icon(Icons.account_tree), 
              label: "سفرها",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person), 
              label: "پروفایل",
            ),
          ],
          currentIndex: dashboardProvider.selectedIndex,
          unselectedItemColor: Colors.grey.shade600,
          selectedItemColor: brandColor, // ست شدن رنگ سبز سفیر برای آیتم فعال
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontFamily: 'IranYekan', fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'IranYekan', fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 8,
          onTap: (index) {
            dashboardProvider.setIndex(index);
            controller!.index = index;
          },
        ),
      ),
    );
  }
}
