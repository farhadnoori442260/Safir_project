import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String messageText; // متغیر را final کردیم که استانداردتر باشد

  const LoadingDialog({
    super.key,
    required this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    const Color safirColor = Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن متن بارگذاری برای زبان‌های دری و پشتو
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // لبه‌های گردتر و مدرن‌تر
        ),
        backgroundColor: Colors.white, // حذف رنگ خاکستری زشت پیش‌فرض
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min, // جمع‌وجور شدن ابعاد پنجره متناسب با متن
            children: [
              const SizedBox(width: 8),
              // انیمیشن چرخشی مدرن با رنگ برند سفیر
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3, // ظریف‌تر کردن خط چرخش
                  valueColor: AlwaysStoppedAnimation<Color>(safirColor),
                ),
              ),
              const SizedBox(width: 20),
              // متن پیام با فونت خوانا و رنگ ملایم مدرن
              Expanded(
                child: Text(
                  messageText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
