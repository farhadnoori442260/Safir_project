import 'package:flutter/material.dart';
// اصلاح ایمپورت‌ها به نام پکیج جدید سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/widgets/users_data_list.dart';

class UserPage extends StatefulWidget {
  static const String id = "webPageUsers"; // اصلاح فرمت آیدی صفحه
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    // رنگ سازمانی و اختصاصی سبز سفیر
    final Color safirPrimaryColor = const Color(0xFF145A41); 
    final Color textColor = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // پس‌زمینه ملایم و یکدست
      body: Padding(
        padding: const EdgeInsets.all(24), // پدینگ هماهنگ با بقیه صفحات
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  "مدیریت مسافران سفیر", // فارسی‌سازی عنوان صفحه
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
              // هدر جدول کاربران با تم سبز سفیر
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: safirPrimaryColor, // رنگ سبز سفیر
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // استفاده مستقیم از متدهای استاتیک شده کامن متدز
                      CommonMethods.header(1, "نام مسافر"),
                      CommonMethods.header(1, "ایمیل"),
                      CommonMethods.header(1, "شماره تماس"),
                      CommonMethods.header(1, "وضعیت حساب / عملیات"),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const UsersDataList(), // نمایش لیست مسافران از فایربیس
            ],
          ),
        ),
      ),
    );
  }
}
