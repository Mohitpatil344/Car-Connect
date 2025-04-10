import 'package:flutter/material.dart';
import 'dart:math';

class BudgetPage extends StatefulWidget {
  final String? carName;
  final double? exShowroomPrice;
  final String? carType;

  BudgetPage({this.carName, this.exShowroomPrice, this.carType});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();

  String? carName, carType;
  double? exShowroomPrice, totalCost, loanEMI, totalLoanPayment;
  double gst = 0,
      cess = 0,
      roadTax = 0,
      insurance = 0,
      registration = 0,
      fastag = 500,
      accessories = 20000;

  @override
  void initState() {
    super.initState();
    if (widget.carName != null) {
      _carNameController.text = widget.carName!;
      carName = widget.carName;
    }
    if (widget.exShowroomPrice != null) {
      _priceController.text = widget.exShowroomPrice!.toString();
      exShowroomPrice = widget.exShowroomPrice;
    }
    if (widget.carType != null) {
      carType = widget.carType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Dark background
        title: const Text(
          'Car Budget & Loan Calculator',
          style: TextStyle(color: Colors.white), // White text
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(_carNameController, 'Car Name'),
            _buildInputField(
                _priceController, 'Ex-Showroom Price (₹)/Your estimated price',
                isNumeric: true),
            _buildDropdownField(),
            _buildInputField(_interestController, 'Interest Rate (%)',
                isNumeric: true),
            _buildInputField(_durationController, 'Loan Duration (Years)',
                isNumeric: true),
            _buildInputField(
                _downPaymentController, 'Down Payment (₹, Optional)',
                isNumeric: true),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateTotalCost,
              child: const Text('Get Cost Breakdown'),
            ),
            if (totalCost != null) ...[
              _buildCostBreakdown(),
              ElevatedButton(
                onPressed: _showDetailedBreakdown,
                child: const Text('Show Detailed Breakdown'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: carType,
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Select Car Type'),
      items: [
        'Small Car',
        'Mid-Size Car',
        'SUV',
        'Electric Vehicle (EV)',
        'Luxury Car (₹20L+)'
      ]
          .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type, style: const TextStyle(color: Colors.white))))
          .toList(),
      onChanged: (value) => setState(() => carType = value),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        onChanged: (value) {
          if (controller == _priceController) {
            setState(() {
              exShowroomPrice = double.tryParse(value) ?? 0;
            });
          }
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: const OutlineInputBorder(),
    );
  }

  void _calculateTotalCost() {
    double interestRate = double.tryParse(_interestController.text) ?? 0;
    int loanDuration = int.tryParse(_durationController.text) ?? 0;
    double downPayment = double.tryParse(_downPaymentController.text) ?? 0;

    if (exShowroomPrice == null || carType == null) return;

    // Apply tax rules based on car type
    if (carType == 'Small Car') {
      gst = exShowroomPrice! * 0.28;
      cess = exShowroomPrice! * 0.03;
      roadTax = exShowroomPrice! * 0.08;
      insurance = exShowroomPrice! * 0.05;
      registration = 5000;
    } else if (carType == 'Mid-Size Car') {
      gst = exShowroomPrice! * 0.28;
      cess = exShowroomPrice! * 0.15;
      roadTax = exShowroomPrice! * 0.10;
      insurance = exShowroomPrice! * 0.05;
      registration = 10000;
    } else if (carType == 'SUV') {
      gst = exShowroomPrice! * 0.28;
      cess = exShowroomPrice! * 0.22;
      roadTax = exShowroomPrice! * 0.12;
      insurance = exShowroomPrice! * 0.06;
      registration = 15000;
    } else if (carType == 'Electric Vehicle (EV)') {
      gst = exShowroomPrice! * 0.05;
      cess = 0;
      roadTax = 0;
      insurance = exShowroomPrice! * 0.04;
      registration = 0;
    } else if (carType == 'Luxury Car (₹20L+)') {
      gst = exShowroomPrice! * 0.28;
      cess = exShowroomPrice! * 0.22;
      roadTax = exShowroomPrice! * 0.15;
      insurance = exShowroomPrice! * 0.06;
      registration = 20000;
    }

    // Calculate total on-road cost
    totalCost = exShowroomPrice! +
        gst +
        cess +
        roadTax +
        insurance +
        registration +
        fastag +
        accessories;

    // Calculate Loan EMI & Total Loan Cost
    double loanAmount = totalCost! - downPayment;
    double monthlyRate = (interestRate / 100) / 12;
    int totalMonths = loanDuration * 12;

    if (loanAmount > 0 && monthlyRate > 0 && totalMonths > 0) {
      loanEMI = (loanAmount * monthlyRate * pow(1 + monthlyRate, totalMonths)) /
          (pow(1 + monthlyRate, totalMonths) - 1);
      totalLoanPayment = loanEMI! * totalMonths;
    }

    setState(() {});
  }

  Widget _buildCostBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Breakdown for $carName ($carType)',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        _buildCostRow('Total On-Road Price (Without Loan)', totalCost!,
            isTotal: true),
        if (loanEMI != null && totalLoanPayment != null) ...[
          _buildCostRow('Monthly EMI', loanEMI!, isTotal: true),
          _buildCostRow('Total Cost with Loan & Interest', totalLoanPayment!,
              isTotal: true),
        ],
      ],
    );
  }

  Widget _buildCostRow(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showDetailedBreakdown() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Detailed Cost Breakdown for $carName ($carType)',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCostRow('Ex-Showroom Price', exShowroomPrice!),
                _buildCostRow('GST', gst),
                _buildCostRow('Cess', cess),
                _buildCostRow('Road Tax', roadTax),
                _buildCostRow('Insurance', insurance),
                _buildCostRow('Registration', registration),
                _buildCostRow('Fastag', fastag),
                _buildCostRow('Accessories', accessories),
                _buildCostRow('Total On-Road Price', totalCost!, isTotal: true),
                if (loanEMI != null && totalLoanPayment != null) ...[
                  _buildCostRow(
                      'Loan Amount',
                      totalCost! -
                          (double.tryParse(_downPaymentController.text) ?? 0)),
                  _buildCostRow('Monthly EMI', loanEMI!),
                  _buildCostRow('Total Loan Payment', totalLoanPayment!),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
