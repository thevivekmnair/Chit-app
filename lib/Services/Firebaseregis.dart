import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebaseflutter2/Models/Planmodel.dart';

class Registration{
  FirebaseAuth _auth=FirebaseAuth.instance;
  CollectionReference _firestore=Firestore.instance.collection("brews");
  CollectionReference _dropdownref=Firestore.instance.collection("Plans");
  

  //Changing querysnapshot to data model
  List<plan> querysnptoplan(QuerySnapshot snapshot){
    List<plan> _list=[];
    for(DocumentSnapshot doc in snapshot.documents){
      _list.add(
        plan(
          chitPlan:doc.data['chit plan'],
          amount: doc.data['amount'],
          monthlyAmt: doc.data['monthly amt'],
          tenor: doc.data['tenor']
        )
      );
    }
    return _list ;
  }
  
  //New User registration
  Future registerNewUser(String email,Map<String,dynamic> credentials)async{
     try{
    AuthResult result=await _auth.createUserWithEmailAndPassword(
      email: email, password: credentials['password']);
      print("Created user");
      await _firestore.document(result.user.uid).setData(
        {
          'name':credentials['name'],
          'accountbranch':credentials['accountbranch'],
          'chit no':'test',
          'accountname':credentials['accountname'],
          'accountnumber':credentials['accountnumber'],
          'ifc code':credentials['ifccode'],
        }
      );
      dynamic planres=await addSelectedPlanToUser(result.user.uid, credentials['plan']);
      bool done=await Approval(uid:result.user.uid).addNewUid(credentials['name'],credentials['fmcToken']);
      if(done==false||planres==null){
        return null;
      }else{
        return "Sucess";
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  //Dropdown plans
  Future dropdownplans()async{
    try{
      QuerySnapshot result= await _dropdownref.getDocuments();
      print(result);
      return querysnptoplan(result);
    }catch(e){
      print(e);
      return null;
    }
  }

  Future addSelectedPlanToUser(String uid,String plan)async{
    try{
    DocumentSnapshot snp=await _dropdownref.document('$plan').get();
    await _firestore.document('$uid').updateData({
      'chit type':snp.data['chit plan'],
      'chit validity':snp.data['tenor'],
      'monthly amt':snp.data['monthly amt'],
      'amount':snp.data['amount']
    });
    return "Sucess";
    }catch(e){
      return null;
    }
  }

}

class Approval{
  CollectionReference _approval=Firestore.instance.collection('Approval');
  String uid;
  Approval({this.uid});

  Future<bool> addNewUid(String name,String fmcToken)async{
    try{
    await _approval.document('$uid').setData({
      'IsApproved':false,
      'name':name,
      'fmcToken':fmcToken,
      'created':DateTime.now()
    });
    return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> checkApproval()async{
    try{
      DocumentSnapshot snp=await _approval.document('$uid').get();
      return snp.data['IsApproved'];
    }catch(e){
      return false;
    }
  }


}