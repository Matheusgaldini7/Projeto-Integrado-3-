import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';

class SkillsRepository {
  static Map<String, Skill> skills = {};

  static Future<void> carregarSkills() async {
    final snapshot = await FirebaseFirestore.instance.collection('skills').get();
    skills = {
      for (var doc in snapshot.docs)
        doc.id: Skill.fromFirestore(doc.id, doc.data())
    };
  }
  static Skill? getSkill(String id) => skills[id];
}