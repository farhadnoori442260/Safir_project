import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استفاده از پس‌زمینه ملایم برای ست شدن با کل پنل سفیر
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // طراحی یک باکس شیک و سایه‌دار برای تصویر اصلی داشبورد سفیر
                Card(
                  elevation: 4,
                  shadowColor: const Color(0xFF145A41).withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      // تنظیم حداکثر عرض برای نمایش استاندارد در مانیتورهای بزرگ وب
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                        maxHeight: 500,
                      ),
                      child: Image.asset(
                        "assets/dashboard.webp",
                        fit: BoxFit.contain,
                        // مدیریت هوشمند خطا در صورتی که عکس هنوز در لود اسِت‌ها مشکل داشته باشد
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 500,
                            height: 350,
                            color: Colors.grey[100],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.dashboard_customize_outlined,
                                  size: 80,
                                  color: Color(0xFF145A41),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "به پنل مدیریت سفیر خوش آمدید",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF145A41),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // یک متن خوش‌آمدگویی ملایم در زیر تصویر
                Text(
                  "خوش آمدید! برای مدیریت بخش‌ها از منوی سمت راست استفاده کنید.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
