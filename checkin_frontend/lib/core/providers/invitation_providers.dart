import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart';
import '../models/invitations/invitation_list_model.dart';
import '../services/invitation_api_service.dart';
import '../models/task/query/query_result.dart';

final invitationApiServiceProvider = Provider<InvitationApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return InvitationApiService(dio);
});

// Provider pre zoznam pozvánok k určitému tasku
final taskInvitationsProvider = FutureProvider.autoDispose.family<QueryResult<InvitationListModel>, String>((
    ref,
    taskId,
    ) async {
  final api = ref.watch(invitationApiServiceProvider);
  return api.getInvitations(taskId: taskId, pageSize: 100);
});