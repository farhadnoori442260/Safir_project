import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safir_drivers/methods/common_method.dart'; // اصلاح نام پکیج به safir_drivers
import 'package:safir_drivers/pages/dashboard.dart';       // اصلاح نام پکیج به safir_drivers
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkIsAvailable() {
    //cMethods.checkConnectivity(context);

    if (imageFile != null) {
      signUpFormValidation();
    } else {
      cMethods.displaySnackBar("لطفاً ابتدا عکس پروفایل خود را انتخاب کنید.", context);
    }
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("نام شما باید حداقل ۴ کاراکتر باشد.", context);
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar("شماره تلفن باید حداقل ۸ رقم باشد.", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("لطفاً یک ایمیل معتبر وارد کنید.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("رمز عبور باید حداقل ۶ کاراکتر باشد.", context);
    } else if (vehicleModelTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar("لطفاً مدل وسیله نقلیه خود را وارد کنید.", context);
    } else if (vehicleColorTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar("لطفاً رنگ وسیله نقلیه خود را وارد کنید.", context);
    } else if (vehicleNumberTextEditingController.text.isEmpty) {
      cMethods.displaySnackBar("لطفاً شماره پلاک/فورم وسیله نقلیه را وارد کنید.", context);
    } else {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    registerNewDriver();
  }

  registerNewDriver() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const LoadingDialog(messageText: "در حال ثبت حساب کاربری شما..."),
      );

      final User? userFirebase = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ))
          .user;

      if (!context.mounted) return;
      Navigator.pop(context);

      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

      Map driverCarInfo = {
        "carColor": vehicleColorTextEditingController.text.trim(),
        "carModel": vehicleModelTextEditingController.text.trim(),
        "carNumber": vehicleNumberTextEditingController.text.trim(),
      };

      Map driverDataMap = {
        "photo": urlOfUploadedImage,
        "car_details": driverCarInfo,
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "no",
      };
      usersRef.set(driverDataMap);

      Navigator.push(context, MaterialPageRoute(builder: (c) => const Dashboard()));
    } catch (errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }
  }

  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
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
              const SizedBox(height: 40),

              imageFile == null
                  ? const CircleAvatar(
                      radius: 86,
                      backgroundImage: AssetImage("assets/images/avatarman.png"),
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: FileImage(
                                File(imageFile!.path),
                              ))),
                    ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "انتخاب عکس پروفایل",
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "نام و نام خانوادگی",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "شماره تلفن",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "ایمیل",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "رمز عبور",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "مدل وسیله نقلیه (مثلاً موتر تویوتا / موتورسایکل)",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "رنگ وسیله نقلیه",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "شماره پلاک یا پلیت وسیله نقلیه",
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF145A41), // تغییر رنگ به سبز اختصاصی سفیر
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)),
                      child: const Text(
                        "ثبت‌نام",
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
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
                child: const Text(
                  "قبلاً ثبت‌نام کرده‌اید؟ از اینجا وارد شوید",
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
