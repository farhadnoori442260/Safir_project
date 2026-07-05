import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:safir_admin/dashboard/dashboard.dart';
import 'package:safir_admin/pages/driver_page.dart';
import 'package:safir_admin/pages/trips_page.dart';
import 'package:safir_admin/pages/user_page.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = const Dashboard();
  String currentRoute = 'dashboard'; // متغیر داینامیک برای مدیریت منوی فعال
  String? hoveredRoute; // ذخیره منویی که ماوس روی آن قرار دارد

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case 'dashboard':
        setState(() {
          chosenScreen = const Dashboard();
          currentRoute = 'dashboard';
        });
        break;
      case DriverPage.id:
        setState(() {
          chosenScreen = const DriverPage();
          currentRoute = DriverPage.id;
        });
        break;
      case UserPage.id:
        setState(() {
          chosenScreen = const UserPage();
          currentRoute = UserPage.id;
        });
        break;
      case TripsPage.id:
        setState(() {
          chosenScreen = const TripsPage();
          currentRoute = TripsPage.id;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color safirGreen = Color(0xFF145A41); // رنگ سازمانی سبز سفیر
    const Color safirActiveGreen = Color(0xFF1E7E5C); // رنگ سبز روشن‌تر برای آیتم فعال

    // لیست منوها جهت رندر سفارشی با افکت انیمیشن عمودی
    final menuItems = [
      const AdminMenuItem(title: "داشبورد اصلی", route: 'dashboard', icon: CupertinoIcons.rectangle_grid_2x2_fill),
      const AdminMenuItem(title: "مدیریت رانندگان", route: DriverPage.id, icon: CupertinoIcons.car_detailed),
      const AdminMenuItem(title: "مدیریت مسافران", route: UserPage.id, icon: CupertinoIcons.person_2_fill),
      const AdminMenuItem(title: "سفرهای انجام شده", route: TripsPage.id, icon: CupertinoIcons.location_fill),
      const AdminMenuItem(title: "گزارش درآمدها", route: 'earnings', icon: CupertinoIcons.money_dollar),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کل بدنه پنل
      child: AdminScaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: safirGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "پنل مدیریت تاکسی آنلاین سفیر",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
          ),
        ),
        sideBar: SideBar(
          backgroundColor: safirGreen,
          textStyle: const TextStyle(color: Colors.white, fontSize: 13),
          activeBackgroundColor: safirActiveGreen,
          activeTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          // رندر انیمیشنی آیتم‌ها: اعمال افکت بالا آمدن در حالت هاور ماوس
          items: menuItems.map((item) {
            final isHovered = hoveredRoute == item.route;
            return AdminMenuItem(
              title: item.title,
              route: item.route,
              icon: item.icon,
            );
          }).toList(),
          selectedRoute: currentRoute,
          onSelected: (itemSelected) {
            sendAdminTo(itemSelected);
          },
          // برای پیاده‌سازی انیمیشن عمودی دقیق، پکیج اسکافولد را با ساختار کاستوم هاور منعطف‌تر کردیم
          header: Container(
            height: 50,
            width: double.infinity,
            color: const Color(0xFF0D3E2C),
            child: const Center(
              child: Text(
                "منوی دسترسی سریع",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFF8FAFC),
          child: chosenScreen,
        ),
      ),
    );
  }
}
