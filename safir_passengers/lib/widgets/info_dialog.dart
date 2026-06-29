import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class InfoDialog extends StatelessWidget {
  final String? title, description; // متغیرها را final کردیم که استاندارد فلاتر رعایت شود

  const InfoDialog({
    super.key, 
    this.title, 
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    const Color safirColor = Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن متن اعلان‌ها برای زبان‌های دری و پشتو
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // لبه‌های گرد مدرن مطابق بقیه دیالوگ‌ها
        ),
        backgroundColor: Colors.white, // حذف پس‌زمینه خاکستری قدیمی
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // جمع‌وجور شدن ابعاد متناسب با متن
            children: [
              // آیکون اطلاعات/اعلان برای جذابیت بیشتر بصری
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: safirColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: safirColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // عنوان پیام/اعلان
              Text(
                title ?? 'توجه',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // متن توضیحات اعلان
              Text(
                description ?? 'برای اعمال تغییرات، برنامه نیاز به بازنشانی دارد.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // دکمه تایید و ری‌استارت برنامه با استایل سبز سفیر
              SizedBox(
                width: double.infinity, // تمام‌عرض شدن دکمه برای هماهنگی بیشتر
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Restart.restartApp(); // ری‌استارت آنلاین برنامه
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // لبه‌های گرد مدرن دکمه
                    ),
                  ),
                  child: const Text(
                    "فهمیدم (تایید)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
