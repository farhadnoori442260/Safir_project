import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/home_page.dart';
import '../models/user_model.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  CommonMethods commonMethods = CommonMethods();
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    gmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    if (authProvider.isGoogleSignedIn == false) {
      phoneController.text = authProvider.phoneNumber;
    }

    if (authProvider.isGoogleSignedIn) {
      gmailController.text = authProvider.firebaseAuth.currentUser!.email.toString();
      phoneController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کامل صفحه فرم پروفایل
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تکمیل پروفایل سفیر',
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 28),
                child: Column(
                  children: [
                    // یک آیکون یا لوگوی گرافیکی ساده و مدرن برای بالای صفحه پروفایل
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: safirColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: safirColor,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // فیلدهای فرم ورودی اطلاعات
                    myTextFormField(
                      hintText: 'نام و نام خانوادگی خود را وارد کنید',
                      icon: Icons.person_outline_rounded,
                      textInputType: TextInputType.name,
                      maxLength: 35,
                      textEditingController: nameController,
                      enabled: true,
                    ),
                    const SizedBox(height: 18),

                    myTextFormField(
                      hintText: 'آدرس ایمیل (اختیاری)',
                      icon: Icons.mail_outline_rounded,
                      textInputType: TextInputType.emailAddress,
                      maxLength: 40,
                      textEditingController: gmailController,
                      enabled: authProvider.isGoogleSignedIn ? false : true,
                    ),
                    const SizedBox(height: 18),

                    myTextFormField(
                      hintText: 'شماره موبایل',
                      icon: Icons.phone_android_rounded,
                      textInputType: TextInputType.number,
                      maxLength: 13,
                      textEditingController: phoneController,
                      enabled: authProvider.isGoogleSignedIn ? true : false,
                    ),
                    const SizedBox(height: 32),

                    // دکمه تایید و ادامه با تم لوکس سفیر
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saveUserDataToFireStore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: safirColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "تایید و ورود به برنامه",
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
          ),
        ),
      ),
    );
  }

  // ویجت فیلد متنی سفارشی‌سازی شده با تم جدید سفیر
  Widget myTextFormField({
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    required int maxLength,
    required TextEditingController textEditingController,
    required bool enabled,
  }) {
    return TextFormField(
      enabled: enabled,
      cursorColor: safirColor,
      controller: textEditingController,
      keyboardType: textInputType,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: 15,
        color: enabled ? Colors.black87 : Colors.black38,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(
          icon,
          size: 22,
          color: enabled ? safirColor : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: safirColor, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
      ),
    );
  }

  // ذخیره اطلاعات کاربری در فایراستور بستر فایربیس
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
        id: authProvider.uid!,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: gmailController.text.trim(),
        blockStatus: "no");

    if (nameController.text.trim().length >= 3) {
      authProvider.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        onSuccess: () async {
          navigateToHomeScreen();
        },
      );
    } else {
      commonMethods.displaySnackBar(
          'نام کاربری باید حداقل شامل ۳ حرف باشد', context);
    }
  }

  void navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false);
  }
}
