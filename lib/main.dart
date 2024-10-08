import 'package:flutter/material.dart';
import 'package:serv_oeste/src/shared/custom_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'ServOeste',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
				useMaterial3: true,
			),
			initialRoute: "/",
			routes: CustomRouter.getRoutes(context)
		);
	}
}