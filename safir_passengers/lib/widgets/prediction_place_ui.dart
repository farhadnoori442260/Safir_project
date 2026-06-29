import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/address_models.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/widgets/loading_dialog.dart';

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;

  const PredictionPlaceUI({super.key, this.predictedPlaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  
  // متد دریافت جزئیات لوکیشن انتخاب شده
  fetchClickedPlaceDetails(String placeId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const LoadingDialog(messageText: "در حال دریافت جزئیات موقعیت..."),
    );

    // ساختار آدرس گوگل مپ (آماده برای جایگزینی با API رایگان در آینده نزدیک)
    String urlPlaceDetailAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";
    
    var responseFromPlaceDetailsAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailAPI);

    if (!mounted) return;
    Navigator.pop(context); // بستن دیالوگ لودینگ

    if (responseFromPlaceDetailsAPI == "error") {
      print("خطا در برقراری ارتباط با سرور نقشه");
      return;
    }

    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      AddressModel dropOffLocation = AddressModel();

      dropOffLocation.placeName = responseFromPlaceDetailsAPI["result"]["name"];
      dropOffLocation.latitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeID = placeId;

      Provider.of<AppInfoClass>(context, listen: false).updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color safirColor = Color(0xFF145A41); // رنگ سبز اختصاصی سفیر

    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن کامل متن آدرس‌ها برای زبان‌های دری و پشتو
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.15)), // خط دور بسیار ظریف و لوکس همانند تم جدیدت
        ),
        child: InkWell(
          onTap: () {
            fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // آیکون موقعیت با رنگ برند سفیر
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: safirColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: safirColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                
                // متون آدرس‌ها
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaceData!.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, 
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.predictedPlaceData!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12, 
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // فلش راهنما در انتهای سمت چپ کارت
                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
