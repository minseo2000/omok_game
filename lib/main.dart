import 'dart:async';

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

  // 바둑판 배열
  final v_listBox = List.generate(15, (i) => List.generate(15, (j)=> ''));
  final v_listBox_count = List.generate(15, (i) => List.generate(15, (j) => ''));

  //게임판을 누르면 바둑판에 돌을 넣기
  void step_downStone(x, y){
    print('zmf');
    if(v_flagButtonPlay == true) return;
    if(v_listBox[x][y] == 'n'){
      v_listBox[x][y] = v_down;
      v_downCount++;
      v_listBox_count[x][y] = 'O';
      v_listBox_count[v_x_count][v_y_count] = '';
      v_x_count = x;
      v_y_count = y;
      setState(() {

      });
    }else{
      return;
    }
    (v_down == 'b') ? v_down = 'w' : v_down = 'b';
    v_x_previous = x;
    v_y_previous = y;
    v_x_AI = 15;
    v_y_AI = 15;

    Timer(Duration(seconds: 1), (){
      step_downStone_AI();
      v_downCount++;
      v_listBox_count[v_x_AI][v_y_AI] = 'O';
      v_listBox_count[v_x_count][v_y_count] = '';
      v_x_count = v_x_AI;
      v_y_count = v_y_AI;
      setState(() {

      });
      (v_down == 'b') ? v_down = 'w' : v_down = 'b';
    });
  }

  void step_downStone_AI(){
    if(v_downCount < 5){
      step_downStone_5downCount();
      if(v_x_AI != 15) return;
    }
    //step_downStone_AI4();
    if(v_x_AI != 15) return;

    //step_downStone_YOU4();
    if(v_x_AI != 15) return;

    //step_downStone_AI3();
    if(v_x_AI != 15) return;

    //step_downStone_YOU3();
    if(v_x_AI != 15) return;

    //step_downStone_attack();
    if(v_x_AI != 15) return;
  }

  void step_downStone_5downCount(){
    if(v_y_previous < 4 || v_y_previous > 10 || v_x_previous < 4 || v_x_previous > 10){
      if(v_listBox[7][7] == 'n'){
        v_x_AI = 7;
        v_y_AI = 7;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[6][7] == 'n'){
        v_x_AI = 6;
        v_y_AI = 7;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[7][6] =='n'){
        v_x_AI = 7;
        v_y_AI = 6;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[8][8] == 'n'){
        v_x_AI = 8;
        v_y_AI = 8;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }

      //p109
    }
  }

  void step_initial(){
    v_downCount = 0;
    for( i = 0; i< v_rowBox; i++){
      for(j = 0; j< v_colBox; j++){
        v_listBox[i][j] = 'n';
        v_listBox_count[i][j] = '';
      }
    }
    setState(() {

    });
  }

  void press_play(){
    v_flagButtonPlay = false;

    if(v_youStone == 'w'){
      v_listBox[7][7] = 'b';
      v_aiStone = 'b';
      v_downCount++;
      v_x_count = 7;
      v_y_count = 7;
      v_down = 'w';

    }else{
      v_down = 'b';
      v_aiStone = 'w';
    }
    setState(() {

    });
  }


  late int i;
  late int j;
  int v_rowBox = 15;
  int v_colBox = 15;
  int v_x_count = 0;
  int v_y_count = 0;
  String v_down = 'n';

  int v_x_previous = 15;
  int v_y_previous = 15;
  int v_x_AI = 15;
  int v_y_AI = 15;


  String v_youStone = 'n';
  String v_aiStone = 'n';
  int v_downCount = 0;

  int v_win = 0;
  int v_tie = 0;
  int v_defeat = 0;
  int v_score = 0;

  @override
  void dispose(){
    _player.stop();
    _player.dispose();
  }
  @override
  void initState(){
    super.initState();
    step_initial();
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
            child: Image.asset('assets/images/lock.png', height: 30, width: 25,),
          ),
          ElevatedButton(
            onPressed: ()async{
              if(v_flagButtonPlay == false){
                EasyLoading.instance.fontSize = 16;
                EasyLoading.instance.displayDuration = const Duration(milliseconds:  500);
                EasyLoading.showToast(' *** 실행되지 않았다냥! ***');
              }else{
                const url = 'https://simsimit00.tistory.com/';
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: Image.asset('assets/images/playstore.png', height: 22, width: 25,),
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
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                //바둑판 배경이미지
                Container(
                  width: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                  color: Colors.yellow,
                  child: Image.asset('assets/images/omok_bg.png', fit: BoxFit.contain,),
                ),
                //15 *15 바둑돌 이미지
                Container(
                    width: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                    height: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[0][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[1][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[2][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[3][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ), // 3
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[4][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[5][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[6][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[7][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[8][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[9][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[10][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[11][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[12][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[13][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container(),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][00]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][01]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][02]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][03]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][04]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][05]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][06]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][07]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][08]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][09]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][10]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][11]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][12]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][13]}.png'),
                                ),),
                                Expanded(flex: 9, child: Container(
                                  child: Image.asset('assets/images/${v_listBox[14][14]}.png'),
                                ),),

                                Expanded(flex: 1,child: Container(),)
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    )
                ),
                // 15 * 15 버튼
                Container(
                  width: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[00][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(00, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[01][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(01, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[02][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(02, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[03][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(03, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[04][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(04, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[05][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(05, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[06][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(06, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[07][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(07, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[08][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(08, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[09][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(09, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[10][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(10, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[11][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(11, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[12][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(12, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[13][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(13, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 18,
                        child: Container(
                          child: Container(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                // 버튼 !
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][00], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 00);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][01], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 01);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][02], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 02);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][03], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 03);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][04], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 04);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][05], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 05);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][06], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 06);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][07], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 07);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][08], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 08);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][09], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 09);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][10], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 10);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][11], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 11);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][12], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 12);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][13], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 13);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Text(v_listBox_count[14][14], style: TextStyle(fontSize: 12),),
                                        onPressed: (){
                                          step_downStone(14, 14);
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.black12,
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Row(
                          children: [
                            // 3 하단 텍스트
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.red,
                                child: Column(
                                    children:[
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              child: Text(
                                                'You',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              ),
                                          )
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            color: Colors.pink,
                                            child: Container(
                                                margin : EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                alignment: Alignment.center,
                                                child: Image.asset(
                                                    'assets/images/${v_youStone}.png'
                                                )
                                            )
                                        ),
                                      ),
                                    ]
                                )
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.yellow,
                                margin : EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child : TextButton(
                                      child: Text('게임\n시작', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                                      style: TextButton.styleFrom(
                                          minimumSize : Size.infinite,
                                          foregroundColor: Colors.black, backgroundColor: Colors.blue
                                      ),
                                  onPressed: ()async{
                                        if(v_flagButtonPlay == true){
                                          step_initial();
                                          (v_youStone == 'b') ? v_youStone = 'w' : v_youStone = 'b';
                                          await showDialog(context: context, builder: (context) {
                                            return AlertDialog(
                                              title: Text(style: TextStyle(color: Colors.pink, fontSize:  15), 'Alert'),
                                              content: Text(v_youStone == 'w' ? '게이머는 백으로 후수입니다.' : '게이머는 흑으로 선공합니다.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: (){Navigator.of(context).pop();},
                                                  child: const Text('확인')
                                                )
                                              ],
                                            );
                                          });
                                          if(v_flagButtonPlay == true) {press_play();}

                                        }else{
                                          EasyLoading.instance.fontSize = 16;
                                          EasyLoading.instance.displayDuration = const Duration(milliseconds:  500);
                                          EasyLoading.showToast(' 아직 실행되지 않았다냥!');
                                        }
                                  },

                                  )
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.green,
                                child: TextButton(
                                  child: Text('기권', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                                  style: TextButton.styleFrom(
                                      minimumSize : Size.infinite,
                                      foregroundColor: Colors.black, backgroundColor: Colors.blue
                                  ),
                                  onPressed: (){},
                                )
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.blue,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.deepOrangeAccent,
                                        alignment : Alignment.center,
                                        child: Text('현재 수순', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                          color: Colors.purple.shade300,
                                          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                          alignment: Alignment.center,
                                          child: Text(v_downCount.toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24
                                              )
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.blue,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.deepOrangeAccent,
                                  alignment : Alignment.center,
                                  child: Text('전적', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                color: Colors.purple.shade300,
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  alignment: Alignment.center,
                                child: Column(
                                    children:[
                                      Expanded(
                                          flex:1,
                                          child: Container(
                                              child:Row(
                                                  children:[
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.centerRight,
                                                            margin: EdgeInsets.fromLTRB(4, 4, 0, 4),
                                                            child: Text(v_win.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 24
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.center,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text('승',
                                                                style: TextStyle(
                                                                    color: Colors.green[100],
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.centerRight,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text(v_tie.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 24
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.center,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text('무',
                                                                style: TextStyle(
                                                                    color: Colors.yellow,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.centerRight,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text(v_defeat.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 24
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.center,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text('패',
                                                                style: TextStyle(
                                                                    color: Colors.red,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20
                                                                ))
                                                        )
                                                    ),
                                                  ]
                                              )
                                          )
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(),

                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.center,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text('점수',
                                                                style: TextStyle(
                                                                    color: Colors.red,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                            alignment : Alignment.centerRight,
                                                            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                                            child: Text(v_score.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 24
                                                                ))
                                                        )
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(),

                                                    ),
                                                  ]
                                              )
                                          )
                                      )
                                ]
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
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

