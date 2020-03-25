import 'package:coronavirus/first.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';




class Terms extends StatefulWidget {
  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> with SingleTickerProviderStateMixin {

//  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//    keywords: <String>[],
//    childDirected: false,
//    testDevices: <String>[], // Android emulators are considered test devices
//  );
//  InterstitialAd myInterstitial = InterstitialAd(
//    adUnitId: InterstitialAd.testAdUnitId,
//    targetingInfo: targetingInfo,
//    listener: (MobileAdEvent event) {
//      print("InterstitialAd event is $event");
//    },
//  );


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

    //FirebaseAdMob.instance.initialize(appId: "ca-app-pub-5594600679324056~7501560549");
  }

  void checkGPS() async{
    bool serviceStatus = await Geolocator().isLocationServiceEnabled();
    if(serviceStatus==true){
    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context){
     // myInterstitial..load()..show();
      return FirstPage();}));
  }
  else{
          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => NotConnected()));
  }
  }
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50,),
              Padding(
                padding: EdgeInsets.all(30),
                child: Image.asset('images/logo.jpg'),
              ),
              
              CupertinoSlidingSegmentedControl(
                children: {
                  0: Text('English',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
                  1: Text('Spanish',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
                },
                onValueChanged: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                groupValue: selectedIndex,
                thumbColor: Color(0xff0D47A1),
                backgroundColor: Color(0xffD32F2F),

              ),
              selectedIndex==0?
              Column(
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text('Terms and Conditions\n(Summary)',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('This App is intended to prevent COVID-19 to continue spreading.'
                        ' It warns people if they have in contact in the past with someone that has been declared as infected.'
                        ' It is very important to use it wisely and responsibly to have accurate data to be more reliable (It is not a game)COVID Alert is not responsible of the data recorded by the users.'
                        ' The data provided by this app is only intended to inform and not to create panic, health issues or financial issues.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  GestureDetector(
                      onTap: ()=>_launchURL('https://drive.google.com/open?id=1V5TU-zkxd6jg5uD8wnQDfPmmJ7Ppa3Wg'),
                      child: Text('Complete Terms and Conditions',style: TextStyle(fontSize: 16,color: Colors.blue,decoration: TextDecoration.underline),
                      )
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('language', 'English');
                      checkGPS();
                    },
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xffD32F2F)
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("I accept this terms and conditions",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,),
                          ),
                        )
                    ),
                  ),
                ],
              )
                  :
              Column(
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text('Terminos y condiciones\n(Resumen)',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Esta aplicación está diseñada para evitar que COVID-19 continúe propagándose.'
                        ' Advierte a las personas si tienen contacto en el pasado con alguien que ha sido declarado infectado.'
                        ' Es muy importante usarlo sabia y responsablemente para tener datos precisos para ser más confiables (no es un juego). '
                        '\nCOVID Alert no se hace responsable de los datos registrados por los usuarios.'
                        ' Los datos proporcionados por esta aplicación solo tienen como objetivo informar y no crear pánico, problemas de salud o problemas financieros. '
                        'El uso de esta aplicacion es de quien lo usa.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  GestureDetector(
                      onTap: ()=>_launchURL('https://drive.google.com/open?id=1JgzeVJDby96O1QmAhc5w9r25GecjWy8J'),
                      child: Text('Terminos y condiciones completos.',style: TextStyle(fontSize: 16,color: Colors.blue,decoration: TextDecoration.underline),
                      )
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('language', 'Spanish');
                      checkGPS();
                    },
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xffD32F2F)
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("Acepto estos términos y condiciones",
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}








class NotConnected extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              Container(padding:const EdgeInsets.symmetric(horizontal: 10.0),child: new Text("Please enable Location!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),textAlign: TextAlign.center,)),
              Padding(padding: const EdgeInsets.all(10.0),),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Image(image: new AssetImage("images/gps.png"),),
              ),
              new RaisedButton(onPressed: () async {

                bool serviceStatus = await Geolocator().isLocationServiceEnabled();
                if(serviceStatus==true){
                  Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context){
                    //myInterstitial..load()..show();
                    return FirstPage();}));
                }


                },
                  child: Text("Try Again",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                  color: Color(0xff0D47A1))
            ],
          ),
        ),
      ),
    );
  }
}
