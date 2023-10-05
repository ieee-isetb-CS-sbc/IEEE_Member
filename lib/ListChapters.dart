import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:member_ieee/InfoDeveloper.dart';
import 'package:member_ieee/Model/Member.dart';
import 'Model/chapters.dart';
import 'PgesForMembers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
 
class ListChapter extends StatefulWidget {
  @override
  State<ListChapter> createState() => _ListChapter();
}
class _ListChapter extends State<ListChapter> {

final storage = new FlutterSecureStorage();

  List<List<dynamic>> _data = [];
  String? filePath;
   
int countIEE=0;
int payerIEE=0;
int NotPayerIEEE=0;

List<Member> Members = [];

 void SetLocalStorge(val)async{
    final usersJson = jsonEncode(val);
    await storage.write(key: "Members", value:usersJson);
  }

void getFromLocalStoreg() async {
  final usersJson = await storage.read(key: "Members");
  if (usersJson != null) {
    final userdecode = jsonDecode(usersJson);
    List<Member> data = userdecode.map<Member>((user) => Member.fromJson(user)).toList();
    print(data);
    setState(() {
        Members = data.toList() ?? [];
        countIEE=data.length;
        payerIEE=data.where((element) => element.ispayer==true).length;
        NotPayerIEEE=data.where((element) => element.ispayer==false).length;
    });
  }
}

  void addInLocalStorageMember(){
    for(var element in _data.skip(1)){
        int idRandom=Random.secure().nextInt(99999);
        Member member=Member(id: idRandom, nom: element[1], cin: element[2], lastname: element[3], email: element[4], ispayer: false, present: false,tlf: element[5], chaptername: element[element.length-1].toString().toLowerCase());
        Members.add(member);
    }
    SetLocalStorge(Members);
    getFromLocalStoreg();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content:  Text( " Added File CSV",style: TextStyle(color: Colors.white,fontSize: 15,),))
    );
  }

void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    filePath = result.files.first.path!;
    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
      setState(() {
        _data = fields;
      });
      addInLocalStorageMember();
  }


  @override
  void initState(){
    super.initState();
    getFromLocalStoreg();
  }

   
  List<cahpters> groupChapters = [
    cahpters(Nom: "CS", ImaggPath: "images/cs.PNG"),
    cahpters(Nom: "WIE", ImaggPath: "images/wie.PNG"),
    cahpters(Nom: "RAS", ImaggPath: "images/ras.PNG"),
    cahpters(Nom: "IAS", ImaggPath: "images/ias.PNG"),
    cahpters(Nom: "Other", ImaggPath: "images/sb.JPG"),
  ];

  Future<void> NavigationScreen(data) async{
       String ? resultat=await Navigator.push(context,MaterialPageRoute(builder: (context)=>PagesForMember(NameChapter:data)));();
        if(resultat=="test"){
            getFromLocalStoreg();
        }else{
            getFromLocalStoreg();
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        _pickFile();
      },
      child:const Icon(Icons.file_copy),
    ),
      appBar: AppBar(
        title: const Center(child: Text("Welcome To IEEE")),
        actions: <Widget>[
           IconButton(onPressed: 
             (){Navigator.push(context,MaterialPageRoute(builder: (context)=> InfoDeveloper(Memebrs:countIEE,NotpayerNumber: NotPayerIEEE,payerNumber: payerIEE,)));}
           , icon: const Icon(Icons.info))
        ],
      ),
      body: Center(
        child: Padding(padding:const EdgeInsets.only(top: 70),child: GridView.builder(
          itemCount: groupChapters.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            final data = groupChapters[index];
              return GestureDetector(
                onTap: () {
                    NavigationScreen(data.Nom.toString());
                },
                child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    data.ImaggPath,
                  ),
                ],
              ),
            ),);
          },
        ))
      )
    );
  }
}
