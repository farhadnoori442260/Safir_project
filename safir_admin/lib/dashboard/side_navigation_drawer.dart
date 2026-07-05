import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:safir_admin/dashboard/dashboard.dart';
import 'package:safir_admin/pages/driver_page.dart';
import 'package:safir_admin/pages/trips_page.dart';
import 'package:safir_admin/pages/user_page.dart';
// ایمپورت کردن فایل کمکی زبان که در قدم اول ساختی
import 'package:safir_admin/utils/lang_helper.dart'; 
import 'package:safir_admin/main.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = const Dashboard();
  String currentRoute = 'dashboard';

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case 'dashboard':
        setState(() { chosenScreen = const Dashboard(); currentRoute = 'dashboard'; });
        break;
      case DriverPage.id:
        setState(() { chosenScreen = const DriverPage(); currentRoute = DriverPage.id; });
        break;
      case UserPage.id:
        setState(() { chosenScreen = const UserPage(); currentRoute = UserPage.id; });
        break;
      case TripsPage.id:
        setState(() { chosenScreen = const TripsPage(); currentRoute = TripsPage.id; });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color safirGreen = Color(0xFF145A41);
    const Color safirActiveGreen = Color(0xFF1E7E5C);

    // اینجا از تابع خودت (tr) برای ترجمه منوها استفاده کردیم
    final menuItems = [
      AdminMenuItem(
        title: tr(context, 'home'), // به جای کلمه ثابت، از تابع خودت استفاده شد
        route: 'dashboard',
        icon: CupertinoIcons.rectangle_grid_2x2_fill,
      ),
      AdminMenuItem(
        title: tr(context, 'reg_title'), 
        route: DriverPage.id,
        icon: CupertinoIcons.car_detailed,
      ),
      AdminMenuItem(
        title: tr(context, 'profile'), 
        route: UserPage.id,
        icon: CupertinoIcons.person_2_fill,
      ),
      AdminMenuItem(
        title: tr(context, 'active_rides'), 
        route: TripsPage.id,
        icon: CupertinoIcons.location_fill,
      ),
      AdminMenuItem(
        title: tr(context, 'total_earned'), 
        route: 'earnings',
        icon: CupertinoIcons.money_dollar,
      ),
    ];

    return Scaffold(
      body: AdminScaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: safirGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Safir Taxi",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
          ),
          actions: [
            // دکمه انتخاب زبان در بالای پنل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<Locale>(
                dropdownColor: safirGreen,
                icon: const Icon(Icons.language, color: Colors.white),
                underline: const SizedBox(),
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    MyApp.setLocale(context, newLocale); // تغییر زبان کل اپ
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
          backgroundColor: safirGreen,
          textStyle: const TextStyle(color: Colors.white, fontSize: 13),
          activeBackgroundColor: safirActiveGreen,
          activeTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: menuItems,
          selectedRoute: currentRoute,
          onSelected: (itemSelected) {
            sendAdminTo(itemSelected);
          },
        ),
        body: chosenScreen,
      ),
    );
  }
}
