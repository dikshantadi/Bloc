import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart'; // your DioApiClient file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Dio
  final dio = Dio();

  // Initialize your API client
  final apiClient = DioApiClient(
    dio: dio,
    preferences: prefs,
    baseUrl: "https://jsonplaceholder.typicode.com", // example API
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

    // Call the API
    final response = await widget.apiClient.request<Map<String, dynamic>>(
      path: "/users/1",
      method: Method_Type.get,
    );

    // Check the result
    if (response.success) {
      setState(() {
        _result = "✅ Success: ${response.data}";
      });
    } else {
      setState(() {
        _result = "❌ Error: ${response.error?.message}";
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
