import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/main.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/widgets/prediction_place_ui.dart';

class SearchDestinationPlace extends StatefulWidget {
  const SearchDestinationPlace({super.key});

  @override
  State<SearchDestinationPlace> createState() => _SearchDestinationPlaceState();
}

class _SearchDestinationPlaceState extends State<SearchDestinationPlace> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();

  List<PredictionModel> dropOffPredictionsPlacesList = [];
  final Color safirColor = const Color(0xFF145A41);

  // جستجوی رایگان و بومی‌سازی شده بر پایه OpenStreetMap Nominatim
  searchLocation(String locationName) async {
    if (locationName.length > 2) {
      // آدرس سرور رایگان Nominatim با فیلتر کشور افغانستان و زبان دری/پشتو
      String apiPlacesUrl =
          "https://nominatim.openstreetmap.org/search?q=$locationName&format=json&addressdetails=1&countrycodes=af&accept-language=fa,ps,en&limit=10";

      print('OSM SEARCH URL: $apiPlacesUrl');

      var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(apiPlacesUrl);

      if (responseFromPlacesAPI == "error" || responseFromPlacesAPI == null) {
        return;
      }

      // پاسخ Nominatim به صورت یک لست جی‌سان مستقیم ارسال می‌شود
      if (responseFromPlacesAPI is List) {
        List<PredictionModel> predictionsList = [];

        for (var eachPlace in responseFromPlacesAPI) {
          // تبدیل ساختار داده نقشه باز به فرمت مورد انتظار PredictionModel قدیمی اوبر شما
          Map<String, dynamic> googleFormatMap = {
            "place_id": eachPlace["place_id"].toString(),
            "main_text": eachPlace["display_name"].toString().split(',')[0], // نام مکان
            "secondary_text": eachPlace["display_name"].toString(), // آدرس کامل
            // ذخیره طول و عرض جغرافیایی برای استفاده در زمان انتخاب لوکیشن
            "latitude": eachPlace["lat"],
            "longitude": eachPlace["lon"]
          };

          predictionsList.add(PredictionModel.fromJson(googleFormatMap));
        }

        if (mounted) {
          setState(() {
            dropOffPredictionsPlacesList = predictionsList;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfoClass>(context, listen: false)
            .pickUpLocation!
            .humanReadableAddress ??
        '';

    pickUpTextEditingController.text = userAddress;
    mq = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 25),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: safirColor,
                                ),
                              ),
                              Center(
                                child: Text(
                                  "انتخاب مقصد سفر",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: safirColor),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 25),
                          
                          // فیلد مبدأ
                          Row(
                            children: [
                              Icon(Icons.circle, color: safirColor, size: 16),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: TextField(
                                      controller: pickUpTextEditingController,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: "موقعیت فعلی (مبداء)",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // فیلد مقصد کاربری سفیر
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 18),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: safirColor.withOpacity(0.3), width: 1)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: TextField(
                                      controller: destinationTextEditingController,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      onChanged: (value) {
                                        searchLocation(value);
                                      },
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: "کجا می‌روید؟ (جستجوی مقصد)",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // نمایش لیست مکان‌های پیش‌بینی شده
                (dropOffPredictionsPlacesList.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.withOpacity(0.1))
                              ),
                              child: PredictionPlaceUI(
                                predictedPlaceData: dropOffPredictionsPlacesList[index],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4),
                          itemCount: dropOffPredictionsPlacesList.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
