import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج پروژه سفیر

class DrivingLicenseScreen extends StatefulWidget {
  const DrivingLicenseScreen({super.key});

  @override
  _DrivingLicenseScreenState createState() => _DrivingLicenseScreenState();
}

class _DrivingLicenseScreenState extends State<DrivingLicenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'جواز رانندگی (گواهینامه)',
            style: TextStyle(fontFamily: 'IranYekan', fontSize: 16, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('بستن', style: TextStyle(fontFamily: 'IranYekan', color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  // بارگذاری تصویر روی جواز رانندگی
                  _buildImagePickerFront(
                      context,
                      'تصویر روی جواز رانندگی (ابتدا عکس بگیرید سپس برش دهید)',
                      registrationProvider.drivingLicenseFrontImage,
                      () => registrationProvider.pickAndCropDrivingLicenseImage(true)),
                  const SizedBox(height: 16),

                  // بارگذاری تصویر پشت جواز رانندگی
                  _buildImagePickerBack(
                      context,
                      'تصویر پشت جواز رانندگی (ابتدا عکس بگیرید سپس برش دهید)',
                      registrationProvider.drivingLicenseBackImage,
                      () => registrationProvider.pickAndCropDrivingLicenseImage(false)),
                  const SizedBox(height: 16),

                  // فیلد نمبر جواز رانندگی
                  Container(
                    padding: const EdgeInsets.all(12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                            controller: registrationProvider.drivingLicenseController,
                            decoration: const InputDecoration(
                              labelText: 'نمبر جواز رانندگی',
                              labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 14),
                              helperText: 'فرمت نمونه: ST-24-7174',
                              helperStyle: TextStyle(fontSize: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'وارد کردن نمبر جواز رانندگی الزامی است';
                              }
                              if (!registrationProvider.licenseRegExp.hasMatch(value)) {
                                return 'لطفاً نمبر جواز را با فرمت معتبر (مانند ST-24-7174) وارد کنید';
                              }
                              return null;
                            },
                            onChanged: (value) => registrationProvider.checkDrivingLicenseFormValidity(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // دکمه تایید نهایی جواز رانندگی
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationProvider.isFormValidDrivingLicnese
                          ? () async {
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  print("Error while saving data: $e");
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: registrationProvider.isFormValidDrivingLicnese
                            ? const Color(0xFF145A41) // رنگ برند سفیر
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'تأیید و ذخیره',
                        style: TextStyle(fontFamily: 'IranYekan', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'IranYekan', fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          imageFile != null
              ? Image.file(File(imageFile.path), height: 150, fit: BoxFit.cover)
              : Image.asset(
                  'assets/auth/license-front.png', 
                  height: 150,
                  errorBuilder: (c, e, s) => Icon(Icons.badge, size: 120, color: Colors.grey.shade300),
                ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41)),
              label: const Text(
                'گرفتن عکس از رو',
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
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'IranYekan', fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          imageFile != null
              ? Image.file(File(imageFile.path), height: 150, fit: BoxFit.cover)
              : Image.asset(
                  'assets/auth/license-back.png', 
                  height: 150,
                  errorBuilder: (c, e, s) => Icon(Icons.badge, size: 120, color: Colors.grey.shade300),
                ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41)),
              label: const Text(
                'گرفتن عکس از پشت',
                style: TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
