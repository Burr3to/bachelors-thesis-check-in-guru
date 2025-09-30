import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model.dart';
import 'package:checkin_frontend/config/app_constants.dart';

// Api calls for CheckInEvents
// Fetching for specific user, needs auth with JWT token
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
    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_jwtToken', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CheckInEventListModel.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception(
          'Failed to load check-in events. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e, st) {
      throw Exception('Network error: $e');
    }
  }
}
