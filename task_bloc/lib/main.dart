import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/network/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final dio = Dio();

  final apiClient = DioApiClient(
    dio: dio,
    preferences: prefs,
    baseUrl: "https://jsonplaceholder.typicode.com",
  );

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final DioApiClient apiClient;

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('API Test')),
        body: ApiTestWidget(apiClient: apiClient),
      ),
    );
  }
}

class ApiTestWidget extends StatefulWidget {
  final DioApiClient apiClient;

  const ApiTestWidget({super.key, required this.apiClient});

  @override
  State<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  String _result = "Press the button to fetch data";

  Future<void> _fetchData() async {
    setState(() {
      _result = "Loading...";
    });

    final response = await widget.apiClient.request<Map<String, dynamic>>(
      path: "/users/1",
      method: Method_Type.get,
    );

    if (response.success) {
      setState(() {
        _result = "Success: ${response.data}";
      });
    } else {
      setState(() {
        _result = "Error: ${response.error?.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text("Fetch User Data"),
            ),
          ],
        ),
      ),
    );
  }
}
