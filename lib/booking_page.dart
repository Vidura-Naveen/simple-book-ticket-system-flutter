//reset seats
import 'package:bookpart/reset_seats.dart';
//reset seats
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirmation_page.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  //reset seats
  final SeatResetService _seatResetService = SeatResetService();
  //reset seats
  List<int> newlyBookedSeats = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _seatCollection =
      FirebaseFirestore.instance.collection('seatCollection');

  List<bool> seatStatus = List.generate(15, (index) => false);

  Future<List<bool>> getSeatStatusFromFirebase() async {
    DocumentSnapshot document =
        await _seatCollection.doc('your_document_id').get();

    if (document.exists) {
      // If the document exists, return the seatStatus list
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      if (data != null && data.containsKey('seatStatus')) {
        List<dynamic> seatStatusData = data['seatStatus'];
        return seatStatusData.map((status) => status as bool).toList();
      }
    }

    // If the document doesn't exist or doesn't contain the seatStatus field, return a default list
    return List.generate(15, (index) => false);
  }

  Future<void> createSeatDocument() async {
    DocumentSnapshot document =
        await _seatCollection.doc('your_document_id').get();

    if (!document.exists) {
      // Create the document if it doesn't exist
      await _seatCollection.doc('your_document_id').set({
        'seatStatus': List.generate(15, (index) => false),
      });
    }
  }

  Future<void> updateSeatStatus(int index, bool booked) async {
    // Ensure the document exists before updating
    await createSeatDocument();

    // Update the seat status
    DocumentReference docRef = _seatCollection.doc('your_document_id');
    Map<String, dynamic> data =
        (await docRef.get()).data() as Map<String, dynamic>;

    if (data != null && data.containsKey('seatStatus')) {
      List<bool> updatedStatus = List.from(data['seatStatus']);
      updatedStatus[index] = booked;

      await docRef.update({'seatStatus': updatedStatus});
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch seat status from Firebase during initialization
    getSeatStatusFromFirebase().then((seatStatusFromFirebase) {
      setState(() {
        seatStatus = seatStatusFromFirebase;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Booking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: seatStatus.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  if (!seatStatus[index]) {
                    // Only allow clicking on green (unbooked) seats
                    setState(() {
                      seatStatus[index] = !seatStatus[index];
                      if (!newlyBookedSeats.contains(index)) {
                        newlyBookedSeats.add(index);
                      }
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: seatStatus[index] ? Colors.red : Colors.green,
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      seatStatus[index] ? 'Booked' : 'Seat $index',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: seatStatus[index] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                List<int> bookedSeats = seatStatus
                    .asMap()
                    .entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();

                // Update Firestore with booked seat information
                for (int index in bookedSeats) {
                  await updateSeatStatus(index, true);
                }

                // Pass the newly booked seats to ConfirmationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationPage(
                      newlyBookedSeats: newlyBookedSeats,
                    ),
                  ),
                );
              },
              child: Text('Submit Booking'),
            ),
            SizedBox(height: 20),
            //reset seats
            ElevatedButton(
              onPressed: () async {
                // ... existing code ...
                // Reset all seats
                await _seatResetService.resetAllSeats();
              },
              child: Text('Reset All Seats'),
            ),
            //reset seats
          ],
        ),
      ),
    );
  }
}
