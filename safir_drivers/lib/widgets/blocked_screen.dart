import 'package:flutter/material.dart';
import 'package:safir_drivers/pages/auth/register_screen.dart'; // اصلاح نام پکیج سفیر

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // آیکون هشدار برای زیبایی و درک سریع‌تر وضعیت توسط راننده
                const Icon(
                  Icons.block_rounded,
                  color: Color(0xFFD32F2F),
                  size: 80,
                ),
                const SizedBox(height: 24),
                
                // متن فارسی اطلاع‌رسانی مسدودیت با فونت ایران‌یکان
                const Text(
                  "حساب کاربری شما توسط مدیریت مسدود شده است.\nلطفاً جهت کسب اطلاعات بیشتر با پشتیبانی سفیر در ارتباط باشید:\nfarhadnoori442@gmail.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 15,
                    color: Colors.blackDE,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                
                // دکمه تایید و بازگشت به صفحه ثبت‌نام
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F), // رنگ قرمز هشدار
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
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
                        fontFamily: 'IranYekan',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
