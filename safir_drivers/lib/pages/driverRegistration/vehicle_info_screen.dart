import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/pages/driverRegistration/vehicle_registration/driver_car_image_screeen.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/pages/driverRegistration/vehicle_registration/vehicle_baisc_info.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/pages/driverRegistration/vehicle_registration/vehicle_registration_screen.dart'; // اصلاح نام پکیج
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool isBasicInfoComplete = false;
  bool isVehiclePictureComplete = false;
  bool isCertificateOfVehicleComplete = false;

  @override
  Widget build(BuildContext context) {
    bool isAllComplete = isBasicInfoComplete &&
        isVehiclePictureComplete &&
        isCertificateOfVehicleComplete;

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'مشخصات و اطلاعات موتر',
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Center(
            child: Column(
              children: [
                // لیست مراحل ثبت اطلاعات موتر
                Container(
                  decoration: BoxDecoration(
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
                  width: MediaQuery.of(context).size.width * 0.93,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      thickness: 0.3,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildListTile(
                            title: 'مشخصات اولیه موتر',
                            subtitle: 'ثبت نوعیت موتر، مدل، برند و نمبر پلیت',
                            isCompleted: isBasicInfoComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VehicleBasicInfoScreen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isBasicInfoComplete = true;
                                });
                              }
                            },
                          );
                        case 1:
                          return _buildListTile(
                            title: 'تصویر موتر',
                            subtitle: 'بارگذاری عکس واضح از نمای ظاهری موتر',
                            isCompleted: isVehiclePictureComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DriverCarImageScreeen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isVehiclePictureComplete = true;
                                });
                              }
                            },
                          );
                        case 2:
                          return _buildListTile(
                            title: 'اسناد اسکن اسناد موتر (جواز سیر)',
                            subtitle: 'بارگذاری تصاویر اسناد رسمی و جواز سیر موتر',
                            isCompleted: isCertificateOfVehicleComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VehicleRegistrationScreen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isCertificateOfVehicleComplete = true;
                                });
                              }
                            },
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // دکمه ذخیره نهایی این بخش
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.93,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAllComplete ? const Color(0xFF145A41) : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isAllComplete
                        ? () async {
                            Navigator.pop(context, true);
                          }
                        : null,
                    child: Text(
                      'تأیید و ذخیره مشخصات موتر',
                      style: TextStyle(
                        fontFamily: 'IranYekan',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isAllComplete ? Colors.white : Colors.black38,
                      ),
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

  // متد ساخت لیست‌تایل‌ها
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 15, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 12, color: Colors.black54),
      ),
      trailing: isCompleted
          ? const Icon(Icons.check_circle, color: Color(0xFF145A41), size: 26)
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
      onTap: onTap,
    );
  }
}
