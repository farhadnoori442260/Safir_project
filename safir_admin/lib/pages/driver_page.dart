import 'package:flutter/material.dart';
// اصلاح ایمپورت‌ها به نام پکیج جدید سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/widgets/drivers_data_list.dart';

class DriverPage extends StatefulWidget {
  static const String id = "webPageDrivers";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    // تعریف تم رنگی اختصاصی سفیر برای هدرها و متن‌ها
    final Color primaryColor = const Color(0xFF1E293B); // یک سرمه‌ای تیره و بسیار شیک مدرن
    final Color textColor = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // پس‌زمینه روشن و ملایم برای خسته نشدن چشم ادمین
      body: Padding(
        padding: const EdgeInsets.all(24), // پدینگ کمی بیشتر برای دلبازتر شدن صفحه
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "مدیریت رانندگان سفیر",
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
              // هدر جدول با استایل و رنگ‌بندی جدید سفیر
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor, // رنگ سرمه‌ای مدرن سفیر برای هدر جدول
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CommonMethods.header(1, "نام راننده"),
                      CommonMethods.header(1, "مشخصات خودرو"),
                      CommonMethods.header(1, "شماره تماس"),
                      CommonMethods.header(1, "کل درآمد"),
                      CommonMethods.header(1, "وضعیت حساب"),
                      CommonMethods.header(1, "جزئیات بیشتر"),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const DriversDataList(), // نمایش لیست داده‌های رانندگان
            ],
          ),
        ),
      ),
    );
  }
}
