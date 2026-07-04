import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/methods/common_method.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/pages/dashboard.dart';       // اصلاح نام پکیج
import 'package:safir_drivers/pages/driverRegistration/driver_registration.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/widgets/blocked_screen.dart';   // اصلاح نام پکیج
import '../../providers/auth_provider.dart'; // اصلاح نام پکیج

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

  // تنظیم کشور پیش‌فرض روی افغانستان برای اپلیکیشن سفیر
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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "ورود یا ثبت‌نام راننده سفیر",
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "لطفاً شماره موبایل خود را بدون صفر وارد کنید",
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                
                Directionality(
                  textDirection: TextDirection.ltr, // برای نمایش درست فیلد شماره تلفن و پیش‌شماره
                  child: TextFormField(
                    controller: phoneController,
                    maxLength: 9, // شماره‌های افغانستان بدون صفر ۹ رقم هستند
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    onChanged: (value) {
                      setState(() {
                        phoneController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '77 123 4567',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF145A41), width: 2),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.fromLTRB(12.0, 14.0, 8.0, 14.0),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                  borderRadius: BorderRadius.zero,
                                  bottomSheetHeight: 400),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            );
                          },
                          child: Text(
                            ' +${selectedCountry.phoneCode}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      suffixIcon: phoneController.text.length == 9
                          ? Container(
                              height: 20,
                              width: 20,
                              margin: const EdgeInsets.all(12.0),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Color(0xFF145A41)),
                              child: const Icon(
                                Icons.done,
                                size: 16,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // دکمه ادامه مسیر با شماره تلفن
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: sendPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF145A41), // رنگ سبز سفیر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : const Text(
                            "ادامه",
                            style: TextStyle(
                              fontFamily: 'IranYekan',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "یا",
                        style: TextStyle(
                          fontFamily: 'IranYekan',
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // دکمه ورود با حساب گوگل
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (!authProvider.isLoading) {
                              await authProvider.signInWithGoogle(
                                context,
                                () async {
                                  bool userExists = await authProvider.checkUserExistById();
                                  bool userExistsInDatabase = await authProvider.checkUserExistByEmail(
                                    authProvider.firebaseAuth.currentUser!.email!.toString(),
                                  );

                                  if (userExists) {
                                    if (userExistsInDatabase) {
                                      bool isBlocked = await authProvider.checkIfDriverIsBlocked();

                                      if (isBlocked) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const BlockedScreen()),
                                        );
                                      } else {
                                        await authProvider.getUserDataFromFirebaseDatabase();
                                        bool isDriverComplete = await authProvider.checkDriverFieldsFilled();

                                        if (isDriverComplete) {
                                          navigate(isSingedIn: true);
                                        } else {
                                          navigate(isSingedIn: false);
                                          commonMethods.displaySnackBar("لطفاً اطلاعات ناقص خود را تکمیل کنید.", context);
                                        }
                                      }
                                    } else {
                                      navigate(isSingedIn: false);
                                    }
                                  } else {
                                    navigate(isSingedIn: false);
                                  }
                                },
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isGoogleSigInLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF145A41)),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png', // حتما لوگوی گوگل را در متعلقات قرار بده یا از آیکون استفاده کن
                                height: 22,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.black80),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "ادامه با حساب گوگل",
                                style: TextStyle(
                                  fontFamily: 'IranYekan',
                                  color: Colors.black80,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Center(
                  child: Text(
                    "با ادامه کار، شما موافقت خود را با قوانین و مقررات سفیر جهت دریافت تماس، پیام در واتساپ یا پیامک تأیید هویت اعلام می‌دارید.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IranYekan',
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.5,
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

  void sendPhoneNumber() {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();

    // ولیدیشن اختصاصی شماره تلفن‌های افغانستان (معمولاً شروع با 7 و کلاً 9 رقم بدون صفر)
    if (phoneNumber.isEmpty || phoneNumber.length != 9 || !RegExp(r'^[7][0-9]{8}$').hasMatch(phoneNumber)) {
      commonMethods.displaySnackBar(
        "لطفاً یک شماره موبایل معتبر (مثل 771234567) وارد کنید.",
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
          MaterialPageRoute(builder: (context) => const Dashboard()),
          (route) => false);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DriverRegistration()));
    }
  }
}
