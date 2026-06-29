import 'package:flutter/material.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'edit_profile_screen.dart'; // ایمپورت صفحه‌ای که قبلاً با هم ساختیم

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            "پروفایل من",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            children: [
              // بخش آواتار و تصویر پروفایل
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: safirColor.withOpacity(0.1),
                        border: Border.all(color: safirColor.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.person, size: 70, color: safirColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // کارت نمایش اطلاعات کاربری (بدون فیلد متنی ضخیم قدیمی)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: safirColor),
                      title: const Text("نام و نام خانوادگی", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Text(
                        userName.isEmpty ? "نامشخص" : userName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.phone_android_outlined, color: safirColor),
                      title: const Text("شماره تلفن", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Text(
                        userPhone.isEmpty ? "نامشخص" : userPhone,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: safirColor),
                      title: const Text("آدرس ایمیل", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Text(
                        userEmail.isEmpty ? "نامشخص" : userEmail,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // دکمه هدایت به صفحه ویرایش لوکس مشخصات
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // رفتن به صفحه ویرایش و بازخوانی اطلاعات پس از بازگشت
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const EditProfileScreen()),
                    ).then((value) {
                      setState(() {}); // ری‌بلد صفحه برای نشان دادن دیتای جدید آپدیت شده در فایربیس
                    });
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: const Text(
                    "ویرایش اطلاعات کاربری",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
