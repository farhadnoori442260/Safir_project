import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/user_information_screen.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/blocked_screen.dart';
import 'package:uber_users_app/pages/home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final Color safirColor = const Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

  // بومی‌سازی پیش‌فرض کشور روی افغانستان (AF - 93)
  Country selectedCountry = Country(
    phoneCode: '93',
    countryCode: 'AF',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Afghanistan',
    example: 'Afghanistan',
    displayName: 'Afghanistan',
    displayNameNoCountryCode: 'AF',
    e164Key: '',
  );

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کل صفحه ورود و ثبت‌نام
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // عنوان شیک صفحه
                  const Text(
                    "شماره موبایل خود را وارد کنید",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "کد تایید پیامکی به این شماره ارسال خواهد شد.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // فیلد ورود شماره همراه با کشور انتخاب‌کن
                  TextFormField(
                    controller: phoneController,
                    maxLength: 9, // شماره‌های افغانستان بدون صفر اول ۹ رقم هستند (مثلاً 78XXXXXXX)
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '78 123 4567',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: safirColor, width: 1.5),
                      ),
                      // دکمه انتخاب کشور (راست‌چین شده در لایه پیش‌فرض فلاتر)
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryListTheme: CountryListThemeData(
                                      borderRadius: BorderRadius.circular(16),
                                      bottomSheetHeight: 450),
                                  onSelect: (value) {
                                    setState(() {
                                      selectedCountry = value;
                                    });
                                  },
                                );
                              },
                              child: Text(
                                ' ${selectedCountry.flagEmoji}  +${selectedCountry.phoneCode} ',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      suffixIcon: phoneController.text.length == 9
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: safirColor,
                              size: 24,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // دکمه تایید و ادامه شماره تلفن
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: sendPhoneNumber,
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
                              "دریافت کد تایید",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // بخش جداکننده راه‌ها
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.withOpacity(0.25))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "یا ورود با حساب‌های دیگر",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.withOpacity(0.25))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // دکمه ورود با گوگل اصلاح شده و لوکس
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (!authProvider.isLoading) {
                                await authProvider.signInWithGoogle(
                                  context,
                                  () async {
                                    bool userExits = await authProvider.checkUserExistById();
                                    bool userExistInDatabse = await authProvider
                                        .checkUserExistByEmail(authProvider
                                            .firebaseAuth.currentUser!.email!
                                            .toString());
                                    if (userExits) {
                                      if (userExistInDatabse) {
                                        bool isBlocked = await authProvider.checkIfUserIsBlocked();
                                        if (isBlocked) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const BlockedScreen()),
                                          );
                                        } else {
                                          await authProvider.getUserDataFromFirebaseDatabase();
                                          navigate(isSingedIn: true);
                                        }
                                      }
                                    } else {
                                      navigate(isSingedIn: false);
                                    }
                                  },
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isGoogleSigInLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: safirColor, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 32), // اصلاح آیکون اشتباه هواپیما
                                SizedBox(width: 4),
                                Text(
                                  "ورود با حساب گوگل",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // دکمه ورود با اپل ایدی
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: const Text(
                        "ورود با حساب اپل",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // متن قوانین حریم خصوصی و موافقت‌نامه بومی‌شده
                  Text(
                    "با ادامه این فرآیند، شما موافقت خود را با شرایط خدمات و قوانین حریم خصوصی سفیر اعلام می‌کنید و تایید می‌کنید که پیامک‌های سیستم را در تلفن خود دریافت نمایید.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      height: 1.5,
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

  // اعتبارسنجی منطق شماره موبایل‌های افغانستان
  void sendPhoneNumber() {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();

    // اعتبارسنجی شماره‌های ۹ رقمی مروّج افغانستان که با ۷ شروع می‌شوند (مثل روشن، اتصالات، افغان‌بیسیم، سلام، ام‌تی‌ان)
    if (phoneNumber.isEmpty ||
        phoneNumber.length != 9 ||
        !RegExp(r'^[7][0-9]{8}$').hasMatch(phoneNumber)) {
      commonMethods.displaySnackBar(
        "لطفاً یک شماره موبایل ۹ رقمی معتبر (بدون صفر اول) وارد کنید.",
        context,
      );
      return;
    }

    String fullPhoneNumber = '+${selectedCountry.phoneCode}$phoneNumber';

    authRepo.signInWithPhone(
      context: context,
      phoneNumber: fullPhoneNumber,
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
