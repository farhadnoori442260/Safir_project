import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// اصلاح ایمپورت قدیمی اوبر به مسیر محلی جدید سفیر
import '../globle/global_var.dart';

class StripePaymentService {
  
  // ایجاد فاکتور یا توکن پرداخت (Payment Intent) در سرور استرایپ
  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = stripeSecretAPIKey;
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      print('اطلاعات فاکتور استرایپ: ${response.body}');
      return jsonDecode(response.body);
    } catch (err) {
      print('خطا در ایجاد فاکتور پرداخت: ${err.toString()}');
      return null;
    }
  }

  // نمایش صفحه یا شیت رسمی پرداخت کارت بانکی به مسافر
  Future<void> displayPaymentSheet(
      BuildContext context, String clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("پرداخت شما با موفقیت انجام شد.", textDirection: TextDirection.rtl)),
      );
    } on StripeException catch (e) {
      print('خطای استرایپ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("پرداخت توسط کاربر لغو شد.", textDirection: TextDirection.rtl)),
      );
    } catch (e) {
      print("خطا در نمایش شیت پرداخت: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("عملیات پرداخت با خطا مواجه شد.", textDirection: TextDirection.rtl)),
      );
    }
  }

  // مقداردهی اولیه و تنظیمات صفحه پرداخت استرایپ
  Future<void> initPaymentSheet(
      BuildContext context, String clientSecret, String currency) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          googlePay: PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: currency,
            merchantCountryCode: "AF", // تغییر کد کشور به افغانستان متناسب با موقعیت سفیر
          ),
          merchantDisplayName: 'Safir Passengers', // نمایش نام برند اختصاصی شما در درگاه
        ),
      );
    } catch (e) {
      print("خطا در آماده‌سازی درگاه پرداخت: $e");
    }
  }
}
