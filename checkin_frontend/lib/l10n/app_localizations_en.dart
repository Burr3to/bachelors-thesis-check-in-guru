// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get tasks => 'Tasks';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get auth_askforlogin => 'Please log in.';

  @override
  String get auth_googlelogin => 'Login with Google';

  @override
  String get home_hero_chip => 'Independent • Collaborative • Public • Private';

  @override
  String get home_hero_title => 'Smart Checklists.\nFrictionless Responses.';

  @override
  String get home_hero_subtitle =>
      'The professional way to collect data. You build the task,\nthey complete it in seconds—no registration required for respondents.';

  @override
  String get home_hero_cta => 'Create Your Task';

  @override
  String get home_sec1_title => 'Two Modes. Infinite Control.';

  @override
  String get home_sec1_desc =>
      'Choose **Collaborative** for shared team goals where everyone works together, or **Independent** to give every respondent their own private copy of the checklist.';

  @override
  String get home_sec2_title => 'Participation Made Simple.';

  @override
  String get home_sec2_desc =>
      'Respondents join via a simple URL. For public tasks, **no login is required**—they just type their name and start. Fast, direct, and effective.';

  @override
  String get home_sec3_title => 'Your Data, Your Rules.';

  @override
  String get home_sec3_desc =>
      'Need verified responses? Switch to **Private Mode** to require authentication. Want maximum reach? Use **Public Mode** for instant access without barriers.';

  @override
  String get home_feature_ready => 'Ready in seconds';

  @override
  String get home_footer_subtitle => 'The efficient way to manage Tasks.';

  @override
  String get home_footer_copyright => '© 2026 CheckIn • Powered by Flutter Web';

  @override
  String get task_create_err_required => 'Deadline and Title are required';

  @override
  String get task_create_err_generic => 'Error creating task';

  @override
  String get task_create_header_title => 'Create New Task';

  @override
  String get task_create_header_subtitle =>
      'Build collaborative workflows with precision';

  @override
  String get task_create_btn_invite => 'Invite People';

  @override
  String get task_create_btn_subtasks => 'Add Subtasks';

  @override
  String get task_create_optional => 'Optional';

  @override
  String get task_create_btn_create => 'Create Task';

  @override
  String get task_create_basic_title_label => 'Title *';

  @override
  String get task_create_basic_title_hint => 'Enter Task Title';

  @override
  String get task_create_basic_desc_placeholder => 'Enter task description';

  @override
  String get task_create_subtasks_title => 'Subtasks';

  @override
  String get task_create_subtasks_remove => 'Remove section';

  @override
  String get task_create_subtasks_hint => 'Add subtask title...';

  @override
  String get task_create_subtasks_desc_hint => 'Add description...';

  @override
  String get task_create_invite_title => 'Invite Team Members';

  @override
  String get task_create_invite_hint => 'Enter or paste emails in any format';

  @override
  String get task_create_invite_parse => 'Parse';

  @override
  String get task_create_invite_remove_all => 'Remove All';

  @override
  String get task_create_invite_send_label => 'Send invites:';

  @override
  String get task_create_invite_immediately => 'Immediately';

  @override
  String get task_create_invite_later => 'Later (manually)';

  @override
  String get task_create_settings_deadline => 'Deadline';

  @override
  String get task_create_settings_set_date => 'Set Date';

  @override
  String get task_create_settings_day => '1 Day';

  @override
  String get task_create_settings_week => '1 Week';

  @override
  String get task_create_settings_month => '1 Month';

  @override
  String get task_create_mode_collab => 'Collaborative';

  @override
  String get task_create_mode_indep => 'Independent';

  @override
  String get task_create_mode_collab_tip => 'One shared list for all';

  @override
  String get task_create_mode_indep_tip => 'Individual copies for each';

  @override
  String get task_create_auth_verified => 'Verified';

  @override
  String get task_create_auth_public => 'Public';

  @override
  String get task_create_auth_verified_tip => 'Only Google-signed users';

  @override
  String get task_create_auth_public_tip => 'Anyone with a link';

  @override
  String tasks_error(String error) {
    return 'Error: $error';
  }

  @override
  String get tasks_empty => 'No tasks found';

  @override
  String get tasks_card_no_desc => 'No description provided';

  @override
  String get tasks_card_created => 'Created';

  @override
  String get tasks_filter_title => 'Filters & Sorting';

  @override
  String get tasks_filter_sort_by => 'Sort By';

  @override
  String get tasks_filter_created_at => 'Creation Date';

  @override
  String get tasks_filter_deadline => 'Deadline';

  @override
  String get tasks_filter_title_field => 'Title';

  @override
  String get tasks_filter_descending => 'Descending Order';

  @override
  String get tasks_filter_mode => 'Cooperation Mode';

  @override
  String get tasks_filter_visibility => 'Visibility';

  @override
  String get tasks_filter_status => 'Task Status';

  @override
  String get tasks_filter_active_only => 'Active only';

  @override
  String get tasks_filter_active_subtitle => 'Tasks before deadline';

  @override
  String get tasks_filter_overdue_only => 'Only Overdue';

  @override
  String get tasks_filter_overdue_subtitle => 'Tasks after deadline';

  @override
  String get tasks_filter_reset => 'Reset All Filters';

  @override
  String get tasks_header_search_hint => 'Search tasks by name...';

  @override
  String get tasks_pagination_page => 'Page';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_add => 'Add';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_unknown => 'Unknown';

  @override
  String get overview_msg_emails_sent => 'All emails were successfully sent.';

  @override
  String get overview_msg_emails_failed =>
      'Error sending emails. Check SMTP settings.';

  @override
  String get overview_msg_task_updated => 'Task updated successfully';

  @override
  String overview_err_update(String error) {
    return 'Failed to update: $error';
  }

  @override
  String get overview_msg_task_deleted => 'Task was deleted';

  @override
  String get overview_err_load_structure => 'Failed to load task structure';

  @override
  String get overview_err_load_progress => 'Failed to load progress';

  @override
  String get overview_checklist_title => 'Task Checklist';

  @override
  String get overview_progress_title => 'Subtasks Progress';

  @override
  String get overview_err_load_task => 'Failed to load task';

  @override
  String get overview_notes_empty => 'No description. Click to add...';

  @override
  String get overview_notes_hint => 'Enter task description';

  @override
  String get overview_btn_save_changes => 'Save Changes';

  @override
  String get overview_results_signatures => 'Completed Signatures';

  @override
  String get overview_results_empty => 'No signatures yet.';

  @override
  String get overview_results_confirmed => 'Confirmed';

  @override
  String get overview_msg_subtask_added => 'Subtask added successfully';

  @override
  String get overview_msg_subtask_deleted => 'Subtask deleted';

  @override
  String get overview_msg_changes_saved => 'Changes saved';

  @override
  String get overview_msg_sync => 'All changes synchronized';

  @override
  String get overview_progress_empty => 'No progress recorded yet.';

  @override
  String get overview_progress_not_started => 'Unknown / Not started';

  @override
  String overview_progress_completed_count(int completed, int total) {
    return '$completed/$total Completed';
  }

  @override
  String get overview_btn_confirm => 'Confirm';

  @override
  String get overview_btn_copy_link => 'Copy link';

  @override
  String get overview_msg_copied => 'Copied to clipboard';

  @override
  String get overview_info_created => 'Created On';

  @override
  String get overview_info_modified => 'Last Modified';

  @override
  String get overview_info_identity => 'Identity Verification';

  @override
  String get overview_info_required => 'Required';

  @override
  String get overview_info_not_required => 'Not Required';

  @override
  String overview_invite_title(int count) {
    return 'Invited ($count)';
  }

  @override
  String get overview_invite_remove => 'Remove';

  @override
  String overview_invite_delete_count(int count) {
    return 'Delete ($count)';
  }

  @override
  String get overview_invite_sending_msg =>
      'Sending invitations in background...';

  @override
  String get overview_invite_err_sending => 'Failed to start sending.';

  @override
  String overview_invite_removed_msg(int count) {
    return 'Removed $count people.';
  }

  @override
  String get overview_invite_no_new_emails => 'No new emails found.';

  @override
  String overview_invite_added_msg(int count) {
    return 'Added $count new people.';
  }

  @override
  String get overview_invite_btn_send_new => 'Send to New';

  @override
  String get overview_invite_btn_remind => 'Remind Unfinished';

  @override
  String get overview_invite_cooldown => 'Wait 30s...';

  @override
  String get overview_invite_input_hint => 'Enter emails...';

  @override
  String get respond_tasks_label => 'Tasks:';

  @override
  String get respond_sign_hint => 'Please sign below to confirm completion:';

  @override
  String get respond_btn_sign_send => 'Sign & Send';

  @override
  String respond_btn_submit(int count) {
    return 'Submit ($count)';
  }

  @override
  String get respond_all_completed => 'All Tasks are Completed!';

  @override
  String get respond_auth_required_title => 'Authentication Required';

  @override
  String get respond_auth_required_subtitle => 'This task is private.';

  @override
  String get respond_sig_label => 'Your name / signature';

  @override
  String respond_sig_signed_as(String name) {
    return 'Signed as: $name';
  }

  @override
  String respond_completed_by(String name) {
    return 'Completed by: $name';
  }

  @override
  String get error_access_denied => 'Access Denied';

  @override
  String get error_not_on_list => 'Not on the list';

  @override
  String get error_not_on_list_msg =>
      'Unfortunately, this task list is only accessible to invited guests.';

  @override
  String get error_private_task => 'Private Task';

  @override
  String get error_private_task_msg =>
      'You must log in to verify your invitation.';

  @override
  String get error_not_found => 'Task does not exist';

  @override
  String get error_not_found_msg =>
      'The link is invalid or the task has been deleted.';

  @override
  String get common_back_to_home => 'Back to Home';

  @override
  String get nav_introduction => 'Introduction';

  @override
  String get nav_my_tasks => 'Tasks';

  @override
  String get dialog_invalid_emails_title => 'Invalid Domains Found';

  @override
  String get dialog_invalid_emails_msg =>
      'The following emails were ignored because their domains do not exist:';

  @override
  String get dialog_invalid_emails_footer => 'Please check for typos.';

  @override
  String get dialog_invalid_emails_btn => 'OK, I\'ll fix them';

  @override
  String get date_expired_today => 'Expired today';

  @override
  String get date_expired_yesterday => 'Expired yesterday';

  @override
  String date_overdue_days_ago(int days) {
    return 'Overdue $days days ago';
  }

  @override
  String date_today_at(String time) {
    return 'Today at $time';
  }

  @override
  String date_tomorrow_at(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String date_in_days(int days) {
    return 'In $days days';
  }

  @override
  String get date_just_now => 'Just now';

  @override
  String date_mins_ago(Object count) {
    return '${count}m ago';
  }

  @override
  String date_hours_ago(Object count) {
    return '${count}h ago';
  }

  @override
  String date_days_ago(Object count) {
    return '${count}d ago';
  }
}
