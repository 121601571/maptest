import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<dynamic> clist = new List();
  List<Marker> markers = new List();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    // TODO: implement initState
    getList();

    super.initState();
  }

  void getList() async{

    Dio dio = new Dio();
    Response response;

    try {
      response =
      await dio.get('https://corp-support.cn' + "/rest/listcompany2" );
    } on DioError catch (e) {
      if (e.response != Null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    Map<String, dynamic> info = json.decode(response.data);
    print(info);
    if (info['code'] != 0) {
    } else {
      setState(() {
        clist = info['data'];
      });
    }

    updateMark();
  }

  Future _showInfo(Map a1){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return CupertinoAlertDialog(
          title: Text('公司信息'),
          content: Column(
            children: <Widget>[
              Text(a1['name']),
              Text(a1['address']),
              Text(a1['contact']),
              Text(a1['tel']),
              Text(a1['code']),

            ],

          ),
          actions:<Widget>[


            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );



  }
  void updateMark(){
    markers.clear();
    for(Map a1 in clist){
      var m1 = Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(a1['lat'], a1['lon']),
        builder: (ctx) => Container(
            child: GestureDetector(
              onTap: () {
                //print('123');
                _showInfo(a1);
              },
              child: Icon(Icons.account_balance),
            )),
       // builder: (ctx) => Icon(Icons.wifi_tethering),
      );
      markers.add(m1);

  }
    setState(() {
      markers = List.from(markers);
    });

  }

  double dynSize(int n ){
    double f1 = n /30;
    double r1 = 1 + f1;
    if (r1 >= 2){
      r1 = 2;
    }
    return r1;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('map test')
      ),
      body:

      FlutterMap(
        options: new MapOptions(
          center:  LatLng(31,121.3),
          zoom: 9,
          plugins: [
            MarkerClusterPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
//           MarkerLayerOptions(
//            markers: [
//              new Marker(
//                width: 80.0,
//                height: 80.0,
//                point: new LatLng(51.5, -0.09),
//                builder: (ctx) => Container(
//                    child: GestureDetector(
//                      onTap: () {
//                        print('123');
//                      },
//                      child: FlutterLogo(),
//                    )),
//
//              ),
//            ],
//          ),


          MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: Size(40, 40),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: markers,
            polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3),
            builder: (context, markers) {
//              return FloatingActionButton(
//                child: Text(markers.length.toString()),
//                onPressed: null,
//              );
             return Transform.scale(scale: dynSize(markers.length),
              child: FloatingActionButton(
                onPressed: () {
                  print('cluster');
                },
                child: Text(markers.length.toString()),

              ),
             );

            },
          ),
        ],
      ),
    );


  }
}