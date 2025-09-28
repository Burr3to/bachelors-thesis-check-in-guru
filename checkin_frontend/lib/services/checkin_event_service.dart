import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model.dart';

// Dočasná URL pre lokálny backend (použite HTTP, ak je kontajner lokálny)
const String _baseUrl = 'http://localhost:5113/api/CheckInEvent';

class CheckInEventService {
  // Hardcoded ID
  final String _testOwnerId = '11111111-1111-1111-1111-111111111111';

  // Fasáda v backende používa generický endpoint GET /api/CheckInEvent
  // s parametrom strFilterAtrib a strFilter (OwnerId)
  Future<List<CheckInEventListModel>> getMyCheckInEvents() async {
    final uri = Uri.parse(
      '$_baseUrl?strFilterAtrib=OwnerId&strFilter=$_testOwnerId',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList
            .map((json) => CheckInEventListModel.fromJson(json))
            .toList();
      } else {
        // Chyba zo servera (napr. 404, 500)
        throw Exception(
          'Failed to load check-in events. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
