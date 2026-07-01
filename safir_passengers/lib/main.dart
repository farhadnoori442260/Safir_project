import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// ایمپورت‌های هماهنگ شده با ساختار پوشه‌بندی جدید گیت‌هاب شما
import 'globle/global_var.dart'; 
import 'authentication/register_screen.dart';
import 'pages/blocked_screen.dart';
import 'pages/safir_home_screen.dart'; // هدایت به هوم اسکرین اختصاصی و جدید سفیر

// پرووایدرها متناسب با پوشه‌بندی جدید شما (در صورت نیاز مسیر دقیق محلی بدهید)
import 'pages/app_info.dart'; 
import 'authentication/auth_provider.dart'; 

late Size mq;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishedKey;
  await Firebase.initializeApp();
  
  // درخواست دسترسی به موقعیت مکانی برای نقشه سفیر قبل از بالا آمدن اسکرین
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
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
        ChangeNotifierProvider(create: (_) => AppInfoClass()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider())
      ],
      child: MaterialApp(
        title: 'Safir Passengers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // تنظیم تم اولیه برنامه با رنگ سبز اختصاصی برند سفیر
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145A41)),
          useMaterial3: true,
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first, // بررسی وضعیت زنده لاگین فایربیس
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF145A41))),
            ),
          );
        }

        // اگر کاربر لاگین نکرده بود -> صفحه ثبت نام
        if (!snapshot.hasData || snapshot.data == null) {
          return const RegisterScreen();
        }

        // گام دوم: بررسی آنلاین وضعیت بلاک بودن کاربر از دیتابیس
        return FutureBuilder<bool>(
          future: authProvider.checkIfUserIsBlocked(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SafeArea(
                child: Scaffold(
                  body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF145A41)))),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const BlockedScreen();
            }
            
            // گام سوم: بررسی تکمیل بودن فیلدهای اطلاعاتی کاربر
            return FutureBuilder<bool>(
              future: authProvider.checkUserFieldsFilled(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(
                    child: Scaffold(
                      body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF145A41)))),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data == true) {
                  // در صورت تایید کامل، کاربر وارد صفحه اصلی سفیر می‌شود
                  return const SafirHomeScreen();
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
