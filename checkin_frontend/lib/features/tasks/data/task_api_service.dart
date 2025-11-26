import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/task_create_model.dart';

part 'task_api_service.g.dart';

@RestApi()
abstract class TaskApiService {
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;

  @POST('/api/CheckInEventApi') // Príklad URL
  Future<void> createTask(@Body() TaskCreateModel body);
}