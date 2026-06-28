import 'package:flutter/material.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/pages/about_page.dart';
import 'package:uber_users_app/pages/profile_page.dart';
import 'package:uber_users_app/pages/trips_history_page.dart';
import 'package:uber_users_app/widgets/sign_out_dialog.dart';
// ایمپورت صفحه تنظیماتی که خودت طراحی کردی (آدرس را در صورت نیاز اصلاح کن)
import 'package:uber_users_app/pages/settings_screen.dart'; 

class CustomDrawer extends StatelessWidget {
  final String userName;
  final AuthenticationProvider authProvider; 

  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.authProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color safirColor = Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کل منوی کناری برای زبان دری/پشتو
      child: Drawer(
        backgroundColor: const Color(0xFFF9F9F9), // پس‌زمینه لایت و تمیز مطابق دیزاین جدیدت
        child: Column(
          children: [
            // ۱. سربرگ اختصاصی و مدرن سفیر (پروفایل کاربر)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 25, right: 20, left: 20),
              decoration: const BoxDecoration(
                color: safirColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/avatarman.png"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : "مسافر سفیر",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                userEmail,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ۲. لیست گزینه‌ها با کادربندی خاص و منظم (Card UI)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                children: [
                  _buildDrawerCard(
                    icon: Icons.account_box_outlined,
                    title: "حساب کاربری",
                    iconColor: safirColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.history_rounded,
                    title: "تاریخچه سفرها",
                    iconColor: safirColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TripsHistoryPage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.settings_outlined,
                    title: "تنظیمات برنامه",
                    iconColor: safirColor,
                    onTap: () {
                      // اتصال مستقیم به صفحه تنظیمات چندزبانه‌ای که ساختی
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentLanguage: 'دری',
                            onLanguageChanged: (lang) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.privacy_tip_outlined,
                    title: "حریم خصوصی و امنیت",
                    iconColor: Colors.grey.shade700,
                    onTap: () {},
                  ),
                  _buildDrawerCard(
                    icon: Icons.help_outline_rounded,
                    title: "مرکز کمک و پشتیبانی",
                    iconColor: Colors.grey.shade700,
                    onTap: () {},
                  ),
                  _buildDrawerCard(
                    icon: Icons.info_outline_rounded,
                    title: "درباره سفir",
                    iconColor: Colors.grey.shade700,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                    },
                  ),
                  _buildDrawerCard(
                    icon: Icons.star_rate_outlined,
                    title: "امتیاز به اپلیکیشن",
                    iconColor: Colors.amber,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ۳. بخش خروج از حساب در پایین منو
            Padding(
              padding: const EdgeInsets.all(15),
              child: _buildDrawerCard(
                icon: Icons.logout_rounded,
                title: "خروج از حساب کاربری",
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                onTap: () async {
                  Navigator.pop(context); // بستن دراور
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SignOutDialog(
                        title: 'خروج',
                        description: 'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
                        onSignOut: () async {
                          await authProvider.signOut(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت اختصاصی برای ساخت دکمه‌های کادردار و شیک منو
  Widget _buildDrawerCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)), // ایجاد همان خط دور اپشن‌ها که دوست داشتی
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 18), // فلش راهنما به سمت چپ برای RTL
        onTap: onTap,
      ),
    );
  }
}
