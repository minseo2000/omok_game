import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


class OmokList extends StatefulWidget {

  final Future<Database> db;

  const OmokList({Key? key, required this.db}) : super(key: key);

  @override
  State<OmokList> createState() => _OmokListState();
}

class _OmokListState extends State<OmokList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
