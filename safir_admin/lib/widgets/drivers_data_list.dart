import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ایمپورت‌های اختصاصی سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/pages/driver_data_screen.dart';
import '../provider/driver_provider.dart';

class DriversDataList extends StatefulWidget {
  const DriversDataList({super.key});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("drivers");

  @override
  Widget build(BuildContext context) {
    // رنگ اختصاصی سفیر برای دکمه‌ها
    final Color safirGreen = const Color(0xFF145A41);

    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          debugPrint("Error: ${snapshotData.error}");
          return const Center(
            child: Text(
              "خطایی رخ داده است. لطفاً بعداً تلاش کنید.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }
        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshotData.connectionState == ConnectionState.none) {
          return const Center(
            child: Text(
              "ارتباط برقرار نیست. لطفاً اینترنت خود را بررسی کنید.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }
        
        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "هیچ اطلاعاتی یافت نشد.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List listItems = [];
        dataMap.forEach((key, value) {
          listItems.add({"key": key, ...value});
        });

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 5),
          itemCount: listItems.length,
          shrinkWrap: true,
          itemBuilder: ((context, index) {
            
            // جلوگیری از کرش در صورت نبود اطلاعات خودرو
            var vehicle = listItems[index]["vehicleInfo"];
            String carDetails = vehicle != null 
                ? "${vehicle["brand"]} ${vehicle["color"]} ${vehicle["productionYear"]}" 
                : "ثبت نشده";

            // محاسبه درآمد و نمایش با واحد افغانی
            var earnings = listItems[index]["earnings"];
            String earningText = (earnings != null && earnings.toString().isNotEmpty)
                ? "${double.parse(earnings.toString()).toStringAsFixed(2)} افغانی"
                : "0.00 افغانی";

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonMethods.data(
                  1,
                  Text(
                    "${listItems[index]["firstName"]} ${listItems[index]["secondName"]}",
                  ),
                ),
                CommonMethods.data(
                  1,
                  Text(carDetails),
                ),
                CommonMethods.data(
                  1,
                  Text(
                    listItems[index]["phoneNumber"]?.toString() ?? "ثبت نشده",
                  ),
                ),
                CommonMethods.data(
                  1,
                  Text(earningText),
                ),
                // سلول دکمه مسدود/رفع مسدودی
                CommonMethods.data(
                  1,
                  SizedBox(
                    height: 30, // بهینه‌سازی ارتفاع دکمه برای خوانایی متن
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: listItems[index]["blockStatus"] == "no" 
                            ? Colors.red.shade700 // رنگ قرمز برای مسدود کردن
                            : safirGreen, // رنگ سبز سفیر برای رفع مسدودی
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Provider.of<DriverProvider>(context, listen: false)
                            .toggleBlockStatus(listItems[index]["key"],
                                listItems[index]["blockStatus"]);
                      },
                      child: Text(
                        listItems[index]["blockStatus"] == "no" ? "مسدود کردن" : "رفع مسدودی",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                // سلول دکمه جزئیات بیشتر
                CommonMethods.data(
                  1,
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safirGreen, // استفاده از سبز سفیر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        String driverId = listItems[index]["key"] ?? 'UnknownID'; 
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => DriverDataScreen(driverId: driverId),
                          ),
                        );
                      },
                      child: const Text(
                        "جزئیات بیشتر",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
