import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilteredUsedCarsScreen extends StatefulWidget {
  final int minPrice;
  final int maxPrice;

  const FilteredUsedCarsScreen({Key? key, required this.minPrice, required this.maxPrice}) : super(key: key);

  @override
  _FilteredUsedCarsScreenState createState() => _FilteredUsedCarsScreenState();
}

class _FilteredUsedCarsScreenState extends State<FilteredUsedCarsScreen> {
  List<Map<String, dynamic>> usedCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsedCars();
  }

Future<void> fetchUsedCars() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Cars')  // ✅ Ensure collection name is correct
        .get(); // Fetch all to check if data exists

    print("Fetched ${querySnapshot.docs.length} cars from Firestore");

    setState(() {
      usedCars = querySnapshot.docs.map((doc) {
        Map<String, dynamic> carData = doc.data() as Map<String, dynamic>;
        print("Car Data: $carData"); // ✅ Debug to check if `name` and `price` exist

        return {
          "id": doc.id,
          "name": carData["name"] ?? "Unknown Name",
          "price": carData["price"] ?? 0,
        };
      }).toList();
      _isLoading = false;
    });
  } catch (e) {
    print("Error fetching cars: $e");
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtered Used Cars"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : usedCars.isEmpty
              ? const Center(
                  child: Text(
                    "No used cars found in this price range",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: usedCars.length,
                  itemBuilder: (context, index) {
                    var car = usedCars[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.white),
                        title: Text(
                          car["name"],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${(car["price"] / 100000).toStringAsFixed(1)} Lakh",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
