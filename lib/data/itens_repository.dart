import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itens.dart';

class ItensRepository {
  static Map<String, ItemBatalha> itens = {};

  static Future<void> carregarItens() async {
    final snapshot = await FirebaseFirestore.instance.collection('itens').get();
    
    itens = {
      for (var doc in snapshot.docs)
        doc.id.toLowerCase(): ItemBatalha.fromFirestore(doc.id, doc.data())
    };
  }

  static ItemBatalha? getItem(String nome) => itens[nome.toLowerCase()];
}