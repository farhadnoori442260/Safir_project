import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // 👈 جایگزین گوگل‌مپ
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // 👈 مختصات OpenStreetMap
import 'package:safir_drivers/methods/common_method.dart';
import 'package:safir_drivers/methods/map_theme_methods.dart';
import 'package:safir_drivers/models/trip_details.dart';
import 'package:safir_drivers/widgets/loading_dialog.dart';
import 'package:safir_drivers/widgets/payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global/global.dart';
import '../../utils/lang_helper.dart'; // 👈 هیلپر زبان

class NewTripPage extends StatefulWidget {
  final TripDetails? newTripDetailsInfo;
  const NewTripPage({super.key, this.newTripDetailsInfo});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final MapController mapController = MapController();
  MapThemeMethods themeMethods = MapThemeMethods();

  List<LatLng> polylinePointsList = [];
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "";
  String distanceText = "";

  String buttonTitleKey = "btn_arrived";
  Color buttonColor = const Color(0xFF145A41); // سبز سفیر
  CommonMethods commonMethods = CommonMethods();

  // دریافت مسیر و تنظیم حدود نقشه OSRM
  obtainDirectionAndDrawRoute(
      LatLng sourceLocationLatLng, LatLng destinationLocationLatLng) async {
    try {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => LoadingDialog(
          messageText: tr(context, 'please_wait'),
        ),
      );

      var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          sourceLocationLatLng, destinationLocationLatLng);

      Navigator.pop(context);

      if (tripDetailsInfo == null || tripDetailsInfo.polylinePoints == null) {
        return;
      }

      setState(() {
        polylinePointsList = tripDetailsInfo.polylinePoints!;
      });

      // تنظیم مرکز نقشه روی مبدأ
      mapController.move(sourceLocationLatLng, 15.0);
    } catch (e) {
      print("Error in obtainDirectionAndDrawRoute: $e");
    }
  }

  // ردیابی زنده لوکیشن راننده
  getLiveLocationUpdatesOfDriver() {
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position positionDriver) {
      driverCurrentPosition = positionDriver;

      LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      mapController.move(driverCurrentPositionLatLng, 16.0);

      updateTripDetailsInformation();

      Map updatedLocationOfDriver = {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude,
      };
      FirebaseDatabase.instance
          .ref()
          .child("tripRequest")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("driverLocation")
          .set(updatedLocationOfDriver);
    });
  }

  updateTripDetailsInformation() async {
    if (!directionRequested) {
      directionRequested = true;

      if (driverCurrentPosition == null) return;

      var driverLocationLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      LatLng dropOffDestinationLocationLatLng;
      if (statusOfTrip == "accepted") {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.pickUpLatLng!;
      } else {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.dropOffLatLng!;
      }

      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          driverLocationLatLng, dropOffDestinationLocationLatLng);

      if (directionDetailsInfo != null) {
        directionRequested = false;

        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  endTripNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(
        messageText: tr(context, 'ending_trip'),
      ),
    );

    var driverCurrentLocationLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    await CommonMethods.getDirectionDetailsFromAPI(
        widget.newTripDetailsInfo!.pickUpLatLng!,
        driverCurrentLocationLatLng);
    Navigator.pop(context);

    String finalFareAmount = "0";
    if (bidAmount != "null" && bidAmount.isNotEmpty) {
      finalFareAmount = bidAmount.toString();
    } else {
      finalFareAmount = fareAmount.toString();
    }

    FirebaseDatabase.instance
        .ref()
        .child("tripRequest")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("fareAmount")
        .set(finalFareAmount);

    FirebaseDatabase.instance
        .ref()
        .child("tripRequest")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("status")
        .set("ended");

    positionStreamNewTripPage!.cancel();

    displayLoadingDialog(finalFareAmount);

    saveFareAmountToDriverTotalEearning(finalFareAmount);
  }

  displayLoadingDialog(faremmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PaymentDialog(fareAmount: faremmount),
    );
  }

  saveFareAmountToDriverTotalEearning(String fareAmount) async {
    DatabaseReference driverEarningRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");
    await driverEarningRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double previousTotalEarning = double.parse(
          snap.snapshot.value.toString(),
        );
        double fareAmountForThisAmount = double.parse(fareAmount);
        double newTotalEarning = previousTotalEarning + fareAmountForThisAmount;
        driverEarningRef.set(newTotalEarning);
      } else {
        driverEarningRef.set(fareAmount);
      }
    });
  }

  saveDriverDataToTripInfo() async {
    Map<String, dynamic> driverDataMap = {
      "status": "accepted",
      "driverId": FirebaseAuth.instance.currentUser!.uid,
      "driverName": "$driverName $driverSecondName",
      "driverPhone": driverPhone,
      "driverPhoto": driverPhoto,
      "carDetails": "$carModel - $carNumber - $carColor",
    };

    if (driverCurrentPosition != null) {
      Map<String, dynamic> driverCurrentLocation = {
        'latitude': driverCurrentPosition!.latitude.toString(),
        'longitude': driverCurrentPosition!.longitude.toString(),
      };
      await FirebaseDatabase.instance
          .ref()
          .child("tripRequest")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("driverLocation")
          .update(driverCurrentLocation);
    }

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequest")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);
  }

  @override
  void initState() {
    super.initState();
    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // 👈 ویجت نقشه OpenStreetMap
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: driverCurrentPosition != null
                    ? LatLng(driverCurrentPosition!.latitude,
                        driverCurrentPosition!.longitude)
                    : googlePlexInitialPosition.target != null
                        ? LatLng(googlePlexInitialPosition.target.latitude,
                            googlePlexInitialPosition.target.longitude)
                        : const LatLng(34.5553, 69.2075),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: themeMethods.getMapTileUrl(isDarkMode),
                  userAgentPackageName: 'com.safir.drivers',
                ),
                // رسم خط مسیر سبز رنگ
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePointsList,
                      strokeWidth: 5.0,
                      color: const Color(0xFF145A41),
                    ),
                  ],
                ),
                // مارکرهای مبدأ، مقصد و موقعیت راننده
                MarkerLayer(
                  markers: [
                    if (driverCurrentPosition != null)
                      Marker(
                        point: LatLng(driverCurrentPosition!.latitude,
                            driverCurrentPosition!.longitude),
                        width: 40,
                        height: 40,
                        child: Image.asset("assets/images/tracking.png"),
                      ),
                    if (widget.newTripDetailsInfo?.pickUpLatLng != null)
                      Marker(
                        point: widget.newTripDetailsInfo!.pickUpLatLng!,
                        width: 35,
                        height: 35,
                        child: const Icon(Icons.location_on,
                            color: Colors.green, size: 35),
                      ),
                    if (widget.newTripDetailsInfo?.dropOffLatLng != null)
                      Marker(
                        point: widget.newTripDetailsInfo!.dropOffLatLng!,
                        width: 35,
                        height: 35,
                        child: const Icon(Icons.location_on,
                            color: Colors.orange, size: 35),
                      ),
                  ],
                ),
              ],
            ),

            // پنل پایینی اطلاعات سفر
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                height: 275,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "$durationText - $distanceText",
                          style: const TextStyle(
                              fontFamily: 'IranYekan',
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.newTripDetailsInfo!.userName ??
                                tr(context, 'unknown_passenger'),
                            style: const TextStyle(
                                fontFamily: 'IranYekan',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri.parse(
                                    "tel://${widget.newTripDetailsInfo!.userPhone}"),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone,
                                  color: Colors.green),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      // آدرس مبدا
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/initial.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "${tr(context, 'origin_label')}: ${widget.newTripDetailsInfo!.pickupAddress}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'IranYekan',
                                    fontSize: 14,
                                    color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // آدرس مقصد
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/final.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "${tr(context, 'destination_label')}: ${widget.newTripDetailsInfo!.dropOffAddress}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'IranYekan',
                                    fontSize: 14,
                                    color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // دکمه مدیریت وضعیت فرآیند سفر
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (statusOfTrip == "accepted") {
                              setState(() {
                                buttonTitleKey = "btn_start_trip";
                                buttonColor = Colors.green.shade700;
                              });
                              statusOfTrip = "arrived";
                              FirebaseDatabase.instance
                                  .ref()
                                  .child("tripRequest")
                                  .child(widget.newTripDetailsInfo!.tripID!)
                                  .child("status")
                                  .set("arrived");

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => LoadingDialog(
                                  messageText: tr(context, 'please_wait'),
                                ),
                              );

                              await obtainDirectionAndDrawRoute(
                                  widget.newTripDetailsInfo!.pickUpLatLng!,
                                  widget.newTripDetailsInfo!.dropOffLatLng!);

                              Navigator.pop(context);
                            } else if (statusOfTrip == "arrived") {
                              setState(() {
                                buttonTitleKey = "btn_end_trip";
                                buttonColor = Colors.red.shade700;
                                statusOfTrip = "ontrip";
                                FirebaseDatabase.instance
                                    .ref()
                                    .child("tripRequest")
                                    .child(widget.newTripDetailsInfo!.tripID!)
                                    .child("status")
                                    .set("ontrip");
                              });
                            } else if (statusOfTrip == "ontrip") {
                              endTripNow();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: Text(
                            tr(context, buttonTitleKey),
                            style: const TextStyle(
                                fontFamily: 'IranYekan',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
