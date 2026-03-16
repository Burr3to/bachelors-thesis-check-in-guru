import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/Statistics/task_summary_stats.dart';
import '../models/task/task_public_detail_model.dart';
import '../models/task/task_update_model.dart';
import '../../features/task_overview/data/models/subtask_combined_list_model.dart';
import '../../features/task_overview/data/models/task_detail_model.dart';
import '../../features/task_list/data/models/query/query_result.dart';
import '../../features/task_create/data/models/task_create_model.dart';
import '../../features/task_list/data/models/task_list_model.dart';

part 'task_api_service.g.dart';

@RestApi()
abstract class TaskApiService {
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;

  @POST('api/Task')
  Future<TaskDetailModel> createTask(@Body() TaskCreateModel body);

  @PUT('api/Task/{id}')
  Future<TaskDetailModel> updateTask(@Path("id") String id, @Body() TaskUpdateModel body);


  @GET('api/Task')
  // Nový návratový typ: QueryResult, kde T je TaskListModel
  // Pridáme Query parametre zodpovedajúce TQueryModel v C#
  Future<QueryResult<TaskListModel>> getTasks({
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 10,

    // (Voliteľné) Ak chceme implementovať filter z Query objektu:
    // @Query("nameContains") String? nameContains,
    // @Query("sortBy") String? sortBy,
  });

  @GET('api/Task/{id}')
  Future<TaskDetailModel> getTask(@Path("id") String id);

  @GET('api/Task/{taskId}/templates')
  Future<List<SubtaskCombinedListModel>> getTemplates(@Path("taskId") String taskId);

  @POST("/tasks/summary-stats")
  Future<List<TaskSummaryStats>> getTaskSummaryStats(@Body() List<String> taskIds);

  @GET('api/Task/{taskId}/instances')
  Future<List<SubtaskCombinedListModel>> getInstances(@Path("taskId") String taskId);

  @GET('api/Task/public/{hash}')
  Future<TaskPublicDetailModel> getPublicSubtasks(@Path("hash") String hash);

  @DELETE('api/Task/{id}')
  Future<void> deleteTask(@Path("id") String taskId);
}
