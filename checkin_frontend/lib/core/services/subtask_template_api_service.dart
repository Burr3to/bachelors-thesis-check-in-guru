import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/subtask_template/subtask_template_create_model.dart';
import '../models/subtask_template/subtask_template_detail_model.dart';
import '../models/subtask_template/subtask_template_update_model.dart';

part 'subtask_template_api_service.g.dart';

@RestApi()
abstract class SubtaskTemplateApiService {
  factory SubtaskTemplateApiService(Dio dio, {String baseUrl}) = _SubtaskTemplateApiService;

  /// Vytvorenie novej šablóny podúlohy (napr. "Uprac aj kuchyňu")
  @POST('api/SubtaskTemplate')
  Future<SubtaskTemplateDetailModel> createTemplate(@Body() SubtaskTemplateCreateModel body);

  /// Aktualizácia textu šablóny
  @PUT('api/SubtaskTemplate/{id}')
  Future<void> updateTemplate( // <--- ZMEŇ NA void
      @Path('id') String id,
      @Body() SubtaskTemplateUpdateModel body,
      );

  /// Odstránenie šablóny (aj so všetkými inštanciami vďaka Cascade Delete na BE)
  @DELETE('api/SubtaskTemplate/{id}')
  Future<void> deleteTemplate(@Path('id') String id);
}