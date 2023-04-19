import 'package:flutter/material.dart';
import 'package:geofencing/home/home_logic.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_widgets/widgets/btn.dart';
import 'package:my_widgets/widgets/dividers.dart';
import 'package:my_widgets/widgets/input.dart';
import 'package:my_widgets/widgets/txt.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeLogic>(
        init: HomeLogic(),
        builder: (logic){
          return Scaffold(
            body: logic.isLoading ? const Center(child: CircularProgressIndicator()): SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: Get.height * 0.6,
                    width: Get.width,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      polygons: logic.ulezPolygons,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      indoorViewEnabled: true,
                      buildingsEnabled: true,
                      // markers: logic.markers,
                      initialCameraPosition: logic.initialLatLong,
                      onMapCreated: (GoogleMapController controller) {
                        if(!logic.controller.isCompleted){
                          logic.controller.complete(controller);
                        }

                      },
                    ),
                  ),
                  const MyDivider(),
                  Text(logic.geofenceStatus),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      children:  [
                        Expanded(
                          child: TxtFormInput(
                            controller: logic.latitude,
                            hintText: 'Latitude',
                            hasBorder: true,
                            borderColor: Colors.black,
                          ),
                        ),
                        const MyVerticalDivider(),
                        Expanded(
                          child: TxtFormInput(
                            controller: logic.longitude,
                            hintText: 'Longitude',
                            hasBorder: true,
                            borderColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const MyDivider(),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Btn(
                        text: 'Check',
                        width: Get.width,
                        onPressed: logic.onCheckTap,
                        hasBorder: false,
                        hasBold: true,))
                ],
              ),
            ),
          );
        });
  }
}
