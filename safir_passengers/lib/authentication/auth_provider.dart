import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// اصلاح کامپوننت‌ها و مدل‌ها بر اساس پوشه‌بندی و ساختار جدید سفیر
import 'register_screen.dart';
import 'otp_screen.dart';
import '../methods/common_methods.dart';
import '../models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isGoogleSignedIn = false;
  bool _isGoogleSignInLoading = false;
  String? _uid;
  String? _phoneNumber;

  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber!;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isGoogleSignedIn => _isGoogleSignedIn;
  bool get isGoogleSigInLoading => _isGoogleSignInLoading;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance; 
  final GoogleSignIn googleSignIn = GoogleSignIn(); 

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startGoogleLoading() {
    _isGoogleSignInLoading = true;
    notifyListeners();
  }

  void stopGoogleLoading() {
    _isGoogleSignInLoading = false;
    notifyListeners();
  }

  // ارسال کد تایید پیامکی (OTP) به شماره موبایل مسافر سفیر
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    startLoading(); 

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
          stopLoading(); 
        },
        verificationFailed: (FirebaseAuthException e) {
          stopLoading(); 
          commonMethods.displaySnackBar(e.toString(), context);
          throw Exception(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          stopLoading(); 
          _phoneNumber = phoneNumber;
          notifyListeners();
          
          // انتقال مسافر به صفحه وارد کردن کد تایید
          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stopLoading(); 
        },
      );
    } on FirebaseException catch (e) {
      stopLoading(); 
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // بررسی وجود شماره تلفن در دیتابیس فایربیس سفیر
  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("phone").equalTo(phoneNumber).once();

    return snapshot.snapshot.exists;
  }

  // تایید نهایی کد OTP و ورود مسافر به لایه احراز هویت
  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      User? user =
          (await firebaseAuth.signInWithCredential(phoneAuthCredential)).user;

      if (user != null) {
        _uid = user.uid;
        notifyListeners();
        onSuccess();
      }

      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // ذخیره اطلاعات تکمیلی مسافر جدید در ریل‌تایم دیتابیس سفیر
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    notifyListeners();

    try {
      DatabaseReference usersRef =
          firebaseDatabase.ref().child("users").child(userModel.id);
      await usersRef.set(userModel.toMap()).then((value) {
        stopLoading();
        notifyListeners();

        onSuccess();
      });
    } on FirebaseException catch (e) {
      stopLoading();
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // چک کردن تکراری نبودن ایمیل در سیستم
  Future<bool> checkUserExistByEmail(String email) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("email").equalTo(email).once();

    return snapshot.snapshot.exists;
  }

  // چک کردن تکراری نبودن شماره تماس
  Future<bool> checkUserExistByPhone(String phoneNumber) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("phone")
        .equalTo(phoneNumber.toString().trim())
        .once();

    return snapshot.snapshot.exists;
  }

  // بررسی اصالت آی‌دی کاربری فایربیس مسافر
  Future<bool> checkUserExistById() async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("id") 
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once();

    return snapshot.snapshot.exists;
  }

  // دریافت کامل پروفایل مسافر از فایربیس و مقداردهی در حافظه برنامه
  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      DatabaseReference usersRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        _userModel = UserModel(
          id: userData['id'] ?? '',
          name: userData['name'] ?? 'مسافر سفیر',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          blockStatus: userData['blockStatus'] ?? 'no',
        );

        _uid = _userModel!.id;
        notifyListeners(); 
      } else {
        print("اطلاعات پروفایل مسافر در دیتابیس پیدا نشد.");
      }
    } catch (e) {
      print("خطا در دریافت اطلاعات کاربر: $e");
    }
  }

  // بررسی وضعیت مسدود (بلاک) بودن مسافر توسط مدیریت سفیر
  Future<bool> checkIfUserIsBlocked() async {
    try {
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map driverData = snapshot.value as Map;
        String blockStatus = driverData["blockStatus"] ?? 'no';

        if (blockStatus == 'yes') {
          // اگر مسافر بلاک بود، بلافاصله حسابش را خارج کن
          await firebaseAuth.signOut();
          await googleSignIn.signOut();

          _uid = null;
          _isGoogleSignedIn = false;
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } else {
        print("داده‌ای یافت نشد یا فرمت آن صحیح نیست.");
        return false; 
      }
    } catch (e) {
      print("خطا در بررسی وضعیت بلاک مسافر: $e");
      return false; 
    }
  }

  // بررسی پر بودن تمام فیلدهای الزامی ثبت‌نام مسافر قبل از ورود به نقشه
  Future<bool> checkUserFieldsFilled() async {
    try {
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map userData = snapshot.value as Map;

        String id = userData["id"] ?? '';
        String name = userData["name"] ?? '';
        String email = userData["email"] ?? '';
        String phone = userData["phone"] ?? '';

        if (id.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty) {
          return false; 
        } else {
          return true; 
        }
      } else {
        return false;
      }
    } catch (e) {
      print("خطا در بررسی تکمیل فیلدهای مسافر: $e");
      return false;
    }
  }

  // ورود سریع مسافران با حساب دایرکت گوگل
  Future<void> signInWithGoogle(
      BuildContext context, VoidCallback onSuccess) async {
    startGoogleLoading();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        stopGoogleLoading();
        return; 
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _uid = user.uid;
        _isGoogleSignedIn = true;
        notifyListeners();
      }
      onSuccess();

      stopGoogleLoading();
    } on FirebaseAuthException catch (e) {
      stopGoogleLoading();
      commonMethods.displaySnackBar(
          e.message ?? "ورود با گوگل با خطا مواجه شد", context);
    }
  }

  // خروج کامل مسافر از حساب کاربری و هدایت امن به صفحه ثبت‌نام سفیر
  Future<void> signOut(BuildContext context) async {
    startLoading();
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();

      _uid = null;
      _isGoogleSignedIn = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
        (route) => false,
      );

      stopLoading();
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.message ?? "خطا در خروج از حساب", context);
    }
  }
}
