import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج پروژه سفیر

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'تایید هویت (سلفی با تذکره)',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // بخش بارگذاری تصویر سلفی تایید هویت
                _buildImagePicker(
                    context,
                    'تأیید تصویر شناسایی',
                    registrationProvider.cnicWithSelfieImage,
                    registrationProvider.pickCnincImageWithSelfie,
                    'لطفاً تذکره یا کارت هویت خود را روبروی خود نگه داشته و یک عکس سلفی بگیرید. تصویر باید کاملاً واضح باشد تا چهره شما و اطلاعات مندرج روی کارت به شفافی قابل خواندن باشند. عکس را در محیطی با نور کافی و کیفیت مناسب تهیه کنید.'
                    ),
                const SizedBox(height: 25),

                // دکمه تایید نهایی سلفی
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: registrationProvider.cnicWithSelfieImage != null
                        ? () async {
                            try {
                              Navigator.pop(context, true);
                            } catch (e) {
                              print("Error while saving data: $e");
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: registrationProvider.cnicWithSelfieImage != null
                          ? const Color(0xFF145A41) // رنگ سبز برند سفیر
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

  Widget _buildImagePicker(BuildContext context, String label, XFile? imageFile,
      VoidCallback onPressed, String description) {
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
              style: const TextStyle(fontFamily: 'IranYekan', fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          imageFile != null
              ? Image.file(File(imageFile.path), height: 200, fit: BoxFit.cover)
              : Image.asset(
                  'assets/auth/selfie-with-id.png', 
                  height: 200,
                  errorBuilder: (c, e, s) => Icon(Icons.account_box, size: 150, color: Colors.grey.shade300),
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
                'گرفتن عکس سلفی',
                style: TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              description,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontFamily: 'IranYekan', fontSize: 12, color: Colors.black54, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
