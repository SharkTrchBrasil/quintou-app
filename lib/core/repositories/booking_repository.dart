import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/models/booking_model.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    final response = await _apiClient.dio.post('/bookings/', data: bookingData);
    return Booking.fromJson(response.data);
  }

  Future<List<Booking>> getMyBookings({int limit = 20, int offset = 0}) async {
    final response = await _apiClient.dio.get('/bookings/my', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => Booking.fromJson(json)).toList();
  }

  Future<Booking> getBooking(String id) async {
    final response = await _apiClient.dio.get('/bookings/$id');
    return Booking.fromJson(response.data);
  }

  Future<List<Booking>> getGuestBookings() async {
    final response = await _apiClient.dio.get('/bookings/my');
    return (response.data as List).map((json) => Booking.fromJson(json)).toList();
  }

  Future<List<Booking>> getHostBookings() async {
    final response = await _apiClient.dio.get('/bookings/host');
    return (response.data as List).map((json) => Booking.fromJson(json)).toList();
  }
}
