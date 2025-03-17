import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(CarComparisonApp());
}

class CarComparisonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CarComparisonPage(),
    );
  }
}

class CarComparisonPage extends StatefulWidget {
  @override
  _CarComparisonPageState createState() => _CarComparisonPageState();
}

class _CarComparisonPageState extends State<CarComparisonPage> {
  String? selectedCar1;
  String? selectedCar2;
  List<Map<String, String>> carList = [];
  Map<String, String> carNameToIdMap = {};

  @override
  void initState() {
    super.initState();
    fetchCarList();
  }

  /// Fetch car names and IDs from Firestore.
  Future<void> fetchCarList() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Cars').get();

      setState(() {
        carList = querySnapshot.docs.map((doc) {
          String carId = doc.id;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String carName = data["name"] ?? "Unknown";

          // Store mapping for quick lookup
          carNameToIdMap[carName] = carId;
          return {"id": carId, "name": carName};
        }).toList();
      });
    } catch (e) {
      print("Error fetching car list: $e");
    }
  }

  /// Fetch car details from Firestore dynamically and navigate to comparison page.
  Future<void> compareCars() async {
    if (selectedCar1 != null && selectedCar2 != null) {
      try {
        String car1Id = carNameToIdMap[selectedCar1!]!;
        String car2Id = carNameToIdMap[selectedCar2!]!;

        DocumentSnapshot car1Snapshot = await FirebaseFirestore.instance
            .collection('Cars')
            .doc(car1Id)
            .get();
        DocumentSnapshot car2Snapshot = await FirebaseFirestore.instance
            .collection('Cars')
            .doc(car2Id)
            .get();

        Map<String, dynamic> car1Details =
            car1Snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> car2Details =
            car2Snapshot.data() as Map<String, dynamic>;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultPage(
              car1: car1Details,
              car2: car2Details,
            ),
          ),
        );
      } catch (e) {
        print("Error fetching car details: $e");
      }
    }
  }

  // Function to fetch car details by name
  Future<Map<String, dynamic>> fetchCarDetailsByName(String carName) async {
    //String? carId = carNameToIdMap[carName];
    //if (carId != null) {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Cars')
        .where('name', isEqualTo: carName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming car names are unique
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      print("Car ID not found for car name: $carName");
      return {}; // Return an empty map if car details not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Compare Cars", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: carList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DropdownButton<String>(
                              hint: Text("Select Car",
                                  style: TextStyle(color: Colors.white)),
                              dropdownColor: Colors.black,
                              value: selectedCar1,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCar1 = newValue;
                                });
                              },
                              items: carList.map((car) {
                                return DropdownMenuItem<String>(
                                  value: car["name"],
                                  child: Text(car["name"]!,
                                      style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                            ),
                            Text("VS",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            DropdownButton<String>(
                              hint: Text("Select Car",
                                  style: TextStyle(color: Colors.white)),
                              dropdownColor: Colors.black,
                              value: selectedCar2,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCar2 = newValue;
                                });
                              },
                              items: carList.map((car) {
                                return DropdownMenuItem<String>(
                                  value: car["name"],
                                  child: Text(car["name"]!,
                                      style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: compareCars,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text("Compare"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "POPULAR CAR COMPARISONS",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2, // Now displaying 2 comparisons
                      itemBuilder: (context, index) {
                        // Define car details based on the index
                        String car1Name;
                        String car2Name;
                        String car1Price = "";
                        String car2Price = "";
                        String car1ImagePath;
                        String car2ImagePath;
                        if (index == 0) {
                          // First comparison: Nexon vs. Sonet
                          car1Name = "Tata Harrier";
                          car2Name = "Kia Sonet";
                          car1ImagePath =
                              'assets/harrier.png'; // Replace with your actual asset
                          car2ImagePath =
                              'assets/white-offroader-jeep-parking.png'; // Replace with your actual asset
                        } else {
                          // Second comparison: BMW vs. Audi
                          car1Name = "BMW 3 Series";
                          car2Name = "Audi Q5";
                          car1ImagePath =
                              'assets/bmw.png'; // Replace with your actual asset
                          car2ImagePath =
                              'assets/pexels-samyantak-mohanty-79378681-8706096.png'; // Replace with your actual asset
                        }

                        return InkWell(
                          onTap: () async {
                            // Fetch car details from Firestore
                            Map<String, dynamic> car1Details =
                                await fetchCarDetailsByName(car1Name);
                            Map<String, dynamic> car2Details =
                                await fetchCarDetailsByName(car2Name);

                            // Navigate to the comparison page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComparisonResultPage(
                                  car1: car1Details,
                                  car2: car2Details,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          car1ImagePath,
                                          width: 120,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          car1Name,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "$car1Price onwards",
                                          style: TextStyle(color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text("VS",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          car2ImagePath,
                                          width: 120,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          car2Name,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "$car2Price onwards",
                                          style: TextStyle(color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ComparisonResultPage extends StatelessWidget {
  final Map<String, dynamic> car1;
  final Map<String, dynamic> car2;
  ComparisonResultPage({required this.car1, required this.car2});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Car Comparison", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: TableBorder.all(color: Colors.white),
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            buildTableRow("Feature", car1["name"], car2["name"],
                isHeader: true),
            buildTableRow("Price", car1["price"], car2["price"]),
            buildTableRow("Engine", car1["engine"], car2["engine"]),
            buildTableRow("Mileage", car1["mileage"], car2["mileage"]),
            buildTableRow("Horsepower", car1["horsepower"], car2["horsepower"]),
            buildTableRow("Torque", car1["torque"], car2["torque"]),
            buildTableRow("Fuel Type", car1["fuel"], car2["fuel"]),
            buildTableRow(
                "Transmission", car1["transmission"], car2["transmission"]),
            buildTableRow("Seating Capacity", car1["seating"], car2["seating"]),
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(String feature, dynamic value1, dynamic value2,
      {bool isHeader = false}) {
    return TableRow(
      decoration:
          BoxDecoration(color: isHeader ? Colors.grey[850] : Colors.black),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(feature,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value1.toString(), style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value2.toString(), style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
