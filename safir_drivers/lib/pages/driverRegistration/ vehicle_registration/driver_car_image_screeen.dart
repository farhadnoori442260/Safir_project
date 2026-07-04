import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج با برند سفیر

class DriverCarImageScreeen extends StatefulWidget {
  const DriverCarImageScreeen({super.key});

  @override
  State<DriverCarImageScreeen> createState() => _DriverCarImageScreeenState();
}

class _DriverCarImageScreeenState extends State<DriverCarImageScreeen> {
  @override
  Widget build(BuildContext context) {
    
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'تصویر وسیله نقلیه',
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'بستن', 
                style: TextStyle(fontFamily: 'IranYekan', color: Colors.black, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // بخش انتخاب تصویر موتر/موتورسایکل راننده
                _buildImagePicker(
                  context,
                  'لطفاً یک عکس واضح از نمای روبه‌رو یا جانبی وسیله نقلیه خود قرار دهید.',
                  registrationProvider.vehicleImage,
                  registrationProvider.pickVehicleImageFromCamera,
                ),
                const SizedBox(height: 25),

                // دکمه تایید و ثبت نهایی
                Widget/SizedBox (
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50, // اندازه ثابت استاندارد برای دکمه
                  child: ElevatedButton(
                    onPressed: registrationProvider.isVehiclePhotoAdded
                        ? () async {
                            try {
                              // Navigator.pop به همراه true یعنی عکس با موفقیت ثبت شد
                              Navigator.pop(context, true);
                            } catch (e) {
                              print("Error while saving data: $e");
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: registrationProvider.isVehiclePhotoAdded
                          ? const Color(0xFF145A41) // رنگ سبز اختصاصی سفیر
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
    );
  }

  // ویجت سفارشی‌سازی شده برای کادر انتخاب تصویر
  Widget _buildImagePicker(BuildContext context, String label, XFile? imageFile,
      VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
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
              style: const TextStyle(fontFamily: 'IranYekan', fontSize: 14, color: Colors.black80),
            ),
          ),
          const SizedBox(height: 16),
          
          // اگر راننده عکس گرفته باشد، آن را نشان می‌دهد؛ در غیر این صورت یک تصویر موتر پیش‌فرض
          imageFile != null
              ? Image.file(File(imageFile.path), height: 160, fit: BoxFit.cover)
              : Icon(Icons.directions_car, size: 120, color: Colors.grey.shade400), // استفاده از آیکون به جای تصویر ثابت محلی جهت جلوگیری از کرش احتمالی نبود فایل
              
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)), // مرز سبز سفیر
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41)),
              label: const Text(
                'گرفتن عکس با دوربین',
                style: TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
