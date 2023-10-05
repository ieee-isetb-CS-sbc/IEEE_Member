class Member{
  int id;
  String nom;
  String lastname;
  String email;
  String cin;
  String tlf;
  bool ispayer;
  bool present;
  String chaptername;
  
  Member({required this.id,required this.nom,required this.cin,required this.lastname,required this.email,required this.ispayer,
  required this.present,required this.tlf,required this.chaptername});

  factory Member.fromJson(Map<String,dynamic> json){
    return Member(
      id: json['id'],
      nom: json['nom'], 
      cin: json['cin'],
      lastname: json['lastname'],
       email: json['email'], 
       ispayer: json['ispayer'], 
       present: json['present'], 
       tlf: json['tlf'],
       chaptername: json['chaptername']) ;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'lastname': lastname,
      'email': email,
      'cin':cin,
      'ispayer': ispayer,
      'present': present,
      'chaptername': chaptername,
      'tlf':tlf
    };
  }

  @override
  String toString() {
    return nom;
  }

}