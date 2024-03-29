import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseflutter2/Models/Planmodel.dart';

class Registration {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _firestore = Firestore.instance.collection("brews");
  CollectionReference _dropdownref = Firestore.instance.collection("Plans");
  CollectionReference _approval = Firestore.instance.collection('Approval');

  //Changing querysnapshot to data model
  List<plan> querysnptoplan(QuerySnapshot snapshot) {
    List<plan> _list = [];
    for (DocumentSnapshot doc in snapshot.documents) {
      _list.add(plan(
        chitPlan: doc.data['chit plan'],
        amount: doc.data['amount'],
        monthlyAmt: doc.data['monthly amt'],
        tenor: doc.data['tenor'],
        eMI: doc.data['emi'],
        type: doc.data['type'],
      ));
    }
    return _list;
  }

  //New User registration
  Future registerNewUser(String email, Map<String, dynamic> credentials) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: credentials['password']);
      print("Created user");
      await _firestore.document(result.user.uid).setData({
        'name': credentials['name'],
        'accountbranch': credentials['accountbranch'],
        'accountname': credentials['accountname'],
        'accountnumber': credentials['accountnumber'],
        'ifc code': credentials['ifccode'],
        'mob no': credentials['mob no'],
        'address': credentials['adress'],
        'pincode': credentials['pincode'],
        'city': credentials['city'],
        'state': credentials['state'],
        'adhaarno': credentials['adhaarno'],
      });
      // dynamic planres=await addSelectedPlanToUser(result.user.uid, credentials['plan'],credentials['selectedAmount']);
      bool done = await Approval(uid: result.user.uid)
          .addNewUid(credentials['name'], credentials['fmcToken']);
      if (done == false) {
        return 'null';
      } else {
        return "Sucess";
      }
    } catch (e) {
      print(e.code);
      return e.code.toString();
    }
  }

  //Dropdown plans
  Future dropdownplans() async {
    try {
      QuerySnapshot result = await _dropdownref.getDocuments();
      print(result);
      return querysnptoplan(result);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future addSelectedPlanToUser(String uid, String plan, String selectedAmount,
      String type, String quanity) async {
    try {
      DocumentSnapshot snp = await _dropdownref.document('$plan').get();
      if (type == 'edmchit') {
        await _firestore.document('$uid').updateData({
          'chit type': snp.data['chit plan'],
          'chit validity': snp.data['tenor'],
          'monthly amt':
              (int.parse(snp.data['emi']) * int.parse(quanity)).toString(),
          'amount': selectedAmount,
          'type': type,
          'time': Timestamp.now()
        });
      } else {
        await _firestore.document('$uid').updateData({
          'chit type': snp.data['chit plan'],
          'chit validity': snp.data['tenor'],
          'monthly amt':
              (int.parse(snp.data['emi']) * int.parse(quanity)).toString(),
          'amount': selectedAmount,
          'type': type,
          'time': Timestamp.now(),
          'bgchit_quantity': quanity,
        });
      }
      await _approval
          .document('$uid')
          .updateData({'PlanState': 'submitted', 'created': Timestamp.now()});
      return "Sucess";
    } catch (e) {
      return null;
    }
  }
}

class Approval {
  CollectionReference _approval = Firestore.instance.collection('Approval');
  String uid;
  Approval({this.uid});

  Future<bool> addNewUid(String name, String fmcToken) async {
    try {
      await _approval.document('$uid').setData({
        'IsApproved': false,
        'PlanState': 'none',
        'name': name,
        'uid': uid,
        'fmcToken': fmcToken,
        'created': Timestamp.now()
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<DocumentSnapshot> get checkApproval {
    try {
      return _approval.document('$uid').snapshots();
      // return snp.map(streamhelper);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
