import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:safir_admin/dashboard/side_navigation_drawer.dart';
import 'package:safir_admin/firebase_options.dart';
import 'package:safir_admin/provider/driver_provider.dart';
import 'package:safir_admin/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // 👈 این دقیقاً همان متدی است که از هر جای برنامه صدا زده شود، کل برنامه را ریبيلد می‌کند
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('fa', 'AF'); // زبان پیش‌فرض

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color safirPrimaryGreen = Color(0xFF145A41);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Safir Admin Panel',
        theme: ThemeData(
          primaryColor: safirPrimaryGreen,
          colorScheme: ColorScheme.fromSeed(
            seedColor: safirPrimaryGreen,
            primary: safirPrimaryGreen,
          ),
          fontFamily: 'IranYekan',
          useMaterial3: true,
        ),
        locale: _locale, // 👈 زبان اصلی اپلیکیشن که با تغییر دکمه آپدیت می‌شود
        supportedLocales: const [
          Locale('fa', 'AF'),
          Locale('ps', 'AF'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 👈 فرستادن لکال فعلی به صورت مستقیم به دراور
        home: SideNavigationDrawer(currentLocale: _locale), 
      ),
    );
  }
}
