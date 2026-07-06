import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:safir_admin/utils/lang_helper.dart'; // 👈 اضافه شدن هیلپر ترجمه

class DriverDataScreen extends StatefulWidget {
  final String driverId;

  const DriverDataScreen({super.key, required this.driverId});

  @override
  State<DriverDataScreen> createState() => _DriverDataScreenState();
}

class _DriverDataScreenState extends State<DriverDataScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("drivers").child(widget.driverId);

    return StreamBuilder(
      stream: driverRef.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return Center(
            child: Text(
              tr(context, 'error_occurred'), // 👈 بومی‌سازی ارور
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return Center(
            child: Text(
              tr(context, 'no_data_found'), // 👈 بومی‌سازی نبودن دیتا
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true, 
            backgroundColor: const Color(0xFF145A41), // 👈 هماهنگ‌سازی رنگ با سبز سفیر پنل اصلی
            centerTitle: true,
            title: Text(
              tr(context, 'driver_details'), // 👈 عنوان هدر متحرک سه‌زبانه
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileSection(dataMap),
                const SizedBox(height: 20),
                const Divider(),
                _buildNationalIdSection(dataMap),
                const SizedBox(height: 20),
                const Divider(),
                _buildLicenseSection(dataMap),
                const SizedBox(height: 20),
                const Divider(),
                _buildVehicleInfoSection(dataMap),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(Map dataMap) {
    String firstName = dataMap['firstName'] ?? '';
    String secondName = dataMap['secondName'] ?? '';
    String notReg = tr(context, 'not_registered'); // 👈 متغیر کمکی برای فیلدهای خالی
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dataMap.containsKey('profilePicture') && dataMap['profilePicture'] != null)
          ClipOval(
            child: Image.network(
              dataMap['profilePicture'],
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 150),
            ),
          ),
        const SizedBox(width: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${tr(context, 'full_name')}: $firstName $secondName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("${tr(context, 'phone')}: ${dataMap['phoneNumber'] ?? notReg}"),
            Text("${tr(context, 'email')}: ${dataMap['email'] ?? notReg}"),
            Text("${tr(context, 'national_id')}: ${dataMap['cnicNumber'] ?? notReg}"),
            Text("${tr(context, 'address')}: ${dataMap['address'] ?? notReg}"),
            Text("${tr(context, 'dob')}: ${dataMap['dob'] ?? notReg}"),
          ],
        ),
      ],
    );
  }

  Widget _buildNationalIdSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'identity_docs'), // 👈 ترجمه عنوان بخش مدارک هویتی
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['cnicFrontImage'], tr(context, 'id_front')),
            _buildImage(dataMap['cnicBackImage'], tr(context, 'id_back')),
            _buildImage(dataMap['driverFaceWithCnic'], tr(context, 'selfie_with_id')),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'driving_license'), // 👈 ترجمه عنوان گواهینامه
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('${tr(context, 'license_number')}: ${dataMap['drivingLicenseNumber'] ?? tr(context, 'not_registered')}'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['drivingLicenseFrontImage'], tr(context, 'license_front')),
            _buildImage(dataMap['drivingLicenseBackImage'], tr(context, 'license_back')),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection(Map dataMap) {
    if (!dataMap.containsKey('vehicleInfo') || dataMap['vehicleInfo'] == null) {
      return Text(
        tr(context, 'vehicle_not_registered'), // 👈 ترجمه شرط عدم وجود خودرو
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    Map vehicle = dataMap['vehicleInfo'] as Map;
    String notReg = tr(context, 'not_registered');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'vehicle_info_title'), // 👈 ترجمه مشخصات سفیر
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("${tr(context, 'vehicle_type')}: ${vehicle['type'] ?? notReg}"),
        Text("${tr(context, 'vehicle_brand')}: ${vehicle['brand'] ?? notReg}"),
        Text("${tr(context, 'vehicle_color')}: ${vehicle['color'] ?? notReg}"),
        Text("${tr(context, 'production_year')}: ${vehicle['productionYear'] ?? notReg}"),
        Text("${tr(context, 'plate_number')}: ${vehicle['registrationPlateNumber'] ?? notReg}"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(vehicle['registrationCertificateFrontImage'], tr(context, 'car_card_front')),
            _buildImage(vehicle['registrationCertificateBackImage'], tr(context, 'car_card_back')),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(dynamic url, String label) {
    if (url == null || url.toString().isEmpty) {
      return Column(
        children: [
          Container(
            width: 150,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return Column(
      children: [
        Image.network(
          url.toString(),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 150,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.red),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
