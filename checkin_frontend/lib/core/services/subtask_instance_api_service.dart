import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/subtask_instance/bulk_subtask_complete_model.dart';

part 'subtask_instance_api_service.g.dart';

/// API service for handling actions on specific subtask execution instances.
@RestApi()
abstract class SubtaskInstanceApiService {
  factory SubtaskInstanceApiService(Dio dio, {String baseUrl}) = _SubtaskInstanceApiService;

  /// Submits a request to complete multiple subtask instances at once.
  /// Used in both Individual and Shared modes to process checking off items.
  @POST('api/SubtaskInstance/bulk-complete')
  Future<dynamic> bulkComplete(@Body() BulkSubtaskCompleteModel body);
}