import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentUser =
      FirebaseDatabase.instance.ref().child("tripRequest");
  final Color safirColor = const Color(0xFF145A41);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'تاریخچه سفرهای من',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
          ),
        ),
        body: StreamBuilder(
          stream: completedTripRequestsOfCurrentUser.onValue,
          builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshotData) {
            if (snapshotData.hasError) {
              return const Center(
                child: Text("خطایی در دریافت اطلاعات رخ داد.", style: TextStyle(color: Colors.red)),
              );
            }

            if (!snapshotData.hasData) {
              return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(safirColor)),
              );
            }

            if (snapshotData.data!.snapshot.value == null) {
              return const Center(
                child: Text("هیچ سفری ثبت نشده است.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              );
            }

            final snapshotValue = snapshotData.data!.snapshot.value;
            if (snapshotValue is Map) {
              final Map<String, dynamic> dataTrips = snapshotValue.cast<String, dynamic>();
              final List<Map<String, dynamic>> tripsList = [];
              
              dataTrips.forEach((key, value) {
                if (value is Map) {
                  // فقط سفرهایی که به اتمام رسیده‌اند و مربوط به کاربر فعلی هستند
                  if (value["status"] != null &&
                      value["status"] == "ended" &&
                      value["userID"] == FirebaseAuth.instance.currentUser!.uid) {
                    tripsList.add({"key": key, ...value});
                  }
                }
              });

              if (tripsList.isEmpty) {
                return const Center(
                  child: Text("هیچ سفری در تاریخچه شما یافت نشد.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                );
              }

              // معکوس کردن لیست برای نمایش جدیدترین سفرها در بالاترین قسمت
              final reverseTripsList = tripsList.reversed.toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: reverseTripsList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // بخش بالایی: وضعیت و کرایه به افغانی
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: safirColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "تکمیل شده",
                                  style: TextStyle(color: safirColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "${reverseTripsList[index]["fareAmount"]} افغانی",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: safirColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // مبدأ سفر
                          Row(
                            children: [
                              Icon(Icons.circle, color: safirColor, size: 14),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  reverseTripsList[index]["pickUpAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          
                          // خط رابط بین مبدا و مقصد
                          Padding(
                            padding: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
                            child: Container(
                              width: 2,
                              height: 15,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          
                          // مقصد سفر
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 16),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  reverseTripsList[index]["dropOffAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("فرمت داده‌ها نامعتبر است.", style: TextStyle(color: Colors.grey)),
              );
            }
          },
        ),
      ),
    );
  }
}
