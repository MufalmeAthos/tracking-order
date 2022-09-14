import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation  = LatLng(-1.94080926, 30.04492188);
  static const LatLng destination     = LatLng(-1.91349383, 30.08710055);

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async{
    PolylinePoints polylinepoints   = PolylinePoints();
    PolylineResult result           = await polylinepoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
            (PointLatLng point) {
              polylineCoordinates.add(
                LatLng(point.latitude, point.longitude),
              );
            }
      );
      setState(() {

      });

    }
    print('OKLM:::::');
    print(polylineCoordinates.length);
    print(result.points.length);
    print('OKLM:::::');

  }
  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    getPolyPoints();
    // print('OKLM:::::');
    // print(polylineCoordinates.length);
    // print(.length);
    // print('OKLM:::::');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:  Center(
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: sourceLocation,
            zoom: 13,
          ),
          polylines: {
            Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: primaryColor,

            ),
          },
          markers: {
           const Marker(
              markerId: MarkerId('source'),
              position: sourceLocation,
            ),
            const Marker(
              markerId: MarkerId('destination'),
              position: destination,
            ),
          },
        ),
      ),
    );
  }
}
