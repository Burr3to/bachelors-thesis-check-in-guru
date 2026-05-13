import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/task/query/query_result.dart';
import '../models/invitations/invitation_create_model.dart';
import '../models/invitations/invitation_list_model.dart';

part 'invitation_api_service.g.dart';

/// API service for managing task invitations and email parsing.
@RestApi()
abstract class InvitationApiService {
  factory InvitationApiService(Dio dio, {String baseUrl}) = _InvitationApiService;

  /// Parses a raw string of text on the backend to extract valid email addresses.
  @POST('api/Invitation/parse')
  Future<List<String>> parseEmails(@Body() String rawText);

  /// Retrieves a paginated list of invitations, optionally filtered by taskId.
  @GET('api/Invitation')
  Future<QueryResult<InvitationListModel>> getInvitations({
    @Query("taskId") String? taskId,
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 10,
  });

  /// Triggers the email delivery process for a task.
  /// If the emails list is provided, it targets those specific addresses.
  @POST('api/Invitation/send/{taskId}')
  Future<void> sendInvitations(
      @Path("taskId") String taskId,
      @Body() List<String>? emails
      );

  /// Checks if a domain (e.g., "university.edu") is valid and has proper mail records.
  @GET('api/Invitation/validate-domain')
  Future<bool> validateDomain(@Query("domain") String domain);

  /// Sends reminder emails to participants who haven't completed their subtasks yet.
  @POST('api/Invitation/remind-unfinished/{taskId}')
  Future<void> sendReminders(@Path("taskId") String taskId);

  /// Creates a single new invitation record.
  @POST('api/Invitation')
  Future<void> createInvitation(@Body() InvitationCreateModel body);

  /// Deletes an invitation by its unique identifier.
  @DELETE('api/Invitation/{id}')
  Future<void> deleteInvitation(@Path("id") String id);
}