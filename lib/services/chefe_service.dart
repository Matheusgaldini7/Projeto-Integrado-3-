import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chefe.dart';

class ChefeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<Chefe?> carregarChefe(String id) async {
    final doc = await _firestore
        .collection('chefes')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return Chefe.fromMap(doc.data()!);
  }
}