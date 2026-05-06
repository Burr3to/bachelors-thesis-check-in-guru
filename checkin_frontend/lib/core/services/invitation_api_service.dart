import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/task/query/query_result.dart';
import '../models/invitations/invitation_create_model.dart';
import '../models/invitations/invitation_list_model.dart';

part 'invitation_api_service.g.dart';

@RestApi()
abstract class InvitationApiService {
  factory InvitationApiService(Dio dio, {String baseUrl}) = _InvitationApiService;

  // Tento endpoint sme pridali pre "Check" tlačidlo
  // Na backende očakáva [FromBody] string rawText
  @POST('api/Invitation/parse')
  Future<List<String>> parseEmails(@Body() String rawText);

  // Štandardné CRUD operácie z ApiControllerBase
  @GET('api/Invitation')
  Future<QueryResult<InvitationListModel>> getInvitations({
    @Query("taskId") String? taskId,
    @Query("pageNumber") int pageNumber = 1,
    @Query("pageSize") int pageSize = 10,
  });

  // NOVÝ: Univerzálny endpoint pre odosielanie (novým alebo vybraným)
  @POST('api/Invitation/send/{taskId}')
  Future<void> sendInvitations(
      @Path("taskId") String taskId,
      @Body() List<String>? emails
      );

  @GET('api/Invitation/validate-domain')
  Future<bool> validateDomain(@Query("domain") String domain);

  @POST('api/Invitation/remind-pending/{taskId}')
  Future<void> sendReminders(@Path("taskId") String taskId);

  @POST('api/Invitation')
  Future<void> createInvitation(@Body() InvitationCreateModel body);


  @DELETE('api/Invitation/{id}')
  Future<void> deleteInvitation(@Path("id") String id);
}