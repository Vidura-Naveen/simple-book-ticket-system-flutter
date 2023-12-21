import 'package:cloud_firestore/cloud_firestore.dart';

class SeatResetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _seatCollection =
      FirebaseFirestore.instance.collection('seatCollection');

  Future<void> resetAllSeats() async {
    await _seatCollection.doc('your_document_id').update({
      'seatStatus': List.generate(15, (index) => false),
    });
  }
}
