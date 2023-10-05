import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:member_ieee/AddMember.dart';
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

  void addInLocalStorageMember(String nom,String lastname,String email,String cin,String tlf){
    int idRandom=Random.secure().nextInt(99999);
    Member member=Member(id: idRandom, nom: nom, cin: cin, lastname: lastname, email: email, ispayer: false, present: false,tlf: tlf, chaptername: widget.NameChapter);
    Members.add(member);
    SetLocalStorge(Members);
    getFromLocalStoreg("");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content:  Text(nom+ " Added with Success To " + widget.NameChapter.toUpperCase() +" Chapter ",style: TextStyle(color: Colors.white,fontSize: 15,),))
    );
  }

  void SetLocalStorge(val)async{
    final usersJson = jsonEncode(val);
    await storage.write(key: "Members", value:usersJson);
  }

void deleteUser(int id)  {
  Member index=Members.firstWhere((element) => element.id==id);
  if (index != -1) {
    Members.remove(index);
    SetLocalStorge(Members);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Member deleted",style: TextStyle(color: Colors.white,fontSize: 15))
        )
    );
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

 void initPresent(String chaptername){
  setState(() {
    for(int i=0;i<Members.length;i++){
      if(Members[i].chaptername==chaptername){
        Members[i].present=false;
      }
    }
  });
   SetLocalStorge(Members);
   getFromLocalStoreg("");
 }

 void changePayer(val,int id){
  setState(() {
       for(int i=0;i<Members.length;i++){
      if(Members[i].id==id){
         Members[i].ispayer=!val;
      }
    }
  });
  SetLocalStorge(Members);
  getFromLocalStoreg("");
  Navigator.pop(context);
}


 
@override
Widget build(BuildContext context) {
  List<Member> data=search.isEmpty ? Members.where((element) => element.chaptername == widget.NameChapter).toList() :
    Members.where((element) => element.chaptername == widget.NameChapter && element.nom.toLowerCase().contains(search.toLowerCase())).toList();
  return Scaffold(
    floatingActionButton: Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
       backgroundColor: widget.NameChapter.toUpperCase()=="RAS" ? Color.fromARGB(255, 55, 2, 64) : widget.NameChapter.toUpperCase()=="WIE"  ? Colors.pink : widget.NameChapter.toUpperCase()=="IAS" ? Color.fromARGB(255, 2, 201, 9) : widget.NameChapter.toUpperCase()=="OTHER" ? Colors.white : Colors.blue ,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
          AddMember(chapterName: widget.NameChapter, addInLocalStorageMember: addInLocalStorageMember)
        ));
      },
      child: Text("Add", style:  TextStyle(color: widget.NameChapter.toUpperCase()=="OTHER" ? Colors.blue : Colors.white, fontWeight: FontWeight.bold),), 
    ),
  ],
),
    appBar: AppBar(
      iconTheme: IconThemeData(color:widget.NameChapter.toUpperCase()=="OTHER" ? Colors.blue : Colors.white ),
      backgroundColor: widget.NameChapter.toUpperCase()=="RAS" ? Color.fromARGB(255, 55, 2, 64) : widget.NameChapter.toUpperCase()=="WIE"  ? Colors.pink : widget.NameChapter.toUpperCase()=="IAS" ? Color.fromARGB(255, 2, 201, 9) : widget.NameChapter.toUpperCase()=="OTHER" ? Colors.white : Colors.blue ,
      title: Text(
        "${widget.NameChapter}  (${data.length})",
        style:  TextStyle(color: widget.NameChapter.toUpperCase()=="OTHER" ? Colors.blue : Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(onPressed:(){ initPresent(widget.NameChapter) ;}, icon:const Icon(Icons.replay_outlined))
      ],
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
          const Padding(padding: EdgeInsets.only(top: 250),
          child:   Center(
            child: Text(
              "No One Yet",
              style: TextStyle(fontSize: 25),
            ),
          ),)
        else
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                Member memeber = data[index];
                return Dismissible(key: Key(memeber.id.toString()),
                 background: Container(
                   color: Colors.cyan,
                   child: const Icon(Icons.delete,color: Colors.white,),
                 ),
                 onDismissed: (direction) {
                      deleteUser(data[index].id);
                      setState(() {
                         data.removeAt(index);
                      });
                 },
                 child: 
                Card(
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
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.yellow,
                          ),
                        ),
                          IconButton(
                          onPressed: () {
                          },
                          icon: const Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(onPressed: (){
                                showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("${data[index].nom} Payed "),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if(data[index].ispayer==true){
                                              Navigator.pop(context);
                                            }else{
                                                changePayer(data[index].ispayer,data[index].id);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                             child: const Text("Yes"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                              if(data[index].ispayer==false){
                                              Navigator.pop(context);
                                            }else{
                                                changePayer(data[index].ispayer,data[index].id);
                                            }
                                          },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                              child:const  Text("No !"),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }
                        ); 
                        }, icon:Icon(data[index].ispayer ? Icons.attach_money_sharp : Icons.money_off,color:data[index].ispayer ? Colors.blue : Colors.grey,))
                      ],
                    ),
                  ),
                ));
              },
            ),
          ),
      ],
    ),
  );
}
}