import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Color safirColor = const Color(0xFF145A41);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            "درباره سفیر",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // نماد یا آیکون شیک برنامه به جای لوگوی قدیمی
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: safirColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_taxi_rounded,
                  size: 80,
                  color: safirColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // نام برند شما
              Text(
                "سامانه هوشمند سفیر",
                style: TextStyle(
                  color: safirColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "نسخه 1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              
              // توضیحات پلتفرم
              const Text(
                "سفیر یک پلتفرم هوشمند حمل و نقل و خدمات شهری در افغانستان است که با هدف ارائه‌ی سفرهای سریع، امن و مقرون‌به‌صرفه طراحی گردیده است.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              const Divider(thickness: 0.8),
              const SizedBox(height: 20),
              
              // بخش پشتیبانی و گزارشات
              Text(
                "پشتیبانی و گزارش مشکلات",
                style: TextStyle(
                  color: safirColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // کارت اطلاعات تماس سفارشی شما
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: Colors.grey),
                      title: Text("ایمیل پشتیبانی"),
                      trailing: Text(
                        "support@safir.af",
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black70),
                      ),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: Colors.grey),
                      title: Text("ارتباط با مدیریت"),
                      trailing: Text(
                        "info@safir.af",
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
