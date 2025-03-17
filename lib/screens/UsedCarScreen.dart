import 'package:flutter/material.dart';
import 'package:proj1/screens/FilteredUsedCarsScreen.dart';

class UsedCarScreen extends StatefulWidget {
  @override
  _UsedCarScreenState createState() => _UsedCarScreenState();
}

class _UsedCarScreenState extends State<UsedCarScreen> {
  RangeValues _budgetRange = const RangeValues(0, 50); // Budget in Lakh

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Find the Right Used Car",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBudgetSelector(),
            const SizedBox(height: 20),
            _buildFindCarButton(),
            const SizedBox(height: 30),
            _buildSellCarSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/white-offroader-jeep-parking.png', // Replace with your image
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text("Choose your Budget",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          RangeSlider(
            values: _budgetRange,
            min: 0,
            max: 100, // Max budget in Lakh
            divisions: 50,
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            labels: RangeLabels("${_budgetRange.start.toInt()} Lakh",
                "${_budgetRange.end.toInt()} Lakh"),
            onChanged: (RangeValues values) {
              setState(() {
                _budgetRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_budgetRange.start.toInt()} Lakh",
                  style: const TextStyle(color: Colors.white)),
              Text("${_budgetRange.end.toInt()} Lakh",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFindCarButton() {
    return ElevatedButton(
      onPressed: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FilteredUsedCarsScreen(
      minPrice: 0,
      maxPrice: 5000000,
    ),
  ),
);

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("Find Used Car"),
    );
  }

  Widget _buildSellCarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Want to Sell Your Car?",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          _buildSellCarOption(
              Icons.email, "Get buyers' details via SMS and Email"),
          _buildSellCarOption(
              Icons.attach_money, "Sell your car at best price"),
          _buildSellCarOption(Icons.group, "Large number of genuine buyers"),
          const SizedBox(height: 10),
          _buildSellCarButton(),
        ],
      ),
    );
  }

  Widget _buildSellCarOption(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  Widget _buildSellCarButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("Sell Car Online"),
    );
  }
}
