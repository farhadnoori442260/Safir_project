import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/methods/common_method.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/pages/dashboard.dart';       // اصلاح نام پکیج
import 'package:safir_drivers/pages/driverRegistration/driver_registration.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/providers/auth_provider.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/widgets/blocked_screen.dart';   // اصلاح نام پکیج

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'تأیید کد دسترسی',
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'کد ۶ رقمی ارسال شده به شماره موبایل خود را وارد کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // فیلد هوشمند وارد کردن کد ۶ رقمی Pinput
                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      smsCode = value;
                    });

                    // اجرای متد بررسی کد
                    verifyOTP(smsCode: smsCode!);
                  },
                ),

                const SizedBox(height: 25),

                // نمایش وضعیت در حال بررسی
                authRepo.isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF145A41), // رنگ سبز سفیر
                      )
                    : const SizedBox.shrink(),

                // انیمیشن موفقیت‌آمیز بودن
                authRepo.isSuccessful
                    ? Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 25),

                const Text(
                  'کد را دریافت نکرده‌اید؟',
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 15),

                // دکمه ارسال مجدد کد دسترسی
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // فرهاد جان، متد ارسال مجدد در صورت نیاز اینجا صدا زده می‌شود
                    },
                    child: const Text(
                      "ارسال مجدد",
                      style: TextStyle(
                        fontFamily: 'IranYekan',
                        fontSize: 14,
                        color: Colors.black80,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // متد بررسی صحت کد پیامکی و هدایت راننده سفیر
  void verifyOTP({required String smsCode}) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    authProvider.verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onSuccess: () async {
        // ۱. بررسی اینکه آیا راننده از قبل در سیستم وجود دارد؟
        bool driverExists = await authProvider.checkUserExistById();

        if (driverExists) {
          // ۲. بررسی مسدود بودن یا نبودن راننده توسط پنل مدیریت سفیر
          bool isBlocked = await authProvider.checkIfDriverIsBlocked();

          if (isBlocked) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BlockedScreen()),
            );
          } else {
            // ۳. دریافت کل اطلاعات راننده از دیتابیس فایربیس
            await authProvider.getUserDataFromFirebaseDatabase();

            // ۴. بررسی اینکه راننده اطلاعات مدارک و وسیله نقلیه را پر کرده است یا خیر
            bool isDriverComplete = await authProvider.checkDriverFieldsFilled();

            if (isDriverComplete) {
              // انتقال به صفحه داشبورد اصلی
              navigate(isSignedIn: true);
            } else {
              // راننده‌ای که احراز هویت شده اما مدارکش ناقص است به فرم ثبت مدارک منتقل می‌شود
              navigate(isSignedIn: false);
              commonMethods.displaySnackBar(
                "لطفاً اطلاعات و مدارک ناقص خود را تکمیل کنید.",
                context,
              );
            }
          }
        } else {
          // اگر راننده کاملاً جدید بود مستقیم به صفحه ثبت اطلاعات اولیه هدایت می‌شود
          navigate(isSignedIn: false);
        }
      },
    );
  }

  // مدیریت ناوبری نهایی صفحات
  void navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DriverRegistration()),
        (route) => false,
      );
    }
  }
}
