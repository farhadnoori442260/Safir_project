import 'package:flutter/material.dart';
// اصلاح ایمپورت‌ها به نام پکیج جدید سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/widgets/drivers_data_list.dart';

class DriverPage extends StatefulWidget {
  static const String id = "webPageDrivers"; // اصلاح فرمت آیدی صفحه
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "مدیریت رانندگان سفیر", // بومی‌سازی عنوان صفحه
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  // استفاده مستقیم از متدهای استاتیک شده کلس کامن متدز
                  CommonMethods.header(1, "نام راننده"),
                  CommonMethods.header(1, "مشخصات خودرو"),
                  CommonMethods.header(1, "شماره تماس"),
                  CommonMethods.header(1, "کل درآمد"),
                  CommonMethods.header(1, "وضعیت حساب"),
                  CommonMethods.header(1, "جزئیات بیشتر"),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const DriversDataList(), // نمایش لیست داده‌های رانندگان
            ],
          ),
        ),
      ),
    );
  }
}
