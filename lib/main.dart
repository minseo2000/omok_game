import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omok/screen/omokList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp]
  ); // 세로 화면 고정

  Future<Database> database = initDatabase();

  runApp(
    MaterialApp(
      home: DatabaseApp(db: database),
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

  @override
  Widget build(BuildContext context) {


    return Text('메인 화면');
  }



}

