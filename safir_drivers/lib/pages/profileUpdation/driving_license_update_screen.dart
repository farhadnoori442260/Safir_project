import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/pages/profileUpdation/cninc_update_screen.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج سفیر

class DrivingLicenseUpdateScreen extends StatefulWidget {
  const DrivingLicenseUpdateScreen({super.key});

  @override
  State<DrivingLicenseUpdateScreen> createState() =>
      _DrivingLicenseUpdateScreenState();
}

class _DrivingLicenseUpdateScreenState
    extends State<DrivingLicenseUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF145A41); // رنگ سبز برند سفیر

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'جواز سیر / لایسنس رانندگی',
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'بستن',
              style: TextStyle(fontFamily: 'IranYekan', color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          leadingWidth: 70,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بارگذاری روی لایسنس
                  _buildImagePickerFront(
                      context,
                      'عکس روی لایسنس (ابتدا عکس بگیرید و سپس کات کنید)',
                      registrationProvider.drivingLicenseFrontImage,
                      () => registrationProvider
                          .pickAndCropDrivingLicenseImage(true)),
                  const SizedBox(height: 16),

                  // بارگذاری پشت لایسنس
                  _buildImagePickerBack(
                      context,
                      'عکس پشت لایسنس (ابتدا عکس بگیرید و سپس کات کنید)',
                      registrationProvider.drivingLicenseBackImage,
                      () => registrationProvider
                          .pickAndCropDrivingLicenseImage(false)),
                  const SizedBox(height: 16),

                  // فیلد شماره لایسنس
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: registrationProvider.drivingLicenseController,
                      decoration: const InputDecoration(
                        labelText: 'شماره لایسنس / جواز رانندگی',
                        helperText: 'فرمت نمونه: ST-24-7174',
                        helperStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 11),
                        labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'وارد کردن شماره لایسنس الزامی است';
                        }
                        if (!registrationProvider.licenseRegExp.hasMatch(value)) {
                          return 'لطفاً شماره لایسنس را با فرمت معتبر (مانند ST-24-7174) وارد کنید';
                        }
                        return null;
                      },
                      onChanged: (value) => registrationProvider
                          .checkDrivingLicenseFormValidity(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // دکمه به‌روزرسانی
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationProvider.isFormValidDrivingLicnese &&
                              registrationProvider.isLoading == false
                          ? () async {
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  await registrationProvider
                                      .updatedriverLicenseInfo(context);

                                  commonMethods.displaySnackBar(
                                      "اطلاعات لایسنس شما با موفقیت به‌روزرسانی شد", context);
                                } catch (e) {
                                  print("Error while saving data: $e");
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: registrationProvider.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'به‌روزرسانی اطلاعات لایسنس',
                              style: TextStyle(fontFamily: 'IranYekan', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
}

Widget _buildImagePickerFront(BuildContext context, String label,
    XFile? imageFile, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'IranYekan', fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: Center,
          ),
        ),
        const SizedBox(height: 16),
        imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(imageFile.path), height: 150, width: 240, fit: BoxFit.cover),
              )
            : Image.asset('assets/auth/license-front.png', height: 150, width: 240, fit: BoxFit.contain),
        const SizedBox(height: 16),
        Container(
          width: 180,
          height: 42,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)),
              borderRadius: BorderRadius.circular(12)),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41), size: 18),
            label: const Text(
              'گرفتن عکس جدید',
              style: TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

Widget _buildImagePickerBack(BuildContext context, String label,
    XFile? imageFile, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'IranYekan', fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: Center,
          ),
        ),
        const SizedBox(height: 16),
        imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(imageFile.path), height: 150, width: 240, fit: BoxFit.cover),
              )
            : Image.asset('assets/auth/license-back.png', height: 150, width: 240, fit: BoxFit.contain),
        const SizedBox(height: 16),
        Container(
          width: 180,
          height: 42,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)),
              borderRadius: BorderRadius.circular(12)),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41), size: 18),
            label: const Text(
              'گرفتن عکس جدید',
              style: TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
