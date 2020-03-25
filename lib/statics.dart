import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coronavirus/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statics extends StatefulWidget {

  @override
  _StaticsState createState() => _StaticsState();
}

class _StaticsState extends State<Statics> {
  var myloc;
  List locationList = [];
  List dateList=[];
  String language;
  List recordedList = [];
  List recordedTimeList = [];
  List latRec = [];
  List longRec = [];
  List latCon = [];
  List longCon = [];


  getSheet() async {
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
        recordedList.add(locationlist[i].data['place']);
        latRec.add(locationlist[i].data['lat']);
        longRec.add(locationlist[i].data['long']);
        recordedTimeList.add(locationlist[i].data['date']);
        var sub2 = await Firestore.instance.collection('locations')
            .where('infected',isEqualTo: true)
            .where('date',isEqualTo: locationlist[i].data['date'])
            .where('place', isEqualTo: locationlist[i].data['place'])
            .getDocuments();
         myloc = sub2.documents;
        if(myloc.isEmpty){
          print('not infected on - ${locationlist[i].data['date']} at ${locationlist[i].data['place']}');
        }
        else{
          print('Infected on - ${locationlist[i].data['date']} at ${locationlist[i].data['place']}');
          setState(() {
            latCon.add(locationlist[i].data['lat']);
            longCon.add(locationlist[i].data['long']);
            locationList.add(locationlist[i].data['place']);
            dateList.add(locationlist[i].data['date']);  
          });
        }
      }
    }
  }

  getLanguage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString('language');
    setState(() {});
    print(language);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSheet();
    getLanguage();
  }

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language=='English'?'Statics':'Estadística',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20,),
          CupertinoSlidingSegmentedControl(
            children: {
              0: Text('Contacted',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
              1: Text('Recorded',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),),
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
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(language=='English'?'This is the places that you and  infected people contact with each others':
                    'Este lugar no estuvo infectado en la fecha seleccionada!'
                    ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),

                locationList!=null?Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locationList.length,
                    itemBuilder: (context,i){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20,10,20,0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (context) => MapPage(lat: latCon[i],long: longCon[i],)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).accentColor
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text('${dateList[i]}     ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                  Text(locationList[i],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ):CircularProgressIndicator()


              ],
            ),
          )
          :
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(language=='English'?'This is the places that you have spent your time':
                  'Estos son los lugares donde has pasado tu tiempo'
                    ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),

                recordedList!=null?Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: recordedList.length,
                    itemBuilder: (context,i){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20,10,20,0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (context) => MapPage(lat: latRec[i],long: longRec[i],)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text('${recordedTimeList[i]}     ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                  Text(recordedList[i],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ):CircularProgressIndicator()


              ],
            ),
          ),
        ],
      ),
    );
  }
}

