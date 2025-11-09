import 'network_response.dart';

void main() {
  final response = NetworkResponse.success({'id': 1});

  response.when(
    success: (data) => print('Success: $data'),
    error: (msg) => print('Error: $msg'),
    loading: (msg) => print('Loading: ${msg ?? "loading"}'),
  );
}
