import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safir_drivers/global/global.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج پروژه سفیر

import '../../methods/map_theme_methods.dart';
import '../../pushNotifications/push_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  
  // تنظیمات رنگ و متن اولیه بر اساس برند سفیر
  Color colorToShow = const Color(0xFF145A41); // سبز سفیر برای آنلاین شدن
  String titleToShow = "شروع به کار (آنلاین)";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _loadDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDriverAvailable = prefs.getBool('isDriverAvailable') ?? false;
      if (isDriverAvailable) {
        colorToShow = Colors.orange.shade800; // رنگ نارنجی/سرخ برای آفلاین شدن
        titleToShow = "خروج از کار (آفلاین)";
      } else {
        colorToShow = const Color(0xFF145A41); // رنگ سبز سفیر برای آنلاین شدن
        titleToShow = "شروع به کار (آنلاین)";
      }
    });
  }

  _saveDriverStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverAvailable', status);
  }

  goOnlineNow() {
    // مقداردهی اولیه ژئوفایر برای رانندگان آنلاین
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event) {});
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOfflineNow() {
    // توقف اشتراک‌گذاری موقعیت زنده راننده
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    // قطع شنود وضعیت سفر جدید
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  @override
  void initState() {
    super.initState();
    _loadDriverStatus();
    initializePushNotificationSystem();
    Provider.of<RegistrationProvider>(context, listen: false)
        .retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// نقشه گوگل
            GoogleMap(
              padding: const EdgeInsets.only(top: 136),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                //themeMethods.updateMapTheme(controllerGoogleMap!);
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfDriver();
              },
            ),

            Container(
              height: 136,
              width: double.infinity,
            ),

            /// دکمه تغییر وضعیت آنلاین / آفلاین
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.black90,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 7.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              height: 240,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      (!isDriverAvailable)
                                          ? "تغییر وضعیت به آنلاین"
                                          : "تغییر وضعیت به آفلاین",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'IranYekan',
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      (!isDriverAvailable)
                                          ? "شما در حال آنلاین شدن هستید؛ با این کار آمادگی شما جهت دریافت درخواست‌های سفر از سوی مسافرین سفیر ثبت خواهد شد."
                                          : "شما در حال آفلاین شدن هستید؛ با خروج از این وضعیت، دیگر درخواست سفر جدیدی دریافت نخواهید کرد.",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'IranYekan',
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        // دکمه تایید عمل (سمت راست در چینش فارسی)
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (!isDriverAvailable) {
                                                goOnlineNow();
                                                setAndGetLocationUpdates();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.orange.shade800;
                                                  titleToShow = "خروج از کار (آفلاین)";
                                                  isDriverAvailable = true;
                                                });
                                                _saveDriverStatus(true);
                                              } else {
                                                goOfflineNow();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = const Color(0xFF145A41);
                                                  titleToShow = "شروع به کار (آنلاین)";
                                                  isDriverAvailable = false;
                                                });
                                                _saveDriverStatus(false);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (!isDriverAvailable)
                                                  ? const Color(0xFF145A41)
                                                  : Colors.orange.shade800,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text(
                                              "تأیید",
                                              style: TextStyle(fontFamily: 'IranYekan', color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // دکمه بازگشت و انصراف
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white24,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text(
                                              "لغو",
                                              style: TextStyle(fontFamily: 'IranYekan', color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorToShow,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      titleToShow,
                      style: const TextStyle(
                        fontFamily: 'IranYekan', 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
