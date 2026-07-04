import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/pages/profileUpdation/vehicleUpdation/driver_car_image_update_screen.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/profileUpdation/vehicleUpdation/vehicle_baisc_info_update_screen.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/profileUpdation/vehicleUpdation/vehicle_registration_update_screen.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج سفیر

class VehicleInfoUpdateScreen extends StatefulWidget {
  const VehicleInfoUpdateScreen({super.key});

  @override
  State<VehicleInfoUpdateScreen> createState() =>
      _VehicleInfoUpdateScreenState();
}

class _VehicleInfoUpdateScreenState extends State<VehicleInfoUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'اطلاعات موتر / وسیله نقلیه',
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Center(
            child: Column(
              children: [
                // کانتیینر اصلی لیست گزینه‌ها
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
                  width: MediaQuery.of(context).size.width * 0.9, // ۹۰ درصد عرض صفحه
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      thickness: 0.3,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildListTile(
                            title: 'اطلاعات پایه موتر',
                            subtitle: 'نوعیت موتر، برند، رنگ و شماره پلیت',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleBaiscInfoUpdateScreen(),
                                ),
                              );
                            },
                          );
                        case 1:
                          return _buildListTile(
                            title: 'عکس موتر',
                            subtitle: 'بارگذاری عکس واضح از نمای ظاهری موتر',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverCarImageUpdateScreeen(),
                                ),
                              );
                            },
                          );
                        case 2:
                          return _buildListTile(
                            title: 'کارت ثبت موتر / اسناد قانونی',
                            subtitle: 'بارگذاری تصاویر اسناد و کتابچه ثبت وسیله نقلیه',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleRegistrationUpdateScreen(),
                                ),
                              );
                            },
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// متد ساخت کاستوم لایست‌تایل متناسب با استایل راست‌چین
Widget _buildListTile({
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    title: Text(
      title,
      style: const TextStyle(fontFamily: 'IranYekan', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 12, color: Colors.black54),
      ),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
    onTap: onTap,
  );
}
