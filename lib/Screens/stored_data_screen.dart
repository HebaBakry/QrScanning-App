import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Models/answer_model.dart';
import '../Models/data_model.dart';

class DataScreen extends StatefulWidget {
  final int keyValue;

  const DataScreen({super.key, required this.keyValue});

  @override
  DataScreenState createState() => DataScreenState();
}

class DataScreenState extends State<DataScreen> {
  String userName = 'Heba Bakry';
  Map<int, String?> selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('data');
    String storedData = box.get(widget.keyValue, defaultValue: 'No data found.');

    if (storedData == 'No data found.') {
      return Scaffold(
        body: Center(child: Text(storedData)),
      );
    }

    final data = Data.fromJson(jsonDecode(storedData));

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: data.questions.length,
                    itemBuilder: (context, index) {
                      final question = data.questions[index];
                      return Card(
                        margin: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.questionText,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 10.0),
                              ...question.options.map((option) {
                                return ListTile(
                                  title: Text(option),
                                  leading: Radio<String>(
                                    value: option,
                                    groupValue: selectedOptions[index],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedOptions[index] = value;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      // Ensure all questions are answered
                      if (selectedOptions.length == data.questions.length) {
                        for (int i = 0; i < data.questions.length; i++) {
                          final selectedAnswer = selectedOptions[i];
                          if (selectedAnswer != null) {
                            final newAnswer = Answer(
                              user: userName,
                              answer: selectedAnswer,
                              timestamp: DateTime.now(),
                            );
                            setState(() {
                              data.questions[i].answers?.add(newAnswer);
                            });
                          }
                        }
            
                        print("data: $data");
            
                        var connectivityResult =
                        await Connectivity().checkConnectivity();
                        if (connectivityResult[0] == ConnectivityResult.none) {
                          // Save as an unsynced data if offline
                          var unsyncedBox = Hive.box('unsynced_data');
                          await unsyncedBox.put(widget.keyValue, jsonEncode(data.toJson()));
                        }
                        else{
                          //if already online sync data direct
                          print('send data to server');
                        }
            
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All answers submitted.'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please answer all questions before submitting.'),
                        ));
                      }
                      Navigator.pop(context);
                    },
                    child: const Center(child: Text('Submit Answers',style: TextStyle(color: Colors.black),)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
