import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/pages/profileUpdation/basic_driver_info_update_screen.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/pages/profileUpdation/cninc_update_screen.dart';
import 'package:safir_drivers/pages/profileUpdation/driving_license_update_screen.dart';
import 'package:safir_drivers/pages/profileUpdation/selfie_with_cninc_update_screen.dart';
import 'package:safir_drivers/pages/profileUpdation/vehicle_info_update_screen.dart';
import 'package:safir_drivers/providers/registration_provider.dart';

class DriverMainInfo extends StatefulWidget {
  const DriverMainInfo({super.key});

  @override
  _DriverMainInfoState createState() => _DriverMainInfoState();
}

class _DriverMainInfoState extends State<DriverMainInfo> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      await Provider.of<RegistrationProvider>(context, listen: false)
          .fetchUserData();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF145A41); // سبز برند سفیر

    return Consumer<RegistrationProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'تکمیل و به‌روزرسانی پروفایل',
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: provider.isFetchLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "در حال دریافت اطلاعات شما...",
                      style: TextStyle(fontFamily: 'IranYekan', fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(
                      color: brandColor,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 6.0),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.92,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // جلوگیری از تداخل اسکرول
                          itemCount: 5,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.black12,
                            thickness: 0.5,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildListTile(
                                title: 'اطلاعات پایه',
                                subtitle: 'نام، ایمیل و مشخصات عمومی راننده',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BasicDriverInfoUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 1) {
                              return _buildListTile(
                                title: 'تذکره / کارت ملی',
                                subtitle: 'تنظیمات عکس و شماره تذکره هوشمند',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CnincUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 2) {
                              return _buildListTile(
                                title: 'سلفی همراه تذکره',
                                subtitle: 'گرفتن عکس واضح راننده در کنار مدرک هویت',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelfieWithCnincUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 3) {
                              return _buildListTile(
                                title: 'جواز سیر / لایسنس رانندگی',
                                subtitle: 'ثبت شماره لایسنس و تصاویر مدارک رانندگی',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DrivingLicenseUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return _buildListTile(
                                title: 'مشخصات وسایط نقلیه',
                                subtitle: 'اطلاعات مدل، رنگ، نمبر پلیت و تصاویر موتر',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VehicleInfoUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  // متد ساخت کاستوم لیست‌تایل متناسب با استایل راست‌به‌چپ
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'IranYekan', fontSize: 12, color: Colors.black54),
      ),
      // استفاده از آیکون چپ‌جهت برای هماهنگی با زبان فارسی و باز شدن صفحات از راست به چپ
      trailing: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.black38),
      onTap: onTap,
    );
  }
}
