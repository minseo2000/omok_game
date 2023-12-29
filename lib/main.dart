import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omok/screen/omokList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';


void main() {

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp]
  ); // 세로 화면 고정

  Future<Database> database = initDatabase();

  runApp(
    MaterialApp(
      home: DatabaseApp(db: database),
      builder: EasyLoading.init(),
      title: 'Cat Mok',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/omokList' : (context) => OmokList(db: database,)
      },
    )
  );

  configLoading();
}

void configLoading(){
  EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 1000)
      ..fontSize = 16.0
      ..toastPosition = EasyLoadingToastPosition.center
      ..loadingStyle = EasyLoadingStyle.dark
      ..radius = 30.0;
}

Future<Database> initDatabase() async{
  return openDatabase(
    join(await getDatabasesPath(), 'omok_database.db'),
    onCreate: (db, version){
      return db.execute(
        "CREATE TABLE omoks(omokDate TEXT PRIMARY KEY, "
            "win INTEGER, tie INTEGER, defeat INTEGER, downCount INTEGER, score INTEGER",
      );
    },
    version: 1,
  );
}

class DatabaseApp extends StatefulWidget {

  final Future<Database> db;


  const DatabaseApp({Key? key, required this.db}) : super(key: key);

  @override
  State<DatabaseApp> createState() => _DatabaseAppState();
}

class _DatabaseAppState extends State<DatabaseApp> {


  final _player = AudioPlayer();
  bool? v_flagButtonPlay = true;

  String v_image_volume = 'assets/images/volume_on.png';
  bool v_volume = true;

  Future audioPlayer(parm_mp3) async {
    await _player.setAsset(parm_mp3);
    _player.play();
  }

  @override
  void dispose(){
    _player.stop();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('냥목', style: TextStyle(color: Colors.white, fontSize: 18),),
        actions: [
          ElevatedButton(
            onPressed: () async{
              if(v_flagButtonPlay == false){
                EasyLoading.instance.fontSize = 16;
                EasyLoading.instance.displayDuration = const Duration(milliseconds: 500);
                EasyLoading.showToast(' 실행되지 않았다냥!');
              }else{
                const url = 'https://simsimit00.tistory.com/';
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: Image.asset('asset/images/lock.png', height: 30, width: 25,),
          ),
          ElevatedButton(
            onPressed: (){
              if(v_volume == true){
                v_image_volume = 'assets/images/volume_off.png';
                v_volume = false;
              }else{
                v_image_volume = 'assets/images/volume_on.png';
                v_volume = true;
              }
              setState(() {

              });
            },
            child: Image.asset(v_image_volume, height: 22, width: 25,),
          ),
          ElevatedButton(
            onPressed: (){
              if(v_flagButtonPlay == true){
                Navigator.of(context).pushNamed('/omokList');
              }else{
                EasyLoading.instance.fontSize = 16;
                EasyLoading.instance.displayDuration = const Duration(milliseconds: 500);
                EasyLoading.showToast('실행되지 않았다냥!');
              }
            },
            child: const Text('기록 보기', style: TextStyle(color: Colors.white, fontSize: 13),),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
              height: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
              color: Colors.yellow,
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 63,
      ),
    );
  }



}

