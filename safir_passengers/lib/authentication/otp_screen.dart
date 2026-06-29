import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/user_information_screen.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/blocked_screen.dart';
import 'package:uber_users_app/pages/home_page.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

CommonMethods commonMethods = CommonMethods();

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    
    // تم مدرن برای فیلدهای ورود کد OTP
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کل صفحه احراز هویت
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // آیکون تایید هویت امنیتی
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: safirColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: safirColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'تایید شماره تماس',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'کد تایید ۶ رقمی ارسال شده به شماره موبایل خود را وارد کنید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ویجت Pinput با دیزاین اختصاصی سفیر
                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: safirColor, width: 1.5),
                        color: Colors.white,
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: safirColor),
                        color: safirColor.withOpacity(0.05),
                      ),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        smsCode = value;
                      });
                      verifyOTP(smsCode: smsCode!);
                    },
                  ),

                  const SizedBox(height: 32),

                  // انیمیشن‌های وضعیت بارگذاری یا موفقیت
                  if (authRepo.isLoading)
                    CircularProgressIndicator(
                      color: safirColor,
                    )
                  else if (authRepo.isSuccessful)
                    Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                  const SizedBox(height: 32),

                  const Text(
                    'کد را دریافت نکرده‌اید؟',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // دکمه ارسال مجدد کد
                  TextButton.icon(
                    onPressed: () {
                      // بعداً منطق ارسال مجدد اضافه می‌شود
                    },
                    icon: Icon(Icons.refresh_rounded, size: 18, color: safirColor),
                    label: Text(
                      "ارسال مجدد کد",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: safirColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTP({required String smsCode}) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    authProvider.verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onSuccess: () async {
        bool userExits = await authProvider.checkUserExistById();
        if (!mounted) return;
        if (userExits) {
          bool isBlocked = await authProvider.checkIfUserIsBlocked();
          if (isBlocked) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BlockedScreen(),
              ),
            );
          } else {
            await authProvider.getUserDataFromFirebaseDatabase();
            bool isUserComplete = await authProvider.checkUserFieldsFilled();

            if (isUserComplete) {
              navigate(isSingedIn: true);
            } else {
              navigate(isSingedIn: false);
              commonMethods.displaySnackBar(
                "لطفاً اطلاعات ناقص خود را تکمیل کنید!",
                context,
              );
            }
          }
        } else {
          navigate(isSingedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserInformationScreen()));
    }
  }
}
