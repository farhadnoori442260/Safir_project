import 'package:flutter/material.dart';
// اصلاح ایمپورت‌ها به نام پکیج جدید سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/widgets/trips_data_list.dart';

class TripsPage extends StatefulWidget {
  static const String id = "webPageTrips"; // اصلاح فرمت آیدی صفحه

  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  Widget build(BuildContext context) {
    // تعریف رنگ سازمانی و اختصاصی سفیر
    final Color safirPrimaryColor = const Color(0xFF145A41); 
    final Color textColor = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // پس‌زمینه ملایم برای جلوه بیشتر جدول
      body: Padding(
        padding: const EdgeInsets.all(24), // پdینگ بهینه برای حالت وب پنل
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "مدیریت سفرهای سفیر", // فارسی‌سازی عنوان
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // هدر جدول با رنگ‌بندی جدید و اختصاصی سبز سفیر
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: safirPrimaryColor, // رنگ سبز سفیر برای هدر جدول
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // استفاده مستقیم از متدهای استاتیک شده
                      CommonMethods.header(2, "شناسه سفر"),
                      CommonMethods.header(1, "نام مسافر"),
                      CommonMethods.header(1, "نام راننده"),
                      CommonMethods.header(1, "مشخصات خودرو"),
                      CommonMethods.header(1, "زمان ثبت"),
                      CommonMethods.header(1, "هزینه (افغانی)"),
                      CommonMethods.header(1, "جزئیات بیشتر"),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              // نمایش لیست داده‌های سفرها
              const TripsDataList(),
            ],
          ),
        ),
      ),
    );
  }
}
