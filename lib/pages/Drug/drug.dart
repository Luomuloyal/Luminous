import 'package:flutter/material.dart';

class DrugView extends StatefulWidget {
  const DrugView({super.key});

  @override
  State<DrugView> createState() => _DrugViewState();
}

class _DrugViewState extends State<DrugView> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("药品"));
  }
}
