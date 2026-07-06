import 'package:flutter/material.dart';
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/utils/lang_helper.dart'; // 👈 ایمپورت هلپر زبان

class TripsPage extends StatefulWidget {
  static const String id = "webPageTrips";
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
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
                  tr(context, 'active_rides'), // 👈 عنوان سه‌زبانه سفرها
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
                      // 👈 هدرهای جدول سفرها متصل به دیتابیس کلمات
                      CommonMethods.header(1, tr(context, 'trip_id')),
                      CommonMethods.header(1, tr(context, 'driver_name')),
                      CommonMethods.header(1, tr(context, 'user_name')),
                      CommonMethods.header(1, tr(context, 'origin')),
                      CommonMethods.header(1, tr(context, 'destination')),
                      CommonMethods.header(1, tr(context, 'fare')),
                      CommonMethods.header(1, tr(context, 'date')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // اینجا هم ویجت لیست سفرهای شما قرار می‌گیرد
            ],
          ),
        ),
      ),
    );
  }
}
