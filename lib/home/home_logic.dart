import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/utils/poly_utils.dart';
import 'package:location/location.dart';
import 'package:my_widgets/my_widgets.dart';


class HomeLogic extends GetxController{

  final key = 'AIzaSyBa7pya_ecwQ2_Wye5kOE5bgbB7nyf38cw';
  LocationData? currentPosition;
  final Completer<GoogleMapController> controller = Completer();
  StreamSubscription<GeofenceStatus>? geofenceStatusStream;
  static LatLng? latLng;


  final CameraPosition initialLatLong = const CameraPosition(
    target: LatLng(51.525426, -0.109025),
    zoom: 14.4746,
  );

  String geofenceStatus = 'Nothing yet';
  EasyGeofencing easyGeofencing = EasyGeofencing();
  final Set<Polygon> ulezPolygons = {};
  final Set<Marker> markers = {};

  bool isLoading = true;
  String status = '';

  final latitude = TextEditingController();
  final longitude = TextEditingController();

  Future<void> _loadUlez() async {
    String data = await DefaultAssetBundle.of(Get.context!).loadString('assets/ulez.geojson');
    Map<String, dynamic> json = convert.jsonDecode(data);
    List<dynamic> features = json['features'];
    for (var feature in features) {
      Map<String, dynamic> geometry = feature['geometry'];
      List<dynamic> coordinates = geometry['coordinates'][0];
      List<LatLng> polygonCoordinates = [];
      for (var coord in coordinates) {
        polygonCoordinates.add(LatLng(coord[1], coord[0]));
      }
      ulezPolygons.add(Polygon(
        polygonId: const PolygonId('ULEZ'),
        points: polygonCoordinates,
        strokeWidth: 2,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.2),
      ));
    }
    update();
  }



  @override
  void onInit() {
    callInit(const LatLng(51.525426, -0.109025));
    super.onInit();
  }

  Future<void> callInit(LatLng latLng) async {
    await  _loadUlez();
    await checkUserLocation(latLng);
    isLoading = false;
    update();
  }

  getUserLocation() async {
    currentPosition = await getLocationPermission();
    goToCurrentPosition(LatLng(currentPosition?.latitude ?? 0.0, currentPosition?.longitude ?? 0.0));
    update();
  }


  Future<void> goToCurrentPosition(LatLng latlng) async {
    final GoogleMapController controllers = await controller.future;
    controllers.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(latlng.latitude, latlng.longitude),
          zoom: 14.4746,
        ),
      ),
    );
  }



  Future<LocationData> getLocationPermission() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Service Not Enabled');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Permission Denied');
      }
    }

    locationData = await location.getLocation();
    latLng = LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    update();
    return locationData;
  }



  Future<void> checkUserLocation(LatLng userLocation) async {

    Point point = Point(userLocation.latitude, userLocation.longitude);
    List<Point> points = [];
    if (ulezPolygons.isEmpty) {
      debugPrint('List is empty');
    } else {
      for (Polygon polygon in ulezPolygons) {
        List<LatLng> polygonPoints = polygon.points;
        for (LatLng latLng in polygonPoints) {
          points.add(Point(latLng.latitude, latLng.longitude));
        }
      }
      if(PolyUtils.containsLocationPoly(point, points)){
        geofenceStatus = 'Alert!. Your are inside the ULEZ';
        markers.add(Marker(
          markerId: const MarkerId("userLocation"),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
        update();

      }else{
        geofenceStatus = 'Outside the ULEZ';
        markers.add(Marker(
          markerId: const MarkerId("userLocation"),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        update();
      }
    }

  }



  Future<void> onCheckTap() async {
    isLoading = true;
    update();
    if(latitude.text.isNotEmpty && longitude.text.isNotEmpty){
      await callInit(LatLng(double.parse(latitude.text), double.parse(longitude.text)));
      print(geofenceStatus);
      print(latitude.text);
      print(longitude.text);
    }else{
      pShowToast(message: 'Please provide latitude and longitude');
    }

  }
}







// geoFencing(){
//   EasyGeofencing.startGeofenceService(
//       pointedLatitude: '51.511727',
//       pointedLongitude: '-0.121111',
//       radiusMeter: '0',
//       eventPeriodInSeconds: 5);
//   geofenceStatusStream ??= EasyGeofencing.getGeofenceStream()!.listen((GeofenceStatus status) {
//     debugPrint(status.toString());
//     geofenceStatus = status.toString();
//     update();
//   });
// }