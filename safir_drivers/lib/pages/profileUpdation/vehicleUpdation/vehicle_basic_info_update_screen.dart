import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safir_drivers/providers/registration_provider.dart'; // اصلاح نام پکیج پروژه سفیر

import '../../../global/global.dart';

class VehicleBaiscInfoUpdateScreen extends StatefulWidget {
  const VehicleBaiscInfoUpdateScreen({super.key});

  @override
  State<VehicleBaiscInfoUpdateScreen> createState() =>
      _VehicleBaiscInfoUpdateScreenState();
}

final _formKey = GlobalKey<FormState>();

class _VehicleBaiscInfoUpdateScreenState
    extends State<VehicleBaiscInfoUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF145A41); // رنگ سبز برند سفیر

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "اطلاعات موتر",
            style: TextStyle(fontFamily: 'IranYekan', fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "بستن",
              style: TextStyle(fontFamily: 'IranYekan', color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          leadingWidth: 70,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              onChanged: () {
                registrationProvider.checkVehicleBasicFormValidity();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // کارت انتخاب نوع وسیله نقلیه
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          activeColor: brandColor,
                          title: Row(
                            children: [
                              Image.asset(
                                "assets/vehicles/home_car.png",
                                height: 50,
                                width: 100,
                              ),
                              const SizedBox(width: 10),
                              const Text("موتر (Car)", style: TextStyle(fontFamily: 'IranYekan', fontSize: 14)),
                            ],
                          ),
                          value: registrationProvider.selectedVehicle == "Car",
                          onChanged: (bool? value) {
                            if (value == true) {
                              registrationProvider.setSelectedVehicle("Car");
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        CheckboxListTile(
                          activeColor: brandColor,
                          title: Row(
                            children: [
                              Image.asset(
                                "assets/vehicles/bike.png",
                                height: 50,
                                width: 100,
                              ),
                              const SizedBox(width: 10),
                              const Text("موتوربایک (Bike)", style: TextStyle(fontFamily: 'IranYekan', fontSize: 14)),
                            ],
                          ),
                          value: registrationProvider.selectedVehicle == "Bike",
                          onChanged: (bool? value) {
                            if (value == true) {
                              registrationProvider.setSelectedVehicle("Bike");
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        CheckboxListTile(
                          activeColor: brandColor,
                          title: Row(
                            children: [
                              Image.asset(
                                "assets/vehicles/auto.png",
                                height: 50,
                                width: 100,
                              ),
                              const SizedBox(width: 10),
                              const Text("ریکشا / سه چرخ (Auto)", style: TextStyle(fontFamily: 'IranYekan', fontSize: 14)),
                            ],
                          ),
                          value: registrationProvider.selectedVehicle == "Auto",
                          onChanged: (bool? value) {
                            if (value == true) {
                              registrationProvider.setSelectedVehicle("Auto");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // فیلدهای متنی مشخصات موتر
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: registrationProvider.brandController,
                          decoration: const InputDecoration(
                            labelText: 'نام برند / مدل موتر',
                            labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'وارد کردن نام برند الزامی است';
                            }
                            return null;
                          },
                          onChanged: (_) => registrationProvider.checkVehicleBasicFormValidity(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: registrationProvider.colorController,
                          decoration: const InputDecoration(
                            labelText: 'رنگ موتر',
                            labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'وارد کردن رنگ الزامی است';
                            }
                            return null;
                          },
                          onChanged: (_) => registrationProvider.checkVehicleBasicFormValidity(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: registrationProvider.productionYearController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'سال تولید',
                            labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'وارد کردن سال تولید الزامی است';
                            }
                            return null;
                          },
                          onChanged: (_) => registrationProvider.checkVehicleBasicFormValidity(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: registrationProvider.numberPlateController,
                          decoration: const InputDecoration(
                            labelText: 'شماره پلیت (اسناد)',
                            labelStyle: TextStyle(fontFamily: 'IranYekan', fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'وارد کردن شماره پلیت الزامی است';
                            }
                            return null;
                          },
                          onChanged: (_) => registrationProvider.checkVehicleBasicFormValidity(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // دکمه آپدیت اطلاعات
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.93,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationProvider.isVehicleBasicFormValid &&
                              registrationProvider.isLoading == false
                          ? () async {
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  await registrationProvider
                                      .updateVehicleBasicInfo(context);
                                  commonMethods.displaySnackBar(
                                      "اطلاعات موتر شما موفقانه به‌روزرسانی شد", context);
                                } catch (e) {
                                  print("Error while saving data: $e");
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: registrationProvider.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'به‌روزرسانی اطلاعات',
                              style: TextStyle(fontFamily: 'IranYekan', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
