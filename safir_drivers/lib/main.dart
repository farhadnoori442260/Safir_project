import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:safir_drivers/pages/auth/register_screen.dart';
import 'package:safir_drivers/pages/dashboard.dart';
import 'package:safir_drivers/providers/authentication_provider.dart';
import 'package:safir_drivers/providers/dashboard_provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart';
import 'package:safir_drivers/providers/trip_provider.dart';
import 'package:safir_drivers/widgets/blocked_screen.dart';
import 'package:safir_drivers/helpers/helper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const Color safirColor = Color(0xFF145A41); // رنگ سازمانی سبز سفیر

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // درخواست مجوزهای موقعیت مکانی و اعلان‌ها
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  await Permission.notification.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppLanguageProvider(), // پرووایدر زبان پروژه سفیر
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TripProvider(),
        ),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, appLanguage, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Safir Drivers',
            debugShowCheckedModeBanner: false,
            locale: appLanguage.appLocal, // زبان فعال برنامه
            supportedLocales: const [
              Locale('fa', 'AF'), // دری / فارسی
              Locale('ps', 'AF'), // پشتو
              Locale('en', 'US'), // انگلیسی
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: safirColor),
              fontFamily: 'IranYekan',
              useMaterial3: true,
            ),
            home: const AuthCheck(),
          );
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: safirColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const RegisterScreen();
        }

        return FutureBuilder<bool>(
          future: authProvider.checkIfDriverIsBlocked(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: CircularProgressIndicator(
                    color: safirColor,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const BlockedScreen();
            }

            return FutureBuilder<bool>(
              future: authProvider.checkDriverFieldsFilled(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: CircularProgressIndicator(
                        color: safirColor,
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return const Dashboard();
                } else {
                  return const RegisterScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
