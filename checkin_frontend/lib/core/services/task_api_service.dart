import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/Statistics/task_summary_stats.dart';
import '../models/task/task_public_detail_model.dart';
import '../models/task/task_update_model.dart';
import '../models/subtask_instance/subtask_combined_list_model.dart';
import '../models/task/task_detail_model.dart';
import '../models/task/query/query_result.dart';
import '../models/task/task_create_model.dart';
import '../models/task/task_list_model.dart';

part 'task_api_service.g.dart';

/// API service for managing Task entities and their related data.
/// Handles CRUD operations, public access via hash, and progress statistics.
@RestApi()
abstract class TaskApiService {
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;

  /// Submits a new task to the server.
  @POST('api/Task')
  Future<TaskDetailModel> createTask(@Body() TaskCreateModel body);

  /// Updates existing task details.
  @PUT('api/Task/{id}')
  Future<TaskDetailModel> updateTask(@Path("id") String id, @Body() TaskUpdateModel body);

  /// Retrieves a paginated and filtered list of tasks for the current user.
  /// Matches the TQueryModel structure on the backend.
  @GET('api/Task')
  Future<QueryResult<TaskListModel>> getTasks({
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 10,
    @Query("sortBy") String? sortBy,
    @Query("sortDesc") bool? sortDesc,
    @Query("nameContains") String? nameContains,
    @Query("mode") int? mode,
    @Query("status") int? status,
    @Query("requiresAuth") bool? requiresAuth,
    @Query("respondentEmail") String? respondentEmail,
  });

  /// Removes specific users from the task's invitation list.
  @DELETE('api/Task/{id}/invitations')
  Future<void> removeInvitations(@Path("id") String id, @Body() List<String> emails);

  /// Fetches full management details for a single task.
  @GET('api/Task/{id}')
  Future<TaskDetailModel> getTask(@Path("id") String id);

  /// Retrieves all subtask "blueprints" (templates) defined for a specific task.
  @GET('api/Task/{taskId}/templates')
  Future<List<SubtaskCombinedListModel>> getTemplates(@Path("taskId") String taskId);

  /// Fetches aggregated progress statistics for a set of tasks to display on the dashboard.
  @POST("api/Task/summary-stats")
  Future<List<TaskSummaryStats>> getTaskSummaryStats(@Body() List<String> taskIds);

  /// Retrieves all active execution rows (instances) of subtasks for a specific task.
  @GET('api/Task/{taskId}/instances')
  Future<List<SubtaskCombinedListModel>> getInstances(@Path("taskId") String taskId);

  /// Fetches a task's public information using its unique secure hash.
  /// Used for users who are not the authors.
  @GET('api/Task/public/{hash}')
  Future<TaskPublicDetailModel> getPublicSubtasks(@Path("hash") String hash);

  /// Permanently deletes a task and all its associated subtasks and invitations.
  @DELETE('api/Task/{id}')
  Future<void> deleteTask(@Path("id") String taskId);
}