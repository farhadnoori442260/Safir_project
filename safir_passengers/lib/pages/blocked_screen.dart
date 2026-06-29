import 'package:flutter/material.dart';
import 'package:uber_users_app/authentication/register_screen.dart'; // هماهنگ با سیستم ثبت‌نام شما

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  final Color safirColor = const Color(0xFF145A41);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // آیکون هشدار و مسدودی محترمانه و شیک
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      size: 70,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // عنوان پیام
                  Text(
                    "حساب کاربری مسدود شده است",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // متن توضیح زنده و بومی‌سازی شده
                  const Text(
                    "دسترسی شما به سامانه سفیر موقتاً توسط مدیریت تعلیق شده است.\nلطفاً جهت بررسی مجدد و رفع مسدودی با پشتیبانی سفیر در ارتباط باشید:\n\nsupport@safir.af",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 35),
                  
                  // دکمه تایید و خروج با استایل اختصاصی سفیر
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safirColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // انتقال کاربر به صفحه ثبت‌نام قدیمی اوبر شما پس از تایید
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "متوجه شدم",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
