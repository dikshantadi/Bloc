import 'package:flutter/material.dart';
import 'networkservice.dart';
import 'network_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = Api();

  NetworkResponse? result = await api.apiCall(
    '/users/1',
    null,
    null,
    RequestType.GET,
  );

  result?.when(
    success: (data) => print('✅ Success: $data'),
    error: (msg) => print('❌ Error: $msg'),
    loading: (msg) => print('⏳ Loading: $msg'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Check console for API test result')),
      ),
    );
  }
}
