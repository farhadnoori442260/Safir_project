import 'package:flutter/material.dart';
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/utils/lang_helper.dart'; // 👈 ایمپورت هلپر زبان

class UserPage extends StatefulWidget {
  static const String id = "webPageUsers";
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1E293B); 
    final Color textColor = const Color(0xFF0F172A);
    String langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      key: ValueKey(langCode), // 👈 کلید بازسازی آنی
      backgroundColor: const Color(0xFFF8FAFC), 
      body: Padding(
        padding: const EdgeInsets.all(24), 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  tr(context, 'manage_users'), // 👈 عنوان سه‌زبانه مسافران
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      // 👈 هدرهای جدول مسافران متصل به دیتابیس کلمات
                      CommonMethods.header(1, tr(context, 'user_name')),
                      CommonMethods.header(1, tr(context, 'email')),
                      CommonMethods.header(1, tr(context, 'phone_number')),
                      CommonMethods.header(1, tr(context, 'total_trips')),
                      CommonMethods.header(1, tr(context, 'account_status')),
                      CommonMethods.header(1, tr(context, 'more_details')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // اینجا هم ویجت لیست کاربران شما قرار می‌گیرد
            ],
          ),
        ),
      ),
    );
  }
}
