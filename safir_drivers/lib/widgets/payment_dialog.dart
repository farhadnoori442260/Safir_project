import 'package:flutter/material.dart';
import 'package:uber_drivers_app/methods/common_method.dart';

class PaymentDialog extends StatefulWidget {
  String fareAmount;

  PaymentDialog({
    super.key,
    required this.fareAmount,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods cMethods = CommonMethods();
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن محتوای دیالوگ پرداخت
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // لبه‌های گرد مدرن
        ),
        backgroundColor: Colors.white, // اصلاح پس‌زمینه به سفید یکدست سفیر
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // آیکون بالای صفحه برای جذابیت بصری دریافت پول
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: safirColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: safirColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                "دریافت نقدی کرایه",
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 24),
              
              // نمایش بزرگ مبلغ کرایه به افغانی
              Text(
                "${widget.fareAmount} افغانی",
                style: TextStyle(
                  color: safirColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // متن راهنمای راننده
              Text(
                "لطفاً مبلغ فوق ( ${widget.fareAmount} افغانی ) را به عنوان هزینه سفر از مسافر دریافت کنید.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // دکمه تایید دریافت پول با استایل سبز سفیر
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    cMethods.turnOnLocationUpdatesForHomePage();
                    //Restart.restartApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirColor, // تغییر رنگ به سبز سفیر
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "مبلغ را دریافت کردم",
                    style: TextStyle(
                      fontFamily: 'IranYekan',
                      fontSize: 16,
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
