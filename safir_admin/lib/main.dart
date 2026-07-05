import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// اصلاح کامل ایمپورت‌ها به پکیج رسمی سفیر ادمین
import 'package:safir_admin/dashboard/side_navigation_drawer.dart';
import 'package:safir_admin/firebase_options.dart';
import 'package:safir_admin/provider/driver_provider.dart';
import 'package:safir_admin/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // مقداردهی اولیه فایربیس با کانفیگ‌های پلتفرم مربوطه (وب/اندروید)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // رنگ سبز امضا و سازمانی سفیر
    const Color safirPrimaryGreen = Color(0xFF145A41);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DriverProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Safir Admin Panel', // تغییر عنوان به پنل مدیریت سفیر
        theme: ThemeData(
          // اعمال رنگ تم سازمانی جدید و حذف رنگ صورتی قبلی
          primaryColor: safirPrimaryGreen,
          colorScheme: ColorScheme.fromSeed(
            seedColor: safirPrimaryGreen,
            primary: safirPrimaryGreen,
          ),
          fontFamily: 'Vazir', // در صورت اضافه کردن فونت فارسی در pubspec
          useMaterial3: true,
        ),
        // راست‌چین کردن کل پنل برای نمایش کاملاً استاندارد زبان فارسی و پشتو
        locale: const Locale('fa', 'AF'), 
        supportedLocales: const [
          Locale('fa', 'AF'),
          Locale('ps', 'AF'),
        ],
        home: const SideNavigationDrawer(),
      ),
    );
  }
}
