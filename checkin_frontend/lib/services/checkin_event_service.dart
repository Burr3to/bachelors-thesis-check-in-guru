import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model.dart';
import 'package:checkin_frontend/config/app_constants.dart';

const String _baseUrl = 'http://localhost:7084/api/CheckInEvent';

class CheckInEventService {
  final String _jwtToken;
  final String _ownerId;

  CheckInEventService({required String jwtToken, required String ownerId})
    : _jwtToken = jwtToken,
      _ownerId = ownerId;

  Future<List<CheckInEventListModel>> getMyCheckInEvents() async {
    final uri = Uri.parse(
      '$kBackendCheckInEventBaseEndpoint?strFilterAtrib=OwnerId&strFilter'
      '=$_ownerId',
    );
    print('CheckInEventService: Načítavam udalosti z URI: $uri'); // DIAGNOSTIKA
    print(
      'CheckInEventService: Používam token, ktorý začína: ${_jwtToken.substring(0, 10)}...',
    ); // DIAGNOSTIKA

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_jwtToken', 'Content-Type': 'application/json'},
      );

      print(
        'CheckInEventService: API odpoveď z /api/CheckInEvent - Status: ${response.statusCode}, Body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}',
      ); // DIAGNOSTIKA

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print(
          'CheckInEventService: Úspešne načítaných ${jsonList.length} udalostí.',
        ); // DIAGNOSTIKA
        return jsonList.map((json) => CheckInEventListModel.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('CheckInEventService: UNAUTHORIZED/FORBIDDEN prístup pre $uri.'); // DIAGNOSTIKA
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        print(
          'CheckInEventService: Zlyhalo načítanie udalostí so statusom ${response.statusCode}.',
        ); // DIAGNOSTIKA
        throw Exception(
          'Failed to load check-in events. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e, st) {
      print(
        'CheckInEventService: Chyba siete/žiadosti pri načítaní udalostí: $e\n$st',
      ); // DIAGNOSTIKA
      throw Exception('Network error: $e');
    }
  }
}
