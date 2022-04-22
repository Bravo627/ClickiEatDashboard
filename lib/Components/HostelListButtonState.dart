import 'package:flutter/material.dart';

class HostelListButton extends StatefulWidget {
  final TextEditingController controller;
  final List<String> hostelsName;

  const HostelListButton(
      {Key? key, required this.controller, required this.hostelsName})
      : super(key: key);

  @override
  State<HostelListButton> createState() => _HostelListButtonState();
}

class _HostelListButtonState extends State<HostelListButton> {
  late String selectedHostelName;

  @override
  void initState() {
    super.initState();
    selectedHostelName = widget.hostelsName.first;
    widget.controller.text = widget.hostelsName.first;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return DropdownButtonFormField(
      value: selectedHostelName,
      decoration: InputDecoration(
        labelText: "Hostel",
        labelStyle: Theme.of(context).textTheme.labelMedium,
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      items: widget.hostelsName.map((e) {
        return DropdownMenuItem(
          child: Text(
            e,
            style: TextStyle(color: Colors.black),
          ),
          value: e,
        );
      }).toList(),
      menuMaxHeight: screenHeight * 0.6,
      isExpanded: true,
      onChanged: (String? value) {
        if (value != null) {
          widget.controller.text = value;

          setState(() {
            selectedHostelName = value;
          });
        }
      },
    );
  }
}