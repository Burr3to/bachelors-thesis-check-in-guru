import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/models/action/bulk_subtask_complete_model.dart';
// + model pre response ak treba

part 'subtask_instance_api_service.g.dart';

@RestApi()
abstract class SubtaskInstanceApiService {
  factory SubtaskInstanceApiService(Dio dio, {String baseUrl}) = _SubtaskInstanceApiService;

  @POST('api/SubtaskInstance/bulk-complete')
  Future<dynamic> bulkComplete(@Body() BulkSubtaskCompleteModel body);
}