import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// اصلاح ایمپورت‌ها به پکیج جدید سفیر ادمین
import 'package:safir_admin/methods/common_methods.dart';
import 'package:safir_admin/provider/user_provider.dart';

class UsersDataList extends StatefulWidget {
  const UsersDataList({super.key});

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList> {
  final usersRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("users");

  @override
  Widget build(BuildContext context) {
    final Color safirGreen = const Color(0xFF145A41); // رنگ سازمانی سبز سفیر

    return StreamBuilder(
      stream: usersRecordsFromDatabase.onValue,
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
              "ارتباط برقرار نیست. لطفاً وضعیت اینترنت خود را بررسی کنید.",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          );
        }

        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "هیچ کاربری ثبت نشده است.",
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
          physics: const NeverScrollableScrollPhysics(), // مدیریت بهتر اسکرول وب
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // استفاده از متد استاتیک به جای شیء‌سازی محلی
                CommonMethods.data(
                  1,
                  Text(
                    listItems[index]["name"]?.toString() ?? "بدون نام",
                  ),
                ),
                CommonMethods.data(
                  1,
                  Text(
                    listItems[index]["email"]?.toString() ?? "ثبت نشده",
                  ),
                ),
                CommonMethods.data(
                  1,
                  Text(
                    listItems[index]["phone"]?.toString() ?? "ثبت نشده",
                  ),
                ),
                CommonMethods.data(
                  1,
                  SizedBox(
                    height: 30, // اصلاح ارتفاع دکمه برای خوانایی متن فارسی
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: listItems[index]["blockStatus"] == "no"
                            ? Colors.red.shade700 // رنگ قرمز برای مسدود سازی
                            : safirGreen, // رنگ سبز سفیر برای رفع مسدودیت
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        // فراخوانی متد پروايدر برای تغییر وضعیت مسدودیت
                        Provider.of<UserProvider>(context, listen: false)
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
              ],
            );
          }),
        );
      },
    );
  }
}
