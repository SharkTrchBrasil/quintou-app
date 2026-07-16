import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://ifo1usk4zzs6kf3w1axrg1y9.207.180.251.156.sslip.io'));
  
  try {
    final res = await dio.get('/spaces/my');
    print('SUCCESS: \${res.statusCode}');
  } on DioException catch (e) {
    print('ERROR: \${e.response?.statusCode} - \${e.message}');
  }
}
