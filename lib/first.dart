import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coronavirus/map.dart';
import 'package:coronavirus/statics.dart';
import 'package:coronavirus/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  double lat;
  double lng;
  String infectText,language;
  String pre = '';
  Color infectColor;
  Color infectStColor;
  String finalPlace;
  bool infected;
  List<Placemark> placemark;
  String infectStatus;

  getStat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    infected = prefs.getBool('infected');
    language = prefs.getString('language');
    if(infected == false){
      setState(() {
        infectText = language=='English'?"Change status to... I'm Infected":"Cambiar estatus a... Estoy Infectado";
        infectStatus = language=='English'?"Not Infected":"No Infectado";
        infectColor = Color(0xffD32F2F);
        infectStColor = Colors.green;
      });
    }
    else{
      setState(() {
        infectText = language=='English'?"Change status to... I'm not Infected":"Cambiar estatus a... No estoy infectado";
        infectStatus = language=='English'?"Infected":"Infectado";
        infectColor = Color(0xff0D47A1);
        infectStColor = Color(0xffD32F2F);
      });
    }
  }

  getLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    lng = position.longitude;
    placemark = await Geolocator().placemarkFromCoordinates(lat, lng);
    print(placemark[0].locality);
    if(placemark[0].name!=''){
      finalPlace = placemark[0].name;
    }
    else if(placemark[0].subLocality!=''){
      finalPlace = placemark[0].subLocality;
    }
    else if(placemark[0].locality!=''){
      finalPlace = placemark[0].locality;
    }
    else if(placemark[0].subAdministrativeArea!=''){
      finalPlace = placemark[0].subAdministrativeArea;
    }
    else if(placemark[0].administrativeArea!=''){
      finalPlace = placemark[0].administrativeArea;
    }
    else{
      finalPlace = "N/A";
    }

  }

  _onAddMarkerButtonPressed() async {
    ToastBar(text: language=='English'?'Please wait...':'Por favor espera...',color: Colors.orange).show();
    await getLocation();
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var id = prefs.getString('id');
      String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
      Firestore.instance.collection('locations').add({
        'deviceId': id,
        'lat': lat,
        'long': lng,
        'place': finalPlace,
        'infected': false,
        'date': date
      });
      ToastBar(text: language=='English'?'Location Added!':'Ubicación agregada',color: Colors.green).show();
    }
    catch(e){
      ToastBar(text: language=='English'?'Something went wrong!':'Algo salió mal',color: Colors.red).show();
    }
  }

  onInfected() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    var subscription = await Firestore.instance.collection('locations').where('deviceId',isEqualTo: id).getDocuments();
    var locations = subscription.documents;
    for(int i=0;i<locations.length;i++){
      print(locations[i].data['date']);
      DateTime date = new DateFormat("yyyy-MM-dd").parse(locations[i].data['date']);
      var de = DateTime.now().difference(date).inDays;
      print(de);
      if(de<=14){
        try{
          Firestore.instance.collection('locations').document(locations[i].documentID).updateData({
            'infected': true
          });
          ToastBar(text: language=='English'?'Markers Added!':'Marcadores añadidos',color: Colors.green).show();
        }
        catch(e){
          ToastBar(text: language=='English'?'Something went wrong!':'Algo salió mal',color: Colors.red).show();
        }
      }
    }
  }

  onNotInfected() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    var subscription = await Firestore.instance.collection('locations').where('deviceId',isEqualTo: id).getDocuments();
    var locations = subscription.documents;
    for(int i=0;i<locations.length;i++){
      try{
          Firestore.instance.collection('locations').document(locations[i].documentID).updateData({
            'infected': false
          });
          ToastBar(text: language=='English'?'Data Updated!':'Datos actualizados',color: Colors.green).show();
        }
        catch(e){
          ToastBar(text: language=='English'?'Something went wrong!':'Algo salió mal',color: Colors.red).show();
        }

    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(language=='English'?"Confirm":"Confirmar"),
          content: new Text(language=='English'?"Are you sure you are$pre infected?":"Estás seguro de$pre estar infectado?"),
          actions: <Widget>[
            FlatButton(
              color: Theme.of(context).primaryColor,
              child: new Text(language=='English'?"Yes":"SI"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if(infected==false){
                  onInfected();
                  setState(() {
                      infectText = language=='English'?"Change status to... I'm not Infected":"Cambiar estatus a... No estoy infectado";
                      pre = ' not';
                      infected = true;
                      infectStatus = language=='English'?"Infected":"Infectado";
                      prefs.setBool('infected', true);
                      infectColor = Color(0xff0D47A1);
                      infectStColor = Color(0xffD32F2F);
                  });
                }else{
                  onNotInfected();
                  setState(() {
                    infectText = language=='English'?"Change status to... I'm Infected":"Cambiar estatus a... Estoy Infectado";
                    pre= '';
                    infected = false;
                    infectStatus = language=='English'?"Not Infected":"No Infectado";
                    prefs.setBool('infected', false);
                    infectColor = Color(0xffD32F2F);
                    infectStColor = Colors.green;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Theme.of(context).primaryColor,
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStat();
    //FirebaseAdMob.instance.initialize(appId: "ca-app-pub-5594600679324056~7501560549");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Alert',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.call_missed_outgoing), onPressed: ()=>_launchURL('https://coronavirus.app/'))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(width: double.infinity,),
            Padding(
              padding: const EdgeInsets.fromLTRB(10,15,10,0),
              child: Text(language=='English'?'When you are moving to new location please make sure to add it by tapping below button':
              'Cuando te muevas a una nueva localización asegúrate de pulsar el botón en la parte inferior',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),textAlign: TextAlign.center,),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0,15,0,10),
              child: GestureDetector(
                onTap: _onAddMarkerButtonPressed,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,
                  child: Text(language=='English'?'Add Your\nNew\nLocation':'Añadir\nNueva\nlocalizacion',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(language=='English'?"If you’re infected with the virus, immediately tap the this button":
              "Si tu estás infectado con el virus, inmediatamente pulsa el siguiente botón.",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),textAlign: TextAlign.center,),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0,10,0,0),
              child: Text(language=='English'?"Current Status: $infectStatus":
              "Estado actual: $infectStatus",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: infectStColor),textAlign: TextAlign.center,),
            ),
            infectText!=null?Padding(
              padding: const EdgeInsets.fromLTRB(15,10,15,30),
              child: GestureDetector(
                onTap: _showDialog,
                child: Container(
                  width: double.infinity,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: infectColor
                  ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(infectText,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),textAlign: TextAlign.center,),
                      ),
                    )
                ),
              ),
            ):CircularProgressIndicator(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: ()=>_launchURL('https://www.cdc.gov/coronavirus/2019-nCoV/index.html'),
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).primaryColor
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("CDC",
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),textAlign: TextAlign.center,),
                            ),
                          )
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: ()=>_launchURL('https://www.who.int/emergencies/diseases/novel-coronavirus-2019'),
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).primaryColor
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("WHO or OMS",
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),textAlign: TextAlign.center,),
                            ),
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(50,30,50,30),
              child: GestureDetector(
                onTap: ()=>_launchURL('https://drive.google.com/open?id=107vp0DfuOLwrZnOLGBB2kRc4Yo2Nm3OO'),
                child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).primaryColor
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.help,color: Colors.white,),
                          SizedBox(width: 10,),
                          Text(language=='English'?"How to use the app":"Como usar la App",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,),
                        ],
                      ),
                    )
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          ToastBar(text: language=='English'?'Loading...':'Cargando...',color: Colors.orange).show();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => MapPage()),
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
                                Icon(Icons.map,color: Theme.of(context).primaryColor,),
                                SizedBox(width: 5,),
                                Text(language=='English'?'Map':'Mapa',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 18),)
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

          ],
        ),
      ),
    );
  }
}
