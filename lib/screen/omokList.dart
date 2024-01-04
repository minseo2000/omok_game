import 'package:flutter/material.dart';
import 'package:omok/omok.dart';
import 'package:sqflite/sqflite.dart';


class OmokList extends StatefulWidget {

  final Future<Database> db;

  const OmokList({Key? key, required this.db}) : super(key: key);

  @override
  State<OmokList> createState() => _OmokListState();
}

class _OmokListState extends State<OmokList> {

  Future<List<Omok>>? OmokList;

  @override
  void initState(){
    super.initState();
    OmokList = getOmokList() as Future<List<Omok>>?;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('냥목')
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot){
              switch (snapshot.connectionState){
                case ConnectionState.active:
                  return const CircularProgressIndicator();
                case ConnectionState.none:
                  return const CircularProgressIndicator();
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                case ConnectionState.done:
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemBuilder: (context, index){
                        Omok omok = (snapshot.data as List<Omok>)[index];
                        return ListTile(
                          subtitle: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('랭킹!', style: const TextStyle(fontSize: 14, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                                        Text((index+1).toString(), style: const TextStyle(fontSize: 35, color: Colors.yellow, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(omok.omokDate!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
                                        Text(omok.win!.toString()+' 승'+omok.tie!.toString()+' 무'+omok.defeat!.toString()+' 패\n'+ '수순' + omok.downCount!.toString()+' 점수 '+omok.score!.toString(), style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: (snapshot.data as List<Omok>).length,
                    );
                  }else{
                    return Text('데이터가 없다냥!');
                  }
              }
              return const CircularProgressIndicator();
            },
            future: OmokList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result = await showDialog(context: context, builder: (context){
            return AlertDialog(
              title: const Text('삭제!'),
              content: const Text('정말 다 삭제할거냥!?'),
              actions: <Widget>[
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(true);

                  },
                  child: const Text('네!'),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop(false);

                  },
                  child: const Text('싫어요!'),
                )
              ],
            );
          });
          if( result == true){
            _removeAllTodos();
          }

        },
        child: const Icon(Icons.remove),
      ),
    );
  }

  void _removeAllTodos() async{
    final Database database = await widget.db;
    database.rawDelete('delete from omoks');
    setState(() {
      OmokList = getOmokList();
    });
  }

  Future<List<Omok>> getOmokList() async {{
    final Database database = await widget.db;
    List<Map<String, dynamic>> maps = await database.rawQuery(
  'select omokDate, win, tie, defeat, downCount, score from omoks order by score desc'
  );
    return List.generate(maps.length, (i) {
     return Omok(
     omokDate: maps[i]['omokDate'],
  win: maps[i]['win'],
  tie: maps[i]['tie'],
  defeat: maps[i]['defeat'],
  downCount: maps[i]['downCount'],
  score: maps[i]['score'],
     );
  });
  }}
}
