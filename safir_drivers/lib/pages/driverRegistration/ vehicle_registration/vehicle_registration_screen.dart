import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart';
import 'package:safir_drivers/utils/lang_helper.dart'; // 👈 هیلپر زبان سفیر

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context, 'vehicle_registration_title'),
            style: const TextStyle(fontFamily: 'IranYekan', fontSize: 16, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                tr(context, 'close'), 
                style: const TextStyle(fontFamily: 'IranYekan', color: Colors.black, fontWeight: FontWeight.bold)
              ),
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
                  // بارگذاری تصویر روی جواز سیر
                  _buildImagePicker(
                    context: context,
                    label: tr(context, 'registration_front_title'),
                    imageFile: registrationProvider.vehicleRegistrationFrontImage,
                    buttonText: tr(context, 'take_photo_front'),
                    defaultAssetPath: 'assets/auth/cnic-front.png',
                    onPressed: () => registrationProvider
                        .pickAndCropVehicleRegistrationImages(true),
                  ),
                  const SizedBox(height: 16),

                  // بارگذاری تصویر پشت جواز سیر
                  _buildImagePicker(
                    context: context,
                    label: tr(context, 'registration_back_title'),
                    imageFile: registrationProvider.vehicleRegistrationBackImage,
                    buttonText: tr(context, 'take_photo_back'),
                    defaultAssetPath: 'assets/auth/cnic-back.png',
                    onPressed: () => registrationProvider
                        .pickAndCropVehicleRegistrationImages(false),
                  ),
                  const SizedBox(height: 25),

                  // دکمه ثبت نهایی مدارک
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationProvider.vehicleRegistrationFrontImage != null &&
                              registrationProvider.vehicleRegistrationBackImage != null
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
                        backgroundColor: registrationProvider.vehicleRegistrationFrontImage != null &&
                                registrationProvider.vehicleRegistrationBackImage != null
                            ? const Color(0xFF145A41) // رنگ سبز برند سفیر
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        tr(context, 'confirm_and_save_final'),
                        style: const TextStyle(
                          fontFamily: 'IranYekan', 
                          color: Colors.white, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        ),
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

  // ویجت یکپارچه برای ساخت کادر دریافت عکس روی/پشت جواز سیر
  Widget _buildImagePicker({
    required BuildContext context,
    required String label,
    required XFile? imageFile,
    required String buttonText,
    required String defaultAssetPath,
    required VoidCallback onPressed,
  }) {
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
          Text(
            label,
            style: const TextStyle(fontFamily: 'IranYekan', fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          imageFile != null
              ? Image.file(File(imageFile.path), height: 150, fit: BoxFit.cover)
              : Image.asset(
                  defaultAssetPath,
                  height: 150,
                  errorBuilder: (c, e, s) => Icon(Icons.credit_card, size: 120, color: Colors.grey.shade300),
                ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF145A41)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF145A41)),
              label: Text(
                buttonText,
                style: const TextStyle(fontFamily: 'IranYekan', color: Color(0xFF145A41), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
