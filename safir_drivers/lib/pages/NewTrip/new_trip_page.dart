import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safir_drivers/methods/common_method.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/methods/map_theme_methods.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/models/trip_details.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/widgets/loading_dialog.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:safir_drivers/widgets/payment_dialog.dart'; // اصلاح نام پکیج پروژه سفیر
import 'package:url_launcher/url_launcher.dart';

import '../../global/global.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails? newTripDetailsInfo;
  const NewTripPage({super.key, this.newTripDetailsInfo});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markersSet = <Marker>{};
  Set<Circle> circlesSet = <Circle>{};
  Set<Polyline> polyLinesSet = <Polyline>{};
  BitmapDescriptor? carMarkerIcon;
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "";
  
  // متون دکمه‌ها بر اساس زبان فارسی و برند سفیر
  String buttonTitleText = "رسیدم (Arrived)";
  Color buttonColor = const Color(0xFF145A41); // رنگ سبز سفیر
  String distanceText = "";
  CommonMethods commonMethods = CommonMethods();

  makeMarker() {
    if (carMarkerIcon == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(2, 2));

      BitmapDescriptor.fromAssetImage(
              configuration, "assets/images/tracking.png")
          .then((valueIcon) {
        carMarkerIcon = valueIcon;
      });
    }
  }

  obtainDirectionAndDrawRoute(
      sourceLocationLatLng, destinationLocationLatLng) async {
    try {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const LoadingDialog(
          messageText: 'لطفاً منتظر بمانید...',
        ),
      );

      var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          sourceLocationLatLng, destinationLocationLatLng);

      Navigator.pop(context);

      if (tripDetailsInfo == null || tripDetailsInfo.encodedPoints == null) {
        return;
      }

      PolylinePoints pointsPolyline = PolylinePoints();
      List<PointLatLng> latLngPoints =
          pointsPolyline.decodePolyline(tripDetailsInfo.encodedPoints!);

      coordinatesPolylineLatLngList.clear();

      if (latLngPoints.isNotEmpty) {
        for (var pointLatLng in latLngPoints) {
          coordinatesPolylineLatLngList
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }
      }

      polyLinesSet.clear();

      setState(() {
        Polyline polyline = Polyline(
            polylineId: const PolylineId("routeID"),
            color: const Color(0xFF145A41), // رنگ مسیر سبز سفیر
            points: coordinatesPolylineLatLngList,
            jointType: JointType.round,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        polyLinesSet.add(polyline);
      });

      LatLngBounds boundsLatLng;

      if (sourceLocationLatLng.latitude > destinationLocationLatLng.latitude &&
          sourceLocationLatLng.longitude >
              destinationLocationLatLng.longitude) {
        boundsLatLng = LatLngBounds(
          southwest: destinationLocationLatLng,
          northeast: sourceLocationLatLng,
        );
      } else if (sourceLocationLatLng.longitude >
          destinationLocationLatLng.longitude) {
        boundsLatLng = LatLngBounds(
          southwest: LatLng(sourceLocationLatLng.latitude,
              destinationLocationLatLng.longitude),
          northeast: LatLng(destinationLocationLatLng.latitude,
              sourceLocationLatLng.longitude),
        );
      } else if (sourceLocationLatLng.latitude >
          destinationLocationLatLng.latitude) {
        boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLocationLatLng.latitude,
              sourceLocationLatLng.longitude),
          northeast: LatLng(sourceLocationLatLng.latitude,
              destinationLocationLatLng.longitude),
        );
      } else {
        boundsLatLng = LatLngBounds(
          southwest: sourceLocationLatLng,
          northeast: destinationLocationLatLng,
        );
      }

      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

      Marker sourceMarker = Marker(
        markerId: const MarkerId('sourceID'),
        position: sourceLocationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      Marker destinationMarker = Marker(
        markerId: const MarkerId('destinationID'),
        position: destinationLocationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      setState(() {
        markersSet.add(sourceMarker);
        markersSet.add(destinationMarker);
      });

      Circle sourceCircle = Circle(
        circleId: const CircleId('sourceCircleID'),
        strokeColor: Colors.orange,
        strokeWidth: 4,
        radius: 14,
        center: sourceLocationLatLng,
        fillColor: Colors.green,
      );

      Circle destinationCircle = Circle(
        circleId: const CircleId('destinationCircleID'),
        strokeColor: Colors.green,
        strokeWidth: 4,
        radius: 14,
        center: destinationLocationLatLng,
        fillColor: Colors.orange,
      );

      setState(() {
        circlesSet.add(sourceCircle);
        circlesSet.add(destinationCircle);
      });
    } catch (e, stackTrace) {
      print("Error in obtainDirectionAndDrawRoute: $e");
    }
  }

  getLiveLocationUpdatesOfDriver() {
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position positionDriver) {
      driverCurrentPosition = positionDriver;

      LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId("carMarkerID"),
        position: driverCurrentPositionLatLng,
        icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "موقعیت من"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: driverCurrentPositionLatLng, zoom: 16);
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((element) => element.markerId.value == "carMarkerID");
        markersSet.add(carMarker);
      });

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

      if (driverCurrentPosition == null) {
        return;
      }

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
      builder: (BuildContext context) => const LoadingDialog(
        messageText: 'در حال اتمام سفر...',
      ),
    );

    var driverCurrentLocationLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    await CommonMethods.getDirectionDetailsFromAPI(
        widget.newTripDetailsInfo!.pickUpLatLng!,
        driverCurrentLocationLatLng);
    Navigator.pop(context);

    String finalFareAmount = "0";
    if (bidAmount != "null") {
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

    Map<String, dynamic> driverCurrentLocation = {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequest")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);
    await FirebaseDatabase.instance
        .ref()
        .child("tripRequest")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("driverLocation")
        .update(driverCurrentLocation);
  }

  @override
  void initState() {
    super.initState();
    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context) {
    makeMarker();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: markersSet,
              circles: circlesSet,
              polylines: polyLinesSet,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) async {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);

                setState(() {
                  googleMapPaddingFromBottom = 262;
                });

                var driverCurrentLocationLatLng = LatLng(
                    driverCurrentPosition!.latitude,
                    driverCurrentPosition!.longitude);

                var userPickUpLocationLatLng =
                    widget.newTripDetailsInfo!.pickUpLatLng;

                await obtainDirectionAndDrawRoute(
                    driverCurrentLocationLatLng, userPickUpLocationLatLng);

                getLiveLocationUpdatesOfDriver();
              },
            ),
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
                            widget.newTripDetailsInfo!.userName ?? "مسافر بدون نام",
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
                              child: const Icon(Icons.phone, color: Colors.green),
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
                                "مبدأ: ${widget.newTripDetailsInfo!.pickupAddress}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'IranYekan', fontSize: 14, color: Colors.white70),
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
                                "مقصد: ${widget.newTripDetailsInfo!.dropOffAddress}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'IranYekan', fontSize: 14, color: Colors.white70),
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
                                buttonTitleText = "شروع سفر (Start Trip)";
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
                                builder: (BuildContext context) =>
                                    const LoadingDialog(
                                  messageText: 'لطفاً منتظر بمانید...',
                                ),
                              );

                              await obtainDirectionAndDrawRoute(
                                  widget.newTripDetailsInfo!.pickUpLatLng,
                                  widget.newTripDetailsInfo!.dropOffLatLng!);

                              Navigator.pop(context);
                            } else if (statusOfTrip == "arrived") {
                              setState(() {
                                buttonTitleText = "پایان سفر (End Trip)";
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
                            buttonTitleText,
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
