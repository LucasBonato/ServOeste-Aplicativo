import 'package:flutter/material.dart';

class Home extends StatelessWidget {
	const Home({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: ListView(
				children: const <Widget>[
					ListTile(
						leading: Icon(Icons.home),
						title: Text("Home"),
					),
					ListTile(
						leading: Icon(Icons.home),
						title: Text("Home"),
					),
					ListTile(
						leading: Icon(Icons.home),
						title: Text("Home"),
					),
					ListTile(
						leading: Icon(Icons.home),
						title: Text("Home"),
					),
					ListTile(
						leading: Icon(Icons.home),
						title: Text("Home"),
					)
				],
			),
		);
	}
}
