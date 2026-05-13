import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/subtask_template/subtask_template_create_model.dart';
import '../models/subtask_template/subtask_template_detail_model.dart';
import '../models/subtask_template/subtask_template_update_model.dart';

part 'subtask_template_api_service.g.dart';

/// API service for managing subtask templates (blueprints).
/// Changes to templates typically affect all future or existing instances depending on the task mode.
@RestApi()
abstract class SubtaskTemplateApiService {
  factory SubtaskTemplateApiService(Dio dio, {String baseUrl}) = _SubtaskTemplateApiService;

  /// Creates a new subtask template definition (e.g., "Clean the kitchen").
  @POST('api/SubtaskTemplate')
  Future<SubtaskTemplateDetailModel> createTemplate(@Body() SubtaskTemplateCreateModel body);

  /// Updates the text or configuration of an existing subtask template.
  @PUT('api/SubtaskTemplate/{id}')
  Future<void> updateTemplate(
      @Path('id') String id,
      @Body() SubtaskTemplateUpdateModel body,
      );

  /// Deletes a specific template.
  /// Note: The backend handles cascading deletion of all associated execution instances.
  @DELETE('api/SubtaskTemplate/{id}')
  Future<void> deleteTemplate(@Path('id') String id);
}