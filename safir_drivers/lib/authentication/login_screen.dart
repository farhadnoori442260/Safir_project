import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:safir_drivers/pages/dashboard.dart'; // اصلاح نام پکیج به safir_drivers
import '../methods/common_method.dart';
import '../widgets/loading_dialog.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    //cMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("لطفاً یک ایمیل معتبر وارد کنید.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("رمز عبور شما باید حداقل ۶ کاراکتر باشد.", context);
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const LoadingDialog(messageText: "در حال ورود به برنامه..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        )
            .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("حساب شما مسدود شده است. لطفاً با پشتیبانی سفیر تماس بگیرید.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("رکورد شما به عنوان راننده در سیستم وجود ندارد.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // تصویر خودروی سفیر از پوشه تصاویر
              Image.asset(
                "assets/images/uberexec.png",
                width: 220,
              ),

              const SizedBox(height: 30),

              const Text(
                "ورود رانندگان سفیر",
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "ایمیل شما",
                        labelStyle: TextStyle(
                          fontFamily: 'IranYekan',
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "رمز عبور",
                        labelStyle: TextStyle(
                          fontFamily: 'IranYekan',
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF145A41), // تغییر رنگ به سبز اختصاصی سفیر
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)),
                      child: const Text(
                        "ورود",
                        style: TextStyle(
                          fontFamily: 'IranYekan',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
                },
                child: const Text(
                  "حسابی ندارید؟ از اینجا ثبت‌نام کنید",
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    color: Colors.grey,
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
