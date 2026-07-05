import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
// اصلاح ایمپورت‌ها به نام پکیج جدید سفیر ادمین
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

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      // اضافه شدن مسیر داشبورد برای برگشت به صفحه اصلی
      case 'dashboard':
        setState(() {
          chosenScreen = const Dashboard();
        });
        break;
      case DriverPage.id:
        setState(() {
          chosenScreen = DriverPage();
        });
        break;
      case UserPage.id:
        setState(() {
          chosenScreen = UserPage();
        });
        break;
      case TripsPage.id:
        setState(() {
          chosenScreen = TripsPage();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color.fromARGB(221, 39, 57, 99),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Safir Admin Panel", // بومی‌سازی عنوان پنل به سفیر
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: const Color.fromARGB(221, 39, 57, 99),
        textStyle: const TextStyle(color: Colors.white),
        activeBackgroundColor: const Color.fromARGB(221, 39, 57, 99),
        activeTextStyle: const TextStyle(color: Colors.white),
        items: const [
          AdminMenuItem(
            title: "Dashboard",
            route: 'dashboard',
            icon: CupertinoIcons.rectangle_grid_2x2_fill,
          ),
          AdminMenuItem(
            title: "Drivers",
            route: DriverPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Users",
            route: UserPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Earnings",
            route: TripsPage.id,
            icon: CupertinoIcons.money_dollar,
          ),
        ],
        selectedRoute: 'dashboard',
        onSelected: (itemSelected) {
          sendAdminTo(itemSelected);
        },
      ),
      body: chosenScreen,
    );
  }
}
