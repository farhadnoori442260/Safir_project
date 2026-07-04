import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/methods/common_method.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج پروژه سفیر

class CnincUpdateScreen extends StatefulWidget {
  const CnincUpdateScreen({super.key});

  @override
  State<CnincUpdateScreen> createState() => _CnincUpdateScreenState();
}

CommonMethods commonMethods = CommonMethods();
final _formKey = GlobalKey<FormState>();

class _CnincUpdateScreenState extends State<CnincUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF145A41); // رنگ سبز برند سفیر

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'تذکره / کارت ملی راننده',
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
                  // بارگذاری روی تذکره
                  _buildImagePickerFront(
                      context,
                      'عکس روی تذکره (ابتدا عکس بگیرید و سپس کات کنید)',
                      registrationProvider.cnincFrontImage,
                      () => registrationProvider.pickAndCropCnincImage(true)),
                  const SizedBox(height: 16),

                  // بارگذاری پشت تذکره
                  _buildImagePickerBack(
                      context,
                      'عکس پشت تذکره (ابتدا عکس بگیرید و سپس کات کنید)',
                      registrationProvider.cnincBackImage,
                      () => registrationProvider.pickAndCropCnincImage(false)),
                  const SizedBox(height: 16),

                  // فیلد شماره تذکره
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
                            blurRadius: 6.0),
                      ],
                    ),
                    child: TextFormField(
                      controller: registrationProvider.cnicController,
                      decoration: const InputDecoration(
                          labelText: 'شماره تذکره / کارت هوشمند ملی',
                          labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide())),
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'وارد کردن شماره تذکره الزامی است';
                        }
                        if (value.length != 13) {
                          return 'شماره تذکره باید ۱۳ رقم باشد';
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          registrationProvider.checkCNICFormValidity(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // دکمه تایید و به‌روزرسانی
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationProvider.isFormValidCninc &&
                              registrationProvider.isLoading == false
                          ? () async {
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  await registrationProvider
                                      .updateCnincInfo(context);
                                  commonMethods.displaySnackBar(
                                      "اطلاعات تذکره شما با موفقیت به‌روزرسانی شد", context);
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
                              'به‌روزرسانی مدرک هویت',
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
            : Image.asset('assets/auth/cnic-front.png', height: 150, width: 240, fit: BoxFit.contain),
        const SizedBox(height: 16),
        Container(
          width: 180,
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF145A41)),
            borderRadius: BorderRadius.circular(12),
          ),
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
            : Image.asset('assets/auth/cnic-back.png', height: 150, width: 240, fit: BoxFit.contain),
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
