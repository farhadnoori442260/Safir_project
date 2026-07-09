import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_map/flutter_map.dart'; // 👈 جایگزین گوگل مپ
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // 👈 مختصات LatLng جدید
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safir_drivers/providers/registration_provider.dart';
import 'package:safir_drivers/utils/lang_helper.dart';

import '../../pushNotifications/push_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // کنترلر نقشه OpenStreetMap
  final MapController mapController = MapController();
  
  Position? currentPositionOfDriver;
  LatLng currentLatLng = const LatLng(34.5553, 69.2075); // مختصات پیش‌فرض (مثلاً کابل)
  
  Color colorToShow = const Color(0xFF145A41);
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  StreamSubscription<Position>? positionStreamHomePage;

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;

    setState(() {
      currentLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
    });

    // انیمیشن جابه‌جایی دوربین نقشه به موقعیت راننده
    mapController.move(currentLatLng, 15.0);
  }

  _loadDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDriverAvailable = prefs.getBool('isDriverAvailable') ?? false;
      if (isDriverAvailable) {
        colorToShow = Colors.orange.shade800;
      } else {
        colorToShow = const Color(0xFF145A41);
      }
    });
  }

  _saveDriverStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverAvailable', status);
  }

  goOnlineNow() {
    Geofire.initialize("onlineDrivers");

    if (currentPositionOfDriver != null) {
      Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfDriver!.latitude,
        currentPositionOfDriver!.longitude,
      );
    }

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
      LatLng newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLatLng = newLatLng;
      });

      if (isDriverAvailable) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      mapController.move(newLatLng, mapController.camera.zoom);
    });
  }

  goOfflineNow() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    if (newTripRequestReference != null) {
      newTripRequestReference!.onDisconnect();
      newTripRequestReference!.remove();
      newTripRequestReference = null;
    }
    
    positionStreamHomePage?.cancel();
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
    
    // دریافت موقیت اولیه راننده
    getCurrentLiveLocationOfDriver();
  }

  @override
  void dispose() {
    positionStreamHomePage?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// نقشه OpenStreetMap با استفاده از پکیج flutter_map
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLatLng,
                initialZoom: 15.0,
              ),
              children: [
                // لایه کاشی‌های نقشه (Tile Layer) از سرورهای OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safir.drivers',
                ),
                // نشانگر موقعیت فعلی راننده رو نقشه
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLatLng,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF145A41),
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ],
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
                                          ? tr(context, 'change_to_online_title')
                                          : tr(context, 'change_to_offline_title'),
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
                                          ? tr(context, 'change_to_online_desc')
                                          : tr(context, 'change_to_offline_desc'),
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
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (!isDriverAvailable) {
                                                goOnlineNow();
                                                setAndGetLocationUpdates();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.orange.shade800;
                                                  isDriverAvailable = true;
                                                });
                                                _saveDriverStatus(true);
                                              } else {
                                                goOfflineNow();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = const Color(0xFF145A41);
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
                                            child: Text(
                                              tr(context, 'confirm'),
                                              style: const TextStyle(
                                                fontFamily: 'IranYekan', 
                                                color: Colors.white, 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
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
                                            child: Text(
                                              tr(context, 'cancel'),
                                              style: const TextStyle(
                                                fontFamily: 'IranYekan', 
                                                color: Colors.white
                                              ),
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
                      isDriverAvailable 
                          ? tr(context, 'status_offline_btn') 
                          : tr(context, 'status_online_btn'),
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
