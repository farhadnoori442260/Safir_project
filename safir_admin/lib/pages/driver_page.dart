import 'package:flutter/material.dart';
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/widgets/drivers_data_list.dart';
// 👈 ایمپورت کردن هلپر زبان خودت برای استفاده از تابع tr
import 'package:safir_admin/utils/lang_helper.dart'; 

class DriverPage extends StatefulWidget {
  static const String id = "webPageDrivers";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1E293B); 
    final Color textColor = const Color(0xFF0F172A);

    // 👈 گرفتن زبان فعلی سیستم برای هماهنگی و رندر آنی
    String langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      // 👈 کلید جادویی برای اینکه صفحه با تغییر زبان درجا بازسازی شود
      key: ValueKey(langCode), 
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
                  // 👈 خواندن خودکار عنوان از دیتابیس کلمات شما
                  tr(context, 'manage_drivers'), 
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor, 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 👈 بدون هیچ شرطی، کلمات جدول را مستقیم به کلیدهای دیتابیس وصل می‌کنیم
                      CommonMethods.header(1, tr(context, 'driver_name')),
                      CommonMethods.header(1, tr(context, 'car_details')),
                      CommonMethods.header(1, tr(context, 'phone_number')),
                      CommonMethods.header(1, tr(context, 'total_earnings')),
                      CommonMethods.header(1, tr(context, 'account_status')),
                      CommonMethods.header(1, tr(context, 'more_details')),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const DriversDataList(), 
            ],
          ),
        ),
      ),
    );
  }
}
