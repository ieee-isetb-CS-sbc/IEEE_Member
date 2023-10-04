import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:member_ieee/Model/Member.dart';
import 'Model/chapters.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class PagesForMember extends StatefulWidget {

  PagesForMember({super.key,required this.NameChapter});
  String  NameChapter;

  @override
  State<PagesForMember> createState() => _PagesForMember();
}

class _PagesForMember extends State<PagesForMember> {

  List<Member> Members = [];

  final storage = new FlutterSecureStorage();

  String search="";

  @override
  void initState() {
        super.initState();
        getFromLocalStoreg("");
  }

  void SetLocalStorge(val)async{
    final usersJson = jsonEncode(val);
    await storage.write(key: "Members", value:usersJson);
  }

void deleteUser(int id) async {
  Member index=Members.firstWhere((element) => element.id==id);
  if (index != -1) {
    Members.remove(index);
    SetLocalStorge(Members);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Member deleted"))
    );
    setState(() {}); 
    Navigator.of(context).pop();
    getFromLocalStoreg("");
  }
}

void getFromLocalStoreg(String name) async {
  final usersJson = await storage.read(key: "Members");
  if (usersJson != null) {
    final userdecode = jsonDecode(usersJson);
    final data = userdecode.map<Member>((user) => Member.fromJson(user)).toList();
    if (name.isEmpty) {
      setState(() {
        Members = data.toList() ?? [];
      });
    } else {
      setState(() {
        Members = data.where((element) =>
          element.nom.toLowerCase().contains(name.toLowerCase())
        ).toList() ?? [];
      });
    }
  }
}

void ChangeSatet(val,int id){
  setState(() {
       for(int i=0;i<Members.length;i++){
      if(Members[i].id==id){
         Members[i].present=val;
      }
    }
  });
  SetLocalStorge(Members);
  getFromLocalStoreg("");
}



  /*List<Member> getMember(){
    return [
        Member(id:2,nom: "ghassen", lastname: "mejri", email: "talel@gmail.com", ispayer: true, present: false, chaptername: "RAS"),
        Member(id:4,nom: "Hkimi", lastname: "mejri", email: "talel@gmail.com", ispayer: false, present: false, chaptername: "IAS"),
        Member(id:3,nom: "talel", lastname: "mejri", email: "talel@gmail.com", ispayer: true, present: false, chaptername: "CS")
    ].where((element) => element.chaptername == widget.NameChapter).toList() ?? [];
  }*/
 
  @override
Widget build(BuildContext context) {
  List<Member> data=search.isEmpty ? Members.where((element) => element.chaptername == widget.NameChapter).toList() :
    Members.where((element) => element.chaptername == widget.NameChapter && element.nom.toLowerCase().contains(search.toLowerCase())).toList()
  ;
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "${widget.NameChapter}  (${data.length})",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (val) {
              setState(() {
                search=val;
              });
            },
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        if (data.isEmpty)
          Center(
            child: Text(
              "Members Not Found",
              style: TextStyle(fontSize: 25),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                Member memeber = data[index];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: memeber.present,
                      onChanged: (val) {
                        ChangeSatet(val,memeber.id);
                      },
                    ),
                    title: Text(memeber.nom + " " + memeber.lastname),
                    subtitle: Text(memeber.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Do You Want Delete  ${data[index].nom}"),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            deleteUser(data[index].id);
                                          },
                                          child: Text("confirm"),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Close"),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                        Text(memeber.ispayer ? 'Payer' : 'Not Yet')
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
}