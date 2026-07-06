import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:safir_admin/dashboard/dashboard.dart';
import 'package:safir_admin/pages/driver_page.dart';
import 'package:safir_admin/pages/trips_page.dart';
import 'package:safir_admin/pages/user_page.dart';
import 'package:safir_admin/utils/lang_helper.dart'; 
import 'package:safir_admin/main.dart';

class SideNavigationDrawer extends StatefulWidget {
  final Locale currentLocale; 
  const SideNavigationDrawer({super.key, required this.currentLocale});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  String currentRoute = 'dashboard';

  // 🎯 اصلاح اصولی بخش سوییچ: هر آیدی دقیقاً صفحه خودش را باز می‌کند
  Widget getActiveScreen() {
    switch (currentRoute) {
      case 'dashboard':
        return const Dashboard();
      case DriverPage.id:
        return const DriverPage();
      case UserPage.id:
        return const UserPage(); // 👈 مدیریت مسافران
      case TripsPage.id:
        return const TripsPage(); // 👈 سفرهای فعال
      default:
        return const Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarBg = Color(0xFF145A41); 
    const Color sideBarBg = Color(0xFF1E293B); 
    const Color activeItemBg = Color(0xFF334155); 
    const Color textStyleColor = Color(0xFF94A3B8); 

    // 🎯 اصلاح لیست منوها: عنوان‌ها و آیکون‌ها دقیقاً با مسیرها ست شده‌اند
    List<AdminMenuItem> getMenuItems() {
      return [
        AdminMenuItem(
          title: tr(context, 'home'), // اصلی صفحه
          route: 'dashboard',
          icon: CupertinoIcons.rectangle_grid_2x2_fill,
        ),
        AdminMenuItem(
          title: tr(context, 'manage_drivers'), // مدیریت رانندگان
          route: DriverPage.id,
          icon: CupertinoIcons.car_detailed,
        ),
        AdminMenuItem(
          title: tr(context, 'manage_users'), // مدیریت مسافران (اینجا اصلاح شد تا با UserPage.id همخوانی داشته باشد)
          route: UserPage.id,
          icon: CupertinoIcons.person_2_fill,
        ),
        AdminMenuItem(
          title: tr(context, 'active_rides'), // سفرهای فعال
          route: TripsPage.id,
          icon: CupertinoIcons.location_fill,
        ),
        AdminMenuItem(
          title: tr(context, 'total_earned'), // مجموع درآمد
          route: 'earnings',
          icon: CupertinoIcons.money_dollar,
        ),
      ];
    }

    return Scaffold(
      key: ValueKey(widget.currentLocale.toString()), 
      body: AdminScaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: appBarBg,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Safir Taxi",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<Locale>(
                value: widget.currentLocale, 
                dropdownColor: appBarBg,
                icon: const Icon(Icons.language, color: Colors.white),
                underline: const SizedBox(),
                selectedItemBuilder: (BuildContext context) {
                  return const [SizedBox(), SizedBox(), SizedBox()];
                },
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    MyApp.setLocale(context, newLocale);
                    setState(() {}); 
                  }
                },
                items: const [
                  DropdownMenuItem(value: Locale('fa', 'AF'), child: Text("دری", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: Locale('ps', 'AF'), child: Text("پشتو", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: Locale('en', 'US'), child: Text("English", style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
        sideBar: SideBar(
          backgroundColor: sideBarBg,
          textStyle: const TextStyle(color: textStyleColor, fontSize: 13),
          activeBackgroundColor: activeItemBg,
          activeTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          borderColor: const Color(0xFF334155),
          iconColor: textStyleColor,
          activeIconColor: Colors.white,
          items: getMenuItems(), 
          selectedRoute: currentRoute,
          onSelected: (itemSelected) {
            if (itemSelected.route != null) {
              setState(() {
                currentRoute = itemSelected.route!;
              });
            }
          },
        ),
        body: getActiveScreen(), 
      ),
    );
  }
}
