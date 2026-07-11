import 'package:flutter/material.dart';
import 'package:safir_drivers/methods/common_method.dart';
import 'package:safir_drivers/helpers/helper.dart';

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
  CommonMethods cMethods = CommonMethods();
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  @override
  Widget build(BuildContext context) {
    final String currencyUnit = tr(context, 'currency_unit');
    
    // جایگذاری داینامیک مبلغ در متن راهنما بدون به هم ریختن ساختار زبان
    final String paymentGuideMsg = tr(context, 'msg_payment_guide')
        .replaceAll('{amount}', widget.fareAmount)
        .replaceAll('{currency}', currencyUnit);

    return Directionality(
      textDirection: Directionality.of(context), // راست‌چین/چپ‌چین داینامیک براساس زبان فعال
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // آیکون بالای صفحه
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
              
              Text(
                tr(context, 'title_collect_cash'),
                style: const TextStyle(
                  fontFamily: 'IranYekan',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 24),
              
              // نمایش بزرگ مبلغ کرایه
              Text(
                "${widget.fareAmount} $currencyUnit",
                style: TextStyle(
                  color: safirColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // متن راهنمای راننده
              Text(
                paymentGuideMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // دکمه تایید دریافت پول
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    cMethods.turnOnLocationUpdatesForHomePage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safirColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    tr(context, 'btn_cash_received'),
                    style: const TextStyle(
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
