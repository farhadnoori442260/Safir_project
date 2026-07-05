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

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // زبان پیش‌فرض پنل مدیریت سفیر (دری)
  Locale _locale = const Locale('fa', 'AF'); 

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
          fontFamily: 'IranYekan', // اعمال فونت شیک ایران‌یکان به کل پنل
          useMaterial3: true,
        ),
        
        locale: _locale,
        supportedLocales: const [
          Locale('fa', 'AF'), // دری
          Locale('ps', 'AF'), // پشتو
          Locale('en', 'US'), // انگلیسی
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SideNavigationDrawer(),
      ),
    );
  }
}
