import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coronavirus/statics.dart';
import 'package:coronavirus/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MapPage extends StatefulWidget {
  final double lat;
  final double long;

  const MapPage({Key key, this.lat, this.long}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {


  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  var markerlist;
TextEditingController search = TextEditingController();

    cameraMove() async {
      if(widget.lat!=null){
        CameraPosition newpos = CameraPosition(
            target: LatLng(widget.lat, widget.long),
            zoom: 18);

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(newpos));
      }
    }


  CameraPosition initPoint;
double lat,lng;
String language;


getLanguage() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  language = prefs.getString('language');

  setState(() {});
}


  getLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    lng = position.longitude;

    setState(() {
      initPoint = CameraPosition(target: LatLng(lat, lng),zoom: 8);
    });

  }



  onStart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('id');
    var sub =await Firestore.instance.collection('locations').where('deviceId',isEqualTo: id).getDocuments();
    setState(() {
      markerlist = sub.documents;
    });

    if(markerlist!=null){
      for(int i=0;i<markerlist.length;i++){
            setState(() {
      _markers.add(
          Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(LatLng(markerlist[i].data['lat'], markerlist[i].data['long']).toString()),
        position: LatLng(markerlist[i].data['lat'], markerlist[i].data['long']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: markerlist[i].data['place'],
          snippet: markerlist[i].data['date']
        )
      ));
    });
      }
    }
  }


  infectedMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    print(id);
    var sub = await Firestore.instance.collection('locations').where('deviceId',isEqualTo: id).getDocuments();
    var locationlist = sub.documents;

    for(int i=0;i<locationlist.length;i++){
      DateTime date = new DateFormat("yyyy-MM-dd").parse(locationlist[i].data['date']);
      var de = DateTime.now().difference(date).inDays;
      print(de);
      if(de<=14){
        var sub2 = await Firestore.instance.collection('locations')
            .where('infected',isEqualTo: true)
            .where('date',isEqualTo: locationlist[i].data['date'])
            .where('place', isEqualTo: locationlist[i].data['place'])
            .getDocuments();
        var myloc = sub2.documents;
        if(myloc.isEmpty){
          print('not infected on - ${locationlist[i].data['date']} at ${locationlist[i].data['place']}');
        }
        else{
          print('Infected on - ${locationlist[i].data['date']} at ${locationlist[i].data['place']}');
          setState(() {
            _markers.add(
                Marker(
                  // This marker id can be anything that uniquely identifies each marker.
                    markerId: MarkerId(LatLng(markerlist[i].data['lat'], markerlist[i].data['long']).toString()),
                    position: LatLng(markerlist[i].data['lat'], markerlist[i].data['long']),
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(
                        title: markerlist[i].data['place'],
                        snippet: markerlist[i].data['date']
                    )
                ));
          });
        }
      }
    }
  }
  
  DateTime selectedDate = DateTime.now();
  String defaultDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2019, 10),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        defaultDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        print(defaultDate);
      });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onStart();
    getLocation();
    getLanguage();
    cameraMove();
    //FirebaseAdMob.instance.initialize(appId: "ca-app-pub-5594600679324056~7501560549");
  }

var selected = 'Recorded';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          initPoint!=null?GoogleMap(
            mapType: MapType.normal,
            rotateGesturesEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: initPoint,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ):Center(child: CircularProgressIndicator(),),


          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15,50,0,0),
              child: CupertinoSlidingSegmentedControl(
                children: {
                  'Recorded': Text(language=='English'?'Recorded':'Todos',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
                  'Contacted': Text(language=='English'?'Contacted':'Contacto',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
                },
                onValueChanged: (value) {
                  setState(() {
                    selected = value;
                  });

                  print(selected);
                  if(selected == 'Contacted'){
                    print('contacted called');
                    infectedMarkers();
                  }
                  else{
                    print('recorded called');
                    setState(() {
                      _markers.clear();
                    });
                    onStart();
                  }
                  },
                groupValue: selected,
                thumbColor: Color(0xff0D47A1),
                backgroundColor: Color(0xffD32F2F),

              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.home,color: Theme.of(context).primaryColor,),
                                SizedBox(width: 5,),
                                Text(language=='English'?'Home':'Inicio',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 18),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap: (){
                          ToastBar(text: language=='English'?'Loading...':'Cargando...',color: Colors.orange).show();
                          //myInterstitial..load()..show();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => Statics()),
                          );
                        },
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.assignment,color: Theme.of(context).primaryColor,),
                                SizedBox(width: 5,),
                                Text(language=='English'?'Statics':'Estadística',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 18),)
                              ],
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

        ],
      ),
    );
  }
}
