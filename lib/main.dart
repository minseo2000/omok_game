import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:omok/screen/omokList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'bannerAdWidget.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/omokList' : (context) => OmokList(db: database,)
      },
      debugShowCheckedModeBanner: false,
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
        "CREATE TABLE omoks(omokDate TEXT PRIMARY KEY, win INTEGER, tie INTEGER, defeat INTEGER, downCount INTEGER, score INTEGER)",
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
      if(v_volume == true) audioPlayer('assets/audios/stone.mp3');
    }else{
      if(v_volume == true) audioPlayer('assets/audios/error.mp3');
      return;
    }

    step_check();
    if(v_flagButtonPlay == true) return;

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
      if(v_volume == true) audioPlayer('assets/audios/stone.mp3');
      step_check();
      (v_down == 'b') ? v_down = 'w' : v_down = 'b';
    });
  }


  void step_check(){
    if(v_downCount < 9) return;
    step_check_5();
    if(v_flagButtonPlay == true) return;
    step_check_downCount();
  }

  void step_check_5(){
    step_check_row();
    if(v_flagButtonPlay == false) step_check_col();
    if(v_flagButtonPlay == false) step_check_grd1();
    if(v_flagButtonPlay == false) step_check_grd2();
    if(v_flagButtonPlay == false) return;

    EasyLoading.instance.fontSize = 24;
    EasyLoading.instance.displayDuration = const Duration(milliseconds: 2000);
    EasyLoading.showToast((v_down == v_youStone ? '승리했다냥!' : '졌다냥..'));

    if(v_down == v_youStone){
      if(v_volume == true) audioPlayer('assets/audios/clap.mp3');
      v_win++;
      (v_downCount < 20) ? v_score = v_score + 30 : v_score = v_score + 20;
    }else{
      if(v_volume == true) audioPlayer('assets/audios/laugh.mp3');
      v_defeat++;
      (v_downCount < 20) ? v_score = v_score - 20: v_score = v_score - 10;
    }
    _insert();
  }

  void step_check_downCount(){
    if(v_downCount < 120) return;
    v_flagButtonPlay = true;

    EasyLoading.instance.fontSize = 24;
    EasyLoading.instance.displayDuration = const Duration(milliseconds: 2000);
    EasyLoading.showToast('무승부다냥!');
    if(v_volume == true) audioPlayer('assets/audios/clap.mp3');
    v_tie++;
    v_score = v_score +10;
    _insert();
  }

  void step_check_row(){
    for(i=0;i<v_rowBox;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count = 0;
        for(jj=0;jj<5;jj++){
          if(v_listBox[i][j+jj] != v_down) break;
          _v_count++;
        }
        if(_v_count == 5){
          v_flagButtonPlay = true;
          return;
        }
      }
    }
  }
  void step_check_col(){
    for(j=0;j<v_colBox;j++){
      for(i=0;i<=v_rowBox-5;i++){
        int _v_count =0;
        for(ii=0;ii<5;ii++){
          if(v_listBox[i+ii][j] != v_down)break;
          _v_count++;
        }
        if(_v_count == 5){
          v_flagButtonPlay = true;
          return;
        }
      }
    }
  }

  void step_check_grd1(){
    for(i=0;i<=v_rowBox-5;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count =0;
        for(jj=0;jj<5;jj++){
          if(v_listBox[i+jj][j+jj] != v_down) break;
          _v_count++;
        }
        if(_v_count == 5){
          v_flagButtonPlay = true;
          return;
        }
      }
    }
  }

  void step_check_grd2(){
    for(i=4;i<v_rowBox;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count = 0;
        for(jj=0;jj<5;jj++){
          if(v_listBox[i-jj][j+jj] != v_down) break;
          _v_count++;
        }
        if(_v_count == 5){
          v_flagButtonPlay = true;
          return;
        }
      }
    }
  }


  void step_downStone_AI(){
    if(v_downCount < 5){
      step_downStone_5downCount();
      if(v_x_AI != 15) return;
    }
    step_downStone_AI4();
    if(v_x_AI != 15) return;

    step_downStone_YOU4();
    if(v_x_AI != 15) return;

    step_downStone_AI3();
    if(v_x_AI != 15) return;

    step_downStone_YOU3();
    if(v_x_AI != 15) return;

    step_downStone_attack();
    if(v_x_AI != 15) return;
  }

  void step_downStone_AI4(){
    step_downStone_AI4_row();
    if(v_x_AI != 15) return;
    step_downStone_AI4_col();
    if(v_x_AI != 15) return;
    step_downStone_AI4_grd1();
    if(v_x_AI != 15) return;
    step_downStone_AI4_grd2();
    if(v_x_AI != 15) return;
  }

  void step_downStone_AI4_row(){
    for(i = 0;i<v_rowBox ;i++){
      for(j=0;j<=v_colBox - 5 ;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for (jj=0;jj<5;jj++){
          if(v_listBox[i][j+jj] == v_youStone) break;
          if(v_listBox[i][j+jj] =='n'){
            _v_count_n++;
            _v_x_AI = i;
            _v_y_AI = j +jj;

          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI4_col(){
    for(j=0;j<v_colBox;j++){
      for(i=0;i<=v_rowBox - 5;i++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for(ii=0;ii<5;ii++){
          if(v_listBox[i+ii][j] == v_youStone) break;
          if(v_listBox[i+ii][j] == 'n'){
            _v_count_n++;
            _v_x_AI = i +ii;
            _v_y_AI = j;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI4_grd1(){
    for(i=0;i<=v_rowBox-5;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for(jj=0;jj<5;jj++){
          if(v_listBox[i+jj][j+jj] == v_youStone) break;
          if(v_listBox[i+jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI = i +jj;
            _v_y_AI = j+jj;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI4_grd2(){
    for(i=4;i<v_rowBox;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for(jj=0;jj<5;jj++){
          if(v_listBox[i-jj][j+jj] == v_youStone) break;
          if(v_listBox[i-jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI = i -jj;
            _v_y_AI = j+jj;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }

  void step_downStone_AI3(){
    step_downStone_AI3_row();
    if(v_x_AI != 15) return;
    step_downStone_AI3_col();
    if(v_x_AI != 15) return;
    step_downStone_AI3_grd1();
    if(v_x_AI != 15) return;
    step_downStone_AI3_grd2();
    if(v_x_AI != 15) return;
  }

  void step_downStone_AI3_row(){
    for(i = 0;i<v_rowBox ;i++){
      for(j=0;j<=v_colBox-4 ;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for (jj=0;jj<4;jj++){
          if(v_listBox[i][j+jj] == v_youStone) break;
          if(v_listBox[i][j+jj] =='n'){
            _v_count_n++;
            _v_x_AI = i;
            _v_y_AI = j +jj;

          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI3_col(){
    for(j=0;j<v_colBox;j++){
      for(i=0;i<=v_rowBox-4;i++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for(ii=0;ii<4;ii++){
          if(v_listBox[i+ii][j] == v_youStone) break;
          if(v_listBox[i+ii][j] == 'n'){
            _v_count_n++;
            _v_x_AI = i +ii;
            _v_y_AI = j;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI3_grd1(){
    for(i=0;i<=v_rowBox-4;i++){
      for(j=0;j<=v_colBox-4;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for(jj=0;jj<4;jj++){
          if(v_listBox[i+jj][j+jj] == v_youStone) break;
          if(v_listBox[i+jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI = i +jj;
            _v_y_AI = j+jj;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }
  void step_downStone_AI3_grd2(){
    for(i=3;i<v_rowBox;i++){
      for(j=0;j<=v_colBox-4;j++){
        int _v_count_n = 0;
        int _v_count_AI = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;
        for(jj=0;jj<4;jj++){
          if(v_listBox[i-jj][j+jj] == v_youStone) break;
          if(v_listBox[i-jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI = i -jj;
            _v_y_AI = j+jj;
          }else{
            _v_count_AI++;
          }
        }
        if(_v_count_n == 1 && _v_count_AI == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }
    }
  }


  void step_end_play(){
    v_flagButtonPlay = true;

    EasyLoading.instance.fontSize = 24;
    EasyLoading.instance.displayDuration = const Duration(milliseconds: 2000);
    EasyLoading.showToast('기권 패다냥!');
    if(v_volume == true) audioPlayer('assets/audios/laugh.mp3');
    v_defeat++;
    (v_downCount < 20) ? v_score = v_score - 10: v_score = v_score -5;
    setState((){});
    _insert();
  }

  void step_downStone_YOU4(){
    step_downStone_YOU4_row();
    if(v_x_AI != 15) return;
    step_downStone_YOU4_col();
    if(v_x_AI != 15) return;
    step_downStone_YOU4_grd1();
    if(v_x_AI != 15) return;
    step_downStone_YOU4_grd2();
    if(v_x_AI != 15) return;
  }

  void step_downStone_YOU4_row(){
    for(i=0;i< v_rowBox;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<5;jj++){
          if(v_listBox[i][j+jj] == v_aiStone) break;
          if(v_listBox[i][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i;
            _v_y_AI = j + jj;
          }else{
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU4_col(){
    for(j=0;j< v_colBox;j++){
      for(i=0;i<=v_rowBox-5;i++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (ii=0;ii<5; ii++){
          if(v_listBox[i+ii][j] == v_aiStone) break;
          if(v_listBox[i+ii][j] == 'n'){
            _v_count_n++;
            _v_x_AI=i+ii;
            _v_y_AI = j;
          }else{
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU4_grd1(){
    for(i=0;i<= v_rowBox-5;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<5;jj++){
          if(v_listBox[i+jj][j+jj] == v_aiStone) break;
          if(v_listBox[i+jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i+jj;
            _v_y_AI = j + jj;
          }else{
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU4_grd2(){
    for(i=4;i< v_rowBox;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<5;jj++){
          if(v_listBox[i-jj][j+jj] == v_aiStone) break;
          if(v_listBox[i-jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i-jj;
            _v_y_AI = j + jj;
          }else{
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 4){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }


  void step_downStone_YOU3(){
    step_downStone_YOU3_row();
    if(v_x_AI != 15) return;
    step_downStone_YOU3_col();
    if(v_x_AI != 15) return;
    step_downStone_YOU3_grd1();
    if(v_x_AI != 15) return;
    step_downStone_YOU3_grd2();
    if(v_x_AI != 15) return;
  }

  void step_downStone_YOU3_row(){
    for(i=0;i< v_rowBox;i++){
      for(j=1;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<4;jj++){
          if(v_listBox[i][j+jj] == v_aiStone) break;
          if(v_listBox[i][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i;
            _v_y_AI = j + jj;
          }else{
            if(jj==0&& v_listBox[i][j-1] == v_aiStone) break;
            if(jj==3 && v_listBox[i][j+jj+1] == v_aiStone) break;
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU3_col(){
    for(j=0;j< v_colBox;j++){
      for(i=1;i<=v_rowBox-5;i++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (ii=0;ii<4; ii++){
          if(v_listBox[i+ii][j] == v_aiStone) break;
          if(v_listBox[i+ii][j] == 'n'){
            _v_count_n++;
            _v_x_AI=i+ii;
            _v_y_AI = j;
          }else{
            if(ii==0 && v_listBox[i-1][j] == v_aiStone) break;
            if(ii==3 && v_listBox[i+ii+1] == v_aiStone) break;
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU3_grd1(){
    for(i=0;i<= v_rowBox-5;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<4;jj++){
          if(v_listBox[i+jj][j+jj] == v_aiStone) break;
          if(v_listBox[i+jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i+jj;
            _v_y_AI = j + jj;
          }else{
            if(jj==0 && v_listBox[i-1][j-1] == v_aiStone) break;
            if(jj==3 && v_listBox[i+jj+1][j+jj+1] == v_aiStone) break;
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
  }
  void step_downStone_YOU3_grd2(){
    for(i=4;i< v_rowBox-1;i++){
      for(j=0;j<=v_colBox-5;j++){
        int _v_count_n = 0;
        int _v_count_YOU = 0;
        int _v_x_AI = 0;
        int _v_y_AI = 0;

        for (jj=0;jj<4;jj++){
          if(v_listBox[i-jj][j+jj] == v_aiStone) break;
          if(v_listBox[i-jj][j+jj] == 'n'){
            _v_count_n++;
            _v_x_AI=i-jj;
            _v_y_AI = j + jj;
          }else{
            if(jj==0 && v_listBox[i+1][j-1] == v_aiStone) break;
            if(jj==3 && v_listBox[i-jj-1][j+jj+1] == v_aiStone) break;
            _v_count_YOU++;
          }
        }
        if(_v_count_n == 1 && _v_count_YOU == 3){
          v_x_AI = _v_x_AI;
          v_y_AI = _v_y_AI;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }

      }
    }
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
      }
      if(v_x_previous == 7){
        if(v_y_previous < 8 && v_listBox[v_x_previous][v_y_previous+1] == 'n'){
          v_x_AI = v_x_previous;
          v_y_AI = v_y_previous-1;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
        if (v_y_previous > 7 && v_listBox[v_x_previous][v_y_previous-1] == 'n'){
          v_x_AI = v_x_previous;
          v_y_AI = v_y_previous+1;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }

      if(v_y_previous == 7){
        if(v_x_previous <8 && v_listBox[v_x_previous+1][v_y_previous] == 'n'){
          v_x_AI = v_x_previous-1;
          v_y_AI = v_y_previous;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
        if(v_x_previous > 7 && v_listBox[v_x_previous -1][v_y_previous] == 'n'){
          v_x_AI = v_x_previous +1;
          v_y_AI = v_y_previous;
          v_listBox[v_x_AI][v_y_AI] = v_down;
          return;
        }
      }

      if(v_y_previous < 8 && v_x_previous < 8 && v_listBox[v_x_previous-1][v_y_previous-1] == 'n'){
        v_x_AI = v_x_previous - 1;
        v_y_AI = v_y_previous - 1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }

      if(v_y_previous < 8 && v_x_previous > 7 && v_listBox[v_x_previous+1][v_y_previous-1] == 'n'){
        v_x_AI = v_x_previous +1;
        v_y_AI = v_y_previous -1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }

      if(v_y_previous > 7 && v_x_previous < 8 && v_listBox[v_x_previous - 1][v_y_previous +1] == 'n'){
        v_x_AI = v_x_previous -1;
        v_y_AI = v_y_previous +1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }


      if(v_y_previous > 7 && v_x_previous > 7 && v_listBox[v_x_previous+1][v_y_previous+1]=='n'){
        v_x_AI = v_x_previous +1;
        v_y_AI = v_y_previous + 1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous-0][v_y_previous+1] =='n'){
        v_x_AI = v_x_previous -0;
        v_y_AI = v_y_previous +1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous+1][v_y_previous+1] == 'n'){
        v_x_AI = v_x_previous +1;
        v_y_AI = v_y_previous +1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous+1][v_y_previous+0] == 'n'){
        v_x_AI = v_x_previous+1;
        v_y_AI = v_y_previous +0;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous+1][v_y_previous-1] =='n'){
        v_x_AI = v_x_previous+1;
        v_y_AI = v_y_previous-1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous+0][v_y_previous-1] == 'n'){
        v_x_AI = v_x_previous+0;
        v_y_AI = v_y_previous-1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous-1][v_y_previous-1] == 'n'){
        v_x_AI = v_x_previous-1;
        v_y_AI = v_y_previous-1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous-1][v_y_previous-0] == 'n'){
        v_x_AI = v_x_previous-1;
        v_y_AI = v_y_previous -0;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
      }
      if(v_listBox[v_x_previous-1][v_y_previous-1] == 'n'){
        v_x_AI = v_x_previous-1;
        v_y_AI = v_y_previous-1;
        v_listBox[v_x_AI][v_y_AI] = v_down;
        return;
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

  void step_downStone_attack(){
    v_scoreTop = 0;

    for(i =0;i<v_rowBox;i++){
      for(j=0;j<v_colBox;j++){
        if(v_listBox[i][j] == 'n'){
          v_scoreRow = 0;
          v_scoreCol = 0;
          v_scoreGrd1 = 0;
          v_scoreGrd2 = 0;
          step_downStone_attack_row(i, j);
          step_downStone_attack_col(i, j);
          step_downStone_attack_grd1(i, j);
          step_downStone_attack_grd2(i, j);

          if(v_scoreTop < v_scoreRow + v_scoreCol + v_scoreGrd1 + v_scoreGrd2){
            v_scoreTop = v_scoreRow + v_scoreCol + v_scoreGrd1 + v_scoreGrd2;
            v_x_AI = i;
            v_y_AI = j;
          }
        }
      }
    }
    v_listBox[v_x_AI][v_y_AI] = v_down;
    return;
  }
  //p130
  void step_downStone_attack_row(x, y){
    if(y ==0){
      v_scoreRow = v_scoreRow - 5;
    }else{
      v_count = 0;
      for(jj=y-1;jj>=0;jj--){
        if(v_count == 4) break; else v_count++;
        if(v_listBox[x][jj] == 'n'){
          v_scoreRow = v_scoreRow + 1;
        }else if(v_listBox[x][jj] == v_youStone){
          v_scoreRow = v_scoreRow - 3;
          break;
        }else{
          v_scoreRow = v_scoreRow + 2 + (5-v_count);
        }
      }
    }

    if( y == v_colBox - 1){
      v_scoreRow = v_scoreRow - 5;
    }else{
      v_count = 0;
      for(jj=y+1;jj<v_colBox;jj++){
        if(v_count == 4) break; else v_count++;
        if(v_listBox[x][jj] == 'n'){
          v_scoreRow = v_scoreRow +1;
        }else if(v_listBox[x][jj] == v_youStone){
          v_scoreRow = v_scoreRow - 3;
          return;
        }else{
          v_scoreRow = v_scoreRow + 2 + (5-v_count);
        }
      }
    }
  }
  void step_downStone_attack_col(x, y){
    if(x ==0){
      v_scoreCol = v_scoreCol - 5;
    }else{
      v_count = 0;
      for(ii=x-1;ii>=0;ii--){
        if(v_count == 4) break; else v_count++;
        if(v_listBox[ii][y] == 'n'){
          v_scoreCol = v_scoreCol + 1;
        }else if(v_listBox[ii][y] == v_youStone){
          v_scoreCol = v_scoreCol - 3;
          break;
        }else{
          v_scoreCol = v_scoreCol + 2 + (5-v_count);
        }
      }
    }

    if( x == v_rowBox - 1){
      v_scoreCol = v_scoreCol - 5;
    }else{
      v_count = 0;
      for(ii=x+1;ii<v_rowBox;ii++){
        if(v_count == 4) break; else v_count++;
        if(v_listBox[ii][y] == 'n'){
          v_scoreCol = v_scoreCol +1;
        }else if(v_listBox[ii][y] == v_youStone){
          v_scoreCol = v_scoreCol - 3;
          return;
        }else{
          v_scoreCol = v_scoreCol + 2 + (5-v_count);
        }
      }
    }
  }

  void step_downStone_attack_grd1(x, y){

    if(x==0 || y==0){
      v_scoreGrd1 = v_scoreGrd1 -5;
    }else{
      for(v_count = 1;v_count < 5; v_count++){
        if(x - v_count < 0 || y- v_count < 0) break;
        if(v_listBox[x-v_count][y - v_count] =='n'){
          v_scoreGrd1 = v_scoreGrd1 +1;
        }else if(v_listBox[x-v_count][y-v_count] == v_youStone){
          v_scoreGrd1 = v_scoreGrd1 -3;
          break;
        }else{
          v_scoreGrd1 = v_scoreGrd1 + 2 + (6 - v_count);
        }
      }
    }
    if(x==v_rowBox -1 || y == v_colBox -1){
      v_scoreGrd1 = v_scoreGrd1 -5;
    }else{
      for(v_count =1;v_count <5; v_count++){
        if(x+v_count > v_colBox -1 || y+v_count > v_rowBox -1) break;
        if(v_listBox[x+v_count][y+v_count] == 'n'){
          v_scoreGrd1 = v_scoreGrd1 + 1;
        }else if(v_listBox[x+v_count][y+ v_count] == v_youStone){
          v_scoreGrd1 = v_scoreGrd1 -3;
          return;
        }else{
          v_scoreGrd1 = v_scoreGrd1 + 2 + (5-v_count);
        }
      }
    }
  }
  void step_downStone_attack_grd2(x, y){

    if(x==0 || y + v_count == v_rowBox -1){
      v_scoreGrd2 = v_scoreGrd2 -5;
    }else{
      for(v_count = 1;v_count < 5; v_count++){
        if(x - v_count < 0 || y + v_count > v_rowBox - 1) break;
        if(v_listBox[x-v_count][y + v_count] =='n'){
          v_scoreGrd2 = v_scoreGrd2 +1;
        }else if(v_listBox[x-v_count][y+v_count] == v_youStone){
          v_scoreGrd2 = v_scoreGrd2 -3;
          break;
        }else{
          v_scoreGrd2 = v_scoreGrd2 + 2 + (6 - v_count);
        }
      }
    }
    if(x==v_rowBox -1 || y == 0){
      v_scoreGrd2 = v_scoreGrd2 -5;
    }else{
      for(v_count =1;v_count <5; v_count++){
        if(x+v_count > v_colBox -1 ||  y - v_count < 0) break;
        if(v_listBox[x+v_count][y - v_count] == 'n'){
          v_scoreGrd2 = v_scoreGrd2 + 1;
        }else if(v_listBox[x+v_count][y - v_count] == v_youStone){
          v_scoreGrd2 = v_scoreGrd2 -3;
          return;
        }else{
          v_scoreGrd2 = v_scoreGrd2 + 2 + (5-v_count);
        }
      }
    }
  }


  void press_play(){
    v_flagButtonPlay = false;

    if(v_youStone == 'w'){
      v_listBox[7][7] = 'b';
      v_aiStone = 'b';
      if(v_volume == true) audioPlayer('assets/audios/stone.mp3');
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
  late int ii;
  late int jj;

  int v_rowBox = 15;
  int v_colBox = 15;
  int v_x_count = 0;
  int v_y_count = 0;
  String v_down = 'n';

  int v_x_previous = 15;
  int v_y_previous = 15;
  int v_x_AI = 15;
  int v_y_AI = 15;

  int v_count = 5;

  int v_scoreTop = 0;
  int v_scoreRow = 0;
  int v_scoreCol = 0;
  int v_scoreGrd1 = 0;
  int v_scoreGrd2 = 0;

  late String v_today;



  String v_youStone = 'n';
  String v_aiStone = 'n';
  int v_downCount = 0;

  int v_win = 0;
  int v_tie = 0;
  int v_defeat = 0;
  int v_score = 0;

  void _insert() async{
    final Database database = await widget.db;
    if(v_win + v_tie + v_defeat == 1){
      String _today = DateFormat('yyyy-mm-dd hh:mm:ss').format(DateTime.now());
      v_today = _today;
      await database.rawUpdate(
        "insert into omoks(omokDate, win, tie, defeat, downCount, score) values('$_today', $v_win, $v_tie, $v_defeat, $v_downCount, $v_score)");
    }else{
      String _today = v_today;
      await database.rawUpdate(
        "update omoks set win = $v_win, tie = $v_tie, defeat = $v_defeat, downCount = $v_downCount, score = $v_score where omokDate = '$_today'"
      );
    }
  }

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
            Expanded(
                flex:1,
child: Container(
  child: Column(
      children:
  [
    Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/cat8.png'),fit: BoxFit.fitWidth
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
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
                                                      color: Colors.black,
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
  ]
  )
)
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                //바둑판 배경이미지
                Container(
                  width: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height - 300 ? MediaQuery.of(context).size.height -300 : MediaQuery.of(context).size.width),
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
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/cat8.png'),fit: BoxFit.fitWidth
                            )
                        ),
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Row(
                          children: [
                            // 3 하단 텍스트
                            Expanded(
                              flex: 1,
                              child: Container(
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
                                  color: Colors.white54,
                                margin : EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child : TextButton(
                                      child: Text('게임\n시작', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                                      style: TextButton.styleFrom(
                                          minimumSize : Size.infinite,

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
                                  color: Colors.white54,
                                child: TextButton(
                                  child: Text('기권', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                                  style: TextButton.styleFrom(
                                      minimumSize : Size.infinite,
                                  ),
                                  onPressed: ()async{
                                    if(v_flagButtonPlay == false){
                                      await showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          title: Text('Alert', style: TextStyle(color: Colors.pink, fontSize: 15),),
                                          content: Text('기권하시겠습니까?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: (){
                                                step_end_play();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('기권')
                                            ),
                                            TextButton(
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('아니오')
                                            ),
                                          ],
                                        );
                                      });
                                    }else{
                                      EasyLoading.instance.fontSize = 16;
                                      EasyLoading.instance.displayDuration = const Duration(milliseconds: 500);
                                      EasyLoading.showToast('게임 중이 아니다냥!');
                                    }
                                  },
                                )
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: Column(
                                      children:[
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Text(
                                                'AI',
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

                                              child: Container(
                                                  margin : EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                      'assets/images/${v_aiStone}.png'
                                                  )
                                              )
                                          ),
                                        ),
                                      ]
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 75,
        child: BannerAdWidget()
      ),
    );
  }



}

