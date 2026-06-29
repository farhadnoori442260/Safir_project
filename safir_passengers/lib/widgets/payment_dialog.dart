import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final String fareAmount;

  const PaymentDialog({
    super.key,
    required this.fareAmount,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  @override
  Widget build(BuildContext context) {
    const Color safirColor = Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن دیالوگ برای زبان‌های دری و پشتو
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // لبه‌های گرد مدرن مطابق دیزاین سفیر
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // آیکون رسید یا پول برای جذابیت بصری
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: safirColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: safirColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                "پرداخت نقدی به راننده",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Divider(height: 1, color: Colors.grey.withOpacity(0.25), thickness: 1.0),
              const SizedBox(height: 20),
              
              // نمایش کرایه به افغانی (AFN)
              Row(
                maincenter: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.fareAmount,
                    style: const TextStyle(
                      color: safirColor,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "افغانی", // تبدیل روپیه به پول رایج افغانستان
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // متن راهنما برای مسافر
              Text(
                "لطفاً مبلغ فوق (${widget.fareAmount} افغانی) را در پایان سفر به صورت نقدی به راننده پرداخت نمایید.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              
              // دکمه تایید و اتمام سفر با تم سبز سفیر
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, "paid"); // ارسال سیگنال پرداخت به نقشه اصلی
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "تایید و پایان سفر",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
