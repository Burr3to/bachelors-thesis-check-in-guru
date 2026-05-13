import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart';
import '../models/invitations/invitation_list_model.dart';
import '../services/invitation_api_service.dart';
import '../models/task/query/query_result.dart';

/// Provides the API service for managing task invitations.
final invitationApiServiceProvider = Provider<InvitationApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return InvitationApiService(dio);
});

/// Fetches a list of invitations associated with a specific task.
/// Automatically disposes when no longer in use to keep data fresh.
final taskInvitationsProvider = FutureProvider.autoDispose.family<QueryResult<InvitationListModel>, String>((
    ref,
    taskId,
    ) async {
  final api = ref.watch(invitationApiServiceProvider);

  // Retrieve a large batch of invitations for the detail view
  return api.getInvitations(taskId: taskId, pageSize: 100);
});