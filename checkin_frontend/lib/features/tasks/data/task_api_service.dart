import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../task_overview/data/models/task_detail_model.dart';
import 'models/query/query_result.dart';
import 'models/task_create_model.dart';
import 'models/task_list_model.dart';

part 'task_api_service.g.dart';

@RestApi()
abstract class TaskApiService {
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;

  @POST('/api/Task')
  Future<void> createTask(@Body() TaskCreateModel body);

  @GET('/api/Task')
  // Nový návratový typ: QueryResult, kde T je TaskListModel
  // Pridáme Query parametre zodpovedajúce TQueryModel v C#
  Future<QueryResult<TaskListModel>> getTasks({
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 10,

    // (Voliteľné) Ak chceme implementovať filter z Query objektu:
    // @Query("nameContains") String? nameContains,
    // @Query("sortBy") String? sortBy,
  });

  @GET('/api/Task/{id}')
  Future<TaskDetailModel> getTask(@Path("id") String id);
}
