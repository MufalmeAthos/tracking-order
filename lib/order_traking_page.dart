import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController>  _controller = Completer();

  static const LatLng sourceLocation  = LatLng(-1.94080926, 30.04492188);
  static const LatLng destination     = LatLng(-1.91349383, 30.08710055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getPolyPoints() async{
    PolylinePoints polylinePoints   = PolylinePoints();
    PolylineResult result           = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      wayPoints: [
        PolylineWayPoint(location: '-1.91954277, 30.05622670'),
      ]
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
            (PointLatLng point) {
              polylineCoordinates.add(
                LatLng(point.latitude, point.longitude),
              );
            }
      );
      setState(() { });

    }
  }

  void getCurrentLocation() async{
    Location location = Location();
    location.getLocation().then(
      (location){
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc){
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(newLoc.latitude!,newLoc.longitude!),
            ),
          ),
        );
        setState(() { });
      },
    );
  }

  void setCustomMarkerIcon () {
    BitmapDescriptor
        .fromAssetImage(ImageConfiguration.empty, 'assets/Pin_source.png')
        .then((icon) => sourceIcon = icon );
    BitmapDescriptor
        .fromAssetImage(ImageConfiguration.empty, 'assets/Pin_destination.png')
        .then((icon) => destinationIcon = icon );
    BitmapDescriptor
        .fromAssetImage(ImageConfiguration.empty, 'assets/Badge.png')
        .then((icon) => currentLocationIcon = icon );
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:  currentLocation == null
      ? Center(child: Text("Loading..."),)
      : Center(
        child: GoogleMap(
          initialCameraPosition:  CameraPosition(
            target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 13  ,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: primaryColor,
              width: 8
            ),
          },
          markers: {
            Marker(
              markerId: MarkerId('currentLocation'),
              icon: currentLocationIcon,
              position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            ),
            Marker(
              markerId: MarkerId('source'),
              icon: sourceIcon,
              position: sourceLocation,
            ),
            Marker(
              markerId: MarkerId('destination'),
              icon: destinationIcon,
              position: destination,
            ),
          },
          onMapCreated: (mapController){
            _controller.complete(mapController);
          },
        ),
      ),
    );
  }
}
