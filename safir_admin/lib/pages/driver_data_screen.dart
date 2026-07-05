import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
          return const Center(
            child: Text(
              "خطایی رخ داده است. بعداً تلاش کنید.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "اطلاعاتی یافت نشد.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true, // فعال کردن دکمه بازگشت به لیست راننده‌ها
            backgroundColor: const Color.fromARGB(221, 39, 57, 99),
            centerTitle: true,
            title: const Text(
              "جزئیات اطلاعات راننده",
              style: TextStyle(color: Colors.white),
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
              "نام و نام خانوادگی: $firstName $secondName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("شماره تماس: ${dataMap['phoneNumber'] ?? 'ثبت نشده'}"),
            Text("ایمیل: ${dataMap['email'] ?? 'ثبت نشده'}"),
            Text("کد ملی: ${dataMap['cnicNumber'] ?? 'ثبت نشده'}"),
            Text("آدرس: ${dataMap['address'] ?? 'ثبت نشده'}"),
            Text("تاریخ تولد: ${dataMap['dob'] ?? 'ثبت نشده'}"),
          ],
        ),
      ],
    );
  }

  // بومی‌سازی شده از CNIC به مدارک هویتی و کد ملی
  Widget _buildNationalIdSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "تصاویر مدارک هویتی (کارت ملی):",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['cnicFrontImage'], "روی کارت ملی"),
            _buildImage(dataMap['cnicBackImage'], "پشت کارت ملی"),
            _buildImage(dataMap['driverFaceWithCnic'], "سلفی با کارت ملی"),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "گواهینامه رانندگی:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('شماره گواهینامه: ${dataMap['drivingLicenseNumber'] ?? 'ثبت نشده'}'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['drivingLicenseFrontImage'], "روی گواهینامه"),
            _buildImage(dataMap['drivingLicenseBackImage'], "پشت گواهینامه"),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection(Map dataMap) {
    // جلوگیری از کرش در صورتی که اطلاعات خودرو هنوز ثبت نشده باشد
    if (!dataMap.containsKey('vehicleInfo') || dataMap['vehicleInfo'] == null) {
      return const Text("اطلاعات خودرو هنوز ثبت نشده است.");
    }

    Map vehicle = dataMap['vehicleInfo'] as Map;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "اطلاعات وسیله نقلیه (سفیر):",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("نوع خودرو: ${vehicle['type'] ?? 'ثبت نشده'}"),
        Text("مدل/برند: ${vehicle['brand'] ?? 'ثبت نشده'}"),
        Text("رنگ: ${vehicle['color'] ?? 'ثبت نشده'}"),
        Text("سال تولید: ${vehicle['productionYear'] ?? 'ثبت نشده'}"),
        Text("شماره پلاک: ${vehicle['registrationPlateNumber'] ?? 'ثبت نشده'}"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(vehicle['registrationCertificateFrontImage'], "روی کارت ماشین"),
            _buildImage(vehicle['registrationCertificateBackImage'], "پشت کارت ماشین"),
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
