import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // پکیج لوکیشن نقشه باز
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/global/trip_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/widgets/bid_dialog.dart';
import 'package:uber_users_app/widgets/payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';
import 'search_destination_place.dart';

class SafirMapScreen extends StatefulWidget {
  final String serviceType;
  const SafirMapScreen({super.key, required this.serviceType});

  @override
  State<SafirMapScreen> createState() => _SafirMapScreenState();
}

class _SafirMapScreenState extends State<SafirMapScreen> {
  // کنترلر نقشه OpenStreetMap
  final MapController _mapController = MapController();
  LatLng _currentUserLatLng = const LatLng(34.5333, 69.1667); // کابل به عنوان پیش‌فرض

  int _selectedCategory = 0; 
  int _selectedVehicleType = 0; 
  int _currentStep = 0; 
  final Color safirColor = const Color(0xFF145A41);

  // لیست نقاط خط مسیر روی OpenStreetMap
  List<LatLng> _routePolylinePoints = [];
  
  DatabaseReference? tripRequestRef;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;

  double actualFareAmount = 0.0;
  double? bidAmount;
  String selectedVehicle = "Car";

  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.serviceType;
    // هماهنگ‌سازی تب اولیه بر اساس انتخاب کاربر در هوم اسکرین سفیر
    if (selectedVehicle == "Bike") {
      _selectedCategory = 1;
    } else if (selectedVehicle == "Auto") {
      _selectedCategory = 0;
      _selectedVehicleType = 1;
    } else {
      _selectedCategory = 0;
      _selectedVehicleType = 0;
    }
    _getCurrentLiveLocation();
  }

  // دریافت موقعیت فعلی با Geolocator بدون نیاز به گوگل
  Future<void> _getCurrentLiveLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (mounted) {
      setState(() {
        _currentUserLatLng = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentUserLatLng, 15.0);
      
      // تبدیل مختصات به آدرس متنی برای هماهنگی با پرووایدر شما
      await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(position, context);
    }
  }

  // دریافت خط مسیر و مسافت ۱۰۰٪ رایگان از سرور عمومی OSRM
  Future<void> _getOSRMRoute() async {
    var pickUp = Provider.of<AppInfoClass>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppInfoClass>(context, listen: false).dropOffLocation;

    if (pickUp == null || dropOff == null) return;

    // آدرس سرور رایگان OSRM برای مسیریابی خودرو
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${pickUp.longitudePosition},${pickUp.latitudePosition};'
        '${dropOff.longitudePosition},${dropOff.latitudePosition}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];
          final double distanceInMeters = data['routes'][0]['distance'].toDouble(); // مسافت به متر
          
          setState(() {
            // تبدیل مختصات جی‌سان OSRM به نقاط سازگار با flutter_map
            _routePolylinePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
            
            // محاسبه قیمت بر اساس مسافت کیلومتری (مثلاً هر کیلومتر ۱۰ افغانی + قیمت ثابت ۳۰ افغانی)
            double distanceInKm = distanceInMeters / 1000;
            double baseFare = 30.0;
            double calculatedFare = baseFare + (distanceInKm * 10);

            if (selectedVehicle == "Car") {
              actualFareAmount = calculatedFare;
            } else if (selectedVehicle == "Auto") {
              actualFareAmount = calculatedFare * 1.4; // سفیر ویژه
            } else if (selectedVehicle == "Bike") {
              actualFareAmount = calculatedFare * 0.5; // سفیر موتور
            }
          });

          // زوم خودکار نقشه طوری که مبدأ و مقصد هر دو دیده شوند
          if (_routePolylinePoints.isNotEmpty) {
            _mapController.move(_routePolylinePoints[0], 13.0);
          }
        }
      }
    } catch (e) {
      debugPrint("خطا در دریافت مسیر OSRM: $e");
    }
  }

  // ارسال درخواست سفر زنده به فایربیس
  void makeTripRequest() {
    tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequest").push();
    var pickUp = Provider.of<AppInfoClass>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppInfoClass>(context, listen: false).dropOffLocation;

    Map<String, dynamic> dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": {"latitude": pickUp!.latitudePosition.toString(), "longitude": pickUp.longitudePosition.toString()},
      "dropOffLatLng": {"latitude": dropOff!.latitudePosition.toString(), "longitude": dropOff.longitudePosition.toString()},
      "pickUpAddress": pickUp.placeName,
      "dropOffAddress": dropOff.placeName,
      "driverId": "waiting",
      "fareAmount": actualFareAmount.toStringAsFixed(0),
      "status": "new",
      "bidAmount": bidAmount != null ? bidAmount!.toStringAsFixed(0) : actualFareAmount.toStringAsFixed(0),
      "vehicleType": selectedVehicle,
    };

    tripRequestRef!.set(dataMap);

    tripStreamSubscription = tripRequestRef!.onValue.listen((eventSnapshot) async {
      var data = eventSnapshot.snapshot.value as Map?;
      if (data == null) return;

      status = data["status"] ?? status;
      nameDriver = data["driverName"] ?? nameDriver;
      phoneNumberDriver = data["driverPhone"] ?? phoneNumberDriver;
      photoDriver = data["driverPhoto"] ?? photoDriver;

      if (status == "accepted" && mounted) {
        setState(() => _currentStep = 4);
      }

      if (status == "ended") {
        double fare = double.parse(data["fareAmount"].toString());
        await showDialog(
          context: context,
          builder: (bc) => PaymentDialog(fareAmount: (bidAmount ?? fare).toStringAsFixed(0)),
        );
        tripStreamSubscription?.cancel();
        Restart.restartApp();
      }
    });
  }

  void cancelRideRequest() {
    tripRequestRef?.remove();
    tripStreamSubscription?.cancel();
    setState(() => _currentStep = 2);
  }

  // المان‌های گرافیکی زیبای شما
  void _showAdvancedProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 45, height: 4.5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 32, backgroundColor: Colors.grey[100], child: Icon(Icons.person, size: 42, color: safirColor)),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName.isEmpty ? 'کاربر سفیر' : userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(userPhone.isEmpty ? 'ثبت نشده' : userPhone, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_left, color: Colors.grey[600], size: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressField(String text, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(color: safirColor, fontSize: 14, overflow: TextOverflow.ellipsis))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: safirColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryTab(int categoryIndex, String label) {
    bool isCategorySelected = _selectedCategory == categoryIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { 
          _selectedCategory = categoryIndex; 
          _selectedVehicleType = 0;
          selectedVehicle = categoryIndex == 0 ? "Car" : "Bike";
          _getOSRMRoute();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isCategorySelected ? safirColor : Colors.transparent, width: 2))),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isCategorySelected ? safirColor : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHorizontalVehicleOption(int index, IconData icon, String title, String subtitle, String price, String vehicleTypeString) {
    bool isSelected = _selectedVehicleType == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedVehicleType = index;
        selectedVehicle = vehicleTypeString;
        _getOSRMRoute();
      }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? safirColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? safirColor : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 10),
                Icon(icon, color: safirColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appInfo = Provider.of<AppInfoClass>(context);
    String currentOrigin = appInfo.pickUpLocation != null ? appInfo.pickUpLocation!.placeName! : "در حال دریافت موقعیت شما...";
    String currentDestination = appInfo.dropOffLocation != null ? appInfo.dropOffLocation!.placeName! : "مقصد خود را انتخاب کنید";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ویجت عالی و ۱۰۰٪ رایگان FlutterMap (جایگزین کل لایه گوگل مپ)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentUserLatLng,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safir.user_app',
                ),
                if (_routePolylinePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePolylinePoints,
                        strokeWidth: 5.0,
                        color: safirColor,
                      ),
                    ],
                  ),
              ],
            ),

            // دکمه‌های شناور شیک شما
            Positioned(
              top: 50, left: 20,
              child: FloatingActionButton(
                heroTag: 'profile_btn', mini: true, backgroundColor: Colors.white,
                onPressed: _showAdvancedProfile,
                child: Icon(Icons.person, color: safirColor),
              ),
            ),
            Positioned(
              top: 50, right: 20,
              child: FloatingActionButton(
                heroTag: 'home_btn', mini: true, backgroundColor: Colors.white,
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.home, color: safirColor),
              ),
            ),

            // لایه‌های شرطی زیبای استپ‌های شما کاملاً متصل به سیستم جدید OSRM
            if (_currentStep == 0)
              Positioned(
                bottom: 30, left: 15, right: 15,
                child: Column(
                  children: [
                    _buildAddressField(currentOrigin, Icons.circle, safirColor, () {}),
                    const SizedBox(height: 12),
                    _buildBottomButton('تایید مبدأ و ادامه', () => setState(() => _currentStep = 1)),
                  ],
                ),
              ),

            if (_currentStep == 1)
              Positioned(
                bottom: 30, left: 15, right: 15,
                child: Column(
                  children: [
                    _buildAddressField(currentDestination, Icons.location_on, Colors.red, () async {
                      var response = await Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchDestinationPlace()));
                      if (response == "placeSelected") {
                        await _getOSRMRoute();
                        setState(() => _currentStep = 2);
                      }
                    }),
                    const SizedBox(height: 12),
                    _buildBottomButton('انتخاب مقصد روی نقشه', () async {
                      var response = await Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchDestinationPlace()));
                      if (response == "placeSelected") {
                        await _getOSRMRoute();
                        setState(() => _currentStep = 2);
                      }
                    }),
                  ],
                ),
              ),

            if (_currentStep == 2)
              Positioned(
                bottom: 25, left: 15, right: 15,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _buildCategoryTab(1, 'موترسایکل'),
                          _buildCategoryTab(0, 'موتر'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedCategory == 0) ...[
                        _buildHorizontalVehicleOption(0, Icons.local_taxi, 'سير اقتصادی', 'ارزان و سریع', '${actualFareAmount.toStringAsFixed(0)} افغانی', 'Car'),
                        const SizedBox(height: 8),
                        _buildHorizontalVehicleOption(1, Icons.electric_car, 'سفير ویژه', 'لوکس و راحت', '${(actualFareAmount * 1.4).toStringAsFixed(0)} افغانی', 'Auto'),
                      ] else ...[
                        _buildHorizontalVehicleOption(0, Icons.motorcycle, 'سفير موتور', 'عبور از ترافیک', '${(actualFareAmount * 0.5).toStringAsFixed(0)} افغانی', 'Bike'),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BidDialogWidget(
                              initialFareAmount: actualFareAmount,
                              onBidAmountChanged: (amount) => setState(() => bidAmount = amount),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBottomButton('درخواست سفیر', () {
                        setState(() => _currentStep = 3);
                        makeTripRequest();
                      }),
                    ],
                  ),
                ),
              ),

            if (_currentStep == 3)
              Positioned(
                bottom: 25, left: 15, right: 15,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.flickr(leftDotColor: safirColor, rightDotColor: Colors.orangeAccent, size: 50),
                      const SizedBox(height: 15),
                      const Text('در حال ارسال درخواست به نزدیک‌ترین سفیران...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => cancelRideRequest(),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                          child: const Text('لغو درخواست', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            if (_currentStep == 4)
              Positioned(
                bottom: 25, left: 15, right: 15,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tripStatusDisplay.isEmpty ? "سفیر در حال حرکت به سمت شماست" : tripStatusDisplay, style: TextStyle(color: safirColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => launchUrl(Uri.parse("tel://$phoneNumberDriver")),
                            icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: safirColor), child: const Icon(Icons.phone, color: Colors.white)),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(nameDriver, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(carDetailsDriver, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(width: 12),
                              ClipOval(
                                child: Image.network(
                                  photoDriver.isEmpty ? "https://firebasestorage.googleapis.com/v0/b/everyone-2de50.appspot.com/o/avatarman.png?alt=media" : photoDriver,
                                  width: 50, height: 50, fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
