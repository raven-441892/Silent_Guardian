import 'package:flutter/material.dart';
import 'header.dart';

class SilentPanicTriggerScreen extends StatefulWidget {
  const SilentPanicTriggerScreen({super.key});

  @override
  State<SilentPanicTriggerScreen> createState() =>
      _SilentPanicTriggerScreenState();
}

class _SilentPanicTriggerScreenState
    extends State<SilentPanicTriggerScreen> {

  List<String> _sequence = [];

  void _addStep(String step) {
    if (_sequence.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 5 steps allowed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _sequence.add(step);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _sequence.removeAt(index);
    });
  }

  void _clearSequence() {
    setState(() {
      _sequence.clear();
    });
  }

  void _saveSequence() {
    if (_sequence.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Minimum 3 steps required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Panic trigger sequence saved"),
        backgroundColor: Colors.green,
      ),
    );
  }


  Widget _buildSequenceDisplay() {
    if (_sequence.isEmpty) {
      return const Text(
        "No sequence added yet",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 8,
      children: List.generate(_sequence.length, (index) {
        return Chip(
          label: Text(_sequence[index]),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => _removeStep(index),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const AppHeader(enableSignInNavigation: false),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Silent Panic Trigger",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            const Text(
              "Build your secret volume button sequence",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Add buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addStep("MAX"),
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Volume Max"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addStep("MIN"),
                  icon: const Icon(Icons.volume_down),
                  label: const Text("Volume Min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Sequence:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            _buildSequenceDisplay(),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearSequence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Clear"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSequence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Save Sequence"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "⚠ When triggered, a 3-second timer will appear before sending alerts.",
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }
}
