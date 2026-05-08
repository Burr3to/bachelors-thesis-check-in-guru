import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sk'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @auth_askforlogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in.'**
  String get auth_askforlogin;

  /// No description provided for @auth_googlelogin.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get auth_googlelogin;

  /// No description provided for @home_hero_chip.
  ///
  /// In en, this message translates to:
  /// **'Independent • Collaborative • Public • Private'**
  String get home_hero_chip;

  /// No description provided for @home_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Checklists.\nFrictionless Responses.'**
  String get home_hero_title;

  /// No description provided for @home_hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The professional way to collect data. You build the task,\nthey complete it in seconds—no registration required for respondents.'**
  String get home_hero_subtitle;

  /// No description provided for @home_hero_cta.
  ///
  /// In en, this message translates to:
  /// **'Create Your Task'**
  String get home_hero_cta;

  /// No description provided for @home_sec1_title.
  ///
  /// In en, this message translates to:
  /// **'Two Modes. Infinite Control.'**
  String get home_sec1_title;

  /// No description provided for @home_sec1_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose **Collaborative** for shared team goals where everyone works together, or **Independent** to give every respondent their own private copy of the checklist.'**
  String get home_sec1_desc;

  /// No description provided for @home_sec2_title.
  ///
  /// In en, this message translates to:
  /// **'Participation Made Simple.'**
  String get home_sec2_title;

  /// No description provided for @home_sec2_desc.
  ///
  /// In en, this message translates to:
  /// **'Respondents join via a simple URL. For public tasks, **no login is required**—they just type their name and start. Fast, direct, and effective.'**
  String get home_sec2_desc;

  /// No description provided for @home_sec3_title.
  ///
  /// In en, this message translates to:
  /// **'Your Data, Your Rules.'**
  String get home_sec3_title;

  /// No description provided for @home_sec3_desc.
  ///
  /// In en, this message translates to:
  /// **'Need verified responses? Switch to **Private Mode** to require authentication. Want maximum reach? Use **Public Mode** for instant access without barriers.'**
  String get home_sec3_desc;

  /// No description provided for @home_feature_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready in seconds'**
  String get home_feature_ready;

  /// No description provided for @home_footer_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The efficient way to manage Tasks.'**
  String get home_footer_subtitle;

  /// No description provided for @home_footer_copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 CheckIn • Powered by Flutter Web'**
  String get home_footer_copyright;

  /// No description provided for @task_create_err_required.
  ///
  /// In en, this message translates to:
  /// **'Deadline and Title are required'**
  String get task_create_err_required;

  /// No description provided for @task_create_err_generic.
  ///
  /// In en, this message translates to:
  /// **'Error creating task'**
  String get task_create_err_generic;

  /// No description provided for @task_create_header_title.
  ///
  /// In en, this message translates to:
  /// **'Create New Task'**
  String get task_create_header_title;

  /// No description provided for @task_create_header_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Build collaborative workflows with precision'**
  String get task_create_header_subtitle;

  /// No description provided for @task_create_btn_invite.
  ///
  /// In en, this message translates to:
  /// **'Invite People'**
  String get task_create_btn_invite;

  /// No description provided for @task_create_btn_subtasks.
  ///
  /// In en, this message translates to:
  /// **'Add Subtasks'**
  String get task_create_btn_subtasks;

  /// No description provided for @task_create_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get task_create_optional;

  /// No description provided for @task_create_btn_create.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get task_create_btn_create;

  /// No description provided for @task_create_basic_title_label.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get task_create_basic_title_label;

  /// No description provided for @task_create_basic_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter Task Title'**
  String get task_create_basic_title_hint;

  /// No description provided for @task_create_basic_desc_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter task description'**
  String get task_create_basic_desc_placeholder;

  /// No description provided for @task_create_subtasks_title.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get task_create_subtasks_title;

  /// No description provided for @task_create_subtasks_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove section'**
  String get task_create_subtasks_remove;

  /// No description provided for @task_create_subtasks_hint.
  ///
  /// In en, this message translates to:
  /// **'Add subtask title...'**
  String get task_create_subtasks_hint;

  /// No description provided for @task_create_subtasks_desc_hint.
  ///
  /// In en, this message translates to:
  /// **'Add description...'**
  String get task_create_subtasks_desc_hint;

  /// No description provided for @task_create_invite_title.
  ///
  /// In en, this message translates to:
  /// **'Invite Team Members'**
  String get task_create_invite_title;

  /// No description provided for @task_create_invite_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste emails in any format'**
  String get task_create_invite_hint;

  /// No description provided for @task_create_invite_parse.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get task_create_invite_parse;

  /// No description provided for @task_create_invite_remove_all.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get task_create_invite_remove_all;

  /// No description provided for @task_create_invite_send_label.
  ///
  /// In en, this message translates to:
  /// **'Send invites:'**
  String get task_create_invite_send_label;

  /// No description provided for @task_create_invite_immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get task_create_invite_immediately;

  /// No description provided for @task_create_invite_later.
  ///
  /// In en, this message translates to:
  /// **'Later (manually)'**
  String get task_create_invite_later;

  /// No description provided for @task_create_settings_deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get task_create_settings_deadline;

  /// No description provided for @task_create_settings_set_date.
  ///
  /// In en, this message translates to:
  /// **'Set Date'**
  String get task_create_settings_set_date;

  /// No description provided for @task_create_settings_day.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get task_create_settings_day;

  /// No description provided for @task_create_settings_week.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get task_create_settings_week;

  /// No description provided for @task_create_settings_month.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get task_create_settings_month;

  /// No description provided for @task_create_mode_collab.
  ///
  /// In en, this message translates to:
  /// **'Collaborative'**
  String get task_create_mode_collab;

  /// No description provided for @task_create_mode_indep.
  ///
  /// In en, this message translates to:
  /// **'Independent'**
  String get task_create_mode_indep;

  /// No description provided for @task_create_mode_collab_tip.
  ///
  /// In en, this message translates to:
  /// **'One shared list for all'**
  String get task_create_mode_collab_tip;

  /// No description provided for @task_create_mode_indep_tip.
  ///
  /// In en, this message translates to:
  /// **'Individual copies for each'**
  String get task_create_mode_indep_tip;

  /// No description provided for @task_create_auth_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get task_create_auth_verified;

  /// No description provided for @task_create_auth_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get task_create_auth_public;

  /// No description provided for @task_create_auth_verified_tip.
  ///
  /// In en, this message translates to:
  /// **'Only Google-signed users'**
  String get task_create_auth_verified_tip;

  /// No description provided for @task_create_auth_public_tip.
  ///
  /// In en, this message translates to:
  /// **'Anyone with a link'**
  String get task_create_auth_public_tip;

  /// No description provided for @tasks_error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String tasks_error(String error);

  /// No description provided for @tasks_empty.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get tasks_empty;

  /// No description provided for @tasks_card_no_desc.
  ///
  /// In en, this message translates to:
  /// **'No description provided'**
  String get tasks_card_no_desc;

  /// No description provided for @tasks_card_created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get tasks_card_created;

  /// No description provided for @tasks_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filters & Sorting'**
  String get tasks_filter_title;

  /// No description provided for @tasks_filter_sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get tasks_filter_sort_by;

  /// No description provided for @tasks_filter_created_at.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get tasks_filter_created_at;

  /// No description provided for @tasks_filter_deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get tasks_filter_deadline;

  /// No description provided for @tasks_filter_title_field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tasks_filter_title_field;

  /// No description provided for @tasks_filter_descending.
  ///
  /// In en, this message translates to:
  /// **'Descending Order'**
  String get tasks_filter_descending;

  /// No description provided for @tasks_filter_mode.
  ///
  /// In en, this message translates to:
  /// **'Cooperation Mode'**
  String get tasks_filter_mode;

  /// No description provided for @tasks_filter_visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get tasks_filter_visibility;

  /// No description provided for @tasks_filter_status.
  ///
  /// In en, this message translates to:
  /// **'Task Status'**
  String get tasks_filter_status;

  /// No description provided for @tasks_filter_active_only.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get tasks_filter_active_only;

  /// No description provided for @tasks_filter_active_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks before deadline'**
  String get tasks_filter_active_subtitle;

  /// No description provided for @tasks_filter_overdue_only.
  ///
  /// In en, this message translates to:
  /// **'Only Overdue'**
  String get tasks_filter_overdue_only;

  /// No description provided for @tasks_filter_overdue_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks after deadline'**
  String get tasks_filter_overdue_subtitle;

  /// No description provided for @tasks_filter_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset All Filters'**
  String get tasks_filter_reset;

  /// No description provided for @tasks_header_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks by name...'**
  String get tasks_header_search_hint;

  /// No description provided for @tasks_pagination_page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get tasks_pagination_page;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknown;

  /// No description provided for @overview_msg_emails_sent.
  ///
  /// In en, this message translates to:
  /// **'All emails were successfully sent.'**
  String get overview_msg_emails_sent;

  /// No description provided for @overview_msg_emails_failed.
  ///
  /// In en, this message translates to:
  /// **'Error sending emails. Check SMTP settings.'**
  String get overview_msg_emails_failed;

  /// No description provided for @overview_msg_task_updated.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get overview_msg_task_updated;

  /// No description provided for @overview_err_update.
  ///
  /// In en, this message translates to:
  /// **'Failed to update: {error}'**
  String overview_err_update(String error);

  /// No description provided for @overview_msg_task_deleted.
  ///
  /// In en, this message translates to:
  /// **'Task was deleted'**
  String get overview_msg_task_deleted;

  /// No description provided for @overview_err_load_structure.
  ///
  /// In en, this message translates to:
  /// **'Failed to load task structure'**
  String get overview_err_load_structure;

  /// No description provided for @overview_err_load_progress.
  ///
  /// In en, this message translates to:
  /// **'Failed to load progress'**
  String get overview_err_load_progress;

  /// No description provided for @overview_checklist_title.
  ///
  /// In en, this message translates to:
  /// **'Task Checklist'**
  String get overview_checklist_title;

  /// No description provided for @overview_progress_title.
  ///
  /// In en, this message translates to:
  /// **'Subtasks Progress'**
  String get overview_progress_title;

  /// No description provided for @overview_err_load_task.
  ///
  /// In en, this message translates to:
  /// **'Failed to load task'**
  String get overview_err_load_task;

  /// No description provided for @overview_notes_empty.
  ///
  /// In en, this message translates to:
  /// **'No description. Click to add...'**
  String get overview_notes_empty;

  /// No description provided for @overview_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter task description'**
  String get overview_notes_hint;

  /// No description provided for @overview_btn_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get overview_btn_save_changes;

  /// No description provided for @overview_results_signatures.
  ///
  /// In en, this message translates to:
  /// **'Completed Signatures'**
  String get overview_results_signatures;

  /// No description provided for @overview_results_empty.
  ///
  /// In en, this message translates to:
  /// **'No signatures yet.'**
  String get overview_results_empty;

  /// No description provided for @overview_results_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get overview_results_confirmed;

  /// No description provided for @overview_msg_subtask_added.
  ///
  /// In en, this message translates to:
  /// **'Subtask added successfully'**
  String get overview_msg_subtask_added;

  /// No description provided for @overview_msg_subtask_deleted.
  ///
  /// In en, this message translates to:
  /// **'Subtask deleted'**
  String get overview_msg_subtask_deleted;

  /// No description provided for @overview_msg_changes_saved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get overview_msg_changes_saved;

  /// No description provided for @overview_msg_sync.
  ///
  /// In en, this message translates to:
  /// **'All changes synchronized'**
  String get overview_msg_sync;

  /// No description provided for @overview_progress_empty.
  ///
  /// In en, this message translates to:
  /// **'No progress recorded yet.'**
  String get overview_progress_empty;

  /// No description provided for @overview_progress_not_started.
  ///
  /// In en, this message translates to:
  /// **'Unknown / Not started'**
  String get overview_progress_not_started;

  /// No description provided for @overview_progress_completed_count.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Completed'**
  String overview_progress_completed_count(int completed, int total);

  /// No description provided for @overview_btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get overview_btn_confirm;

  /// No description provided for @overview_btn_copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get overview_btn_copy_link;

  /// No description provided for @overview_msg_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get overview_msg_copied;

  /// No description provided for @overview_info_created.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get overview_info_created;

  /// No description provided for @overview_info_modified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get overview_info_modified;

  /// No description provided for @overview_info_identity.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get overview_info_identity;

  /// No description provided for @overview_info_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get overview_info_required;

  /// No description provided for @overview_info_not_required.
  ///
  /// In en, this message translates to:
  /// **'Not Required'**
  String get overview_info_not_required;

  /// No description provided for @overview_invite_title.
  ///
  /// In en, this message translates to:
  /// **'Invited ({count})'**
  String overview_invite_title(int count);

  /// No description provided for @overview_invite_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get overview_invite_remove;

  /// No description provided for @overview_invite_delete_count.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String overview_invite_delete_count(int count);

  /// No description provided for @overview_invite_sending_msg.
  ///
  /// In en, this message translates to:
  /// **'Sending invitations in background...'**
  String get overview_invite_sending_msg;

  /// No description provided for @overview_invite_err_sending.
  ///
  /// In en, this message translates to:
  /// **'Failed to start sending.'**
  String get overview_invite_err_sending;

  /// No description provided for @overview_invite_removed_msg.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} people.'**
  String overview_invite_removed_msg(int count);

  /// No description provided for @overview_invite_no_new_emails.
  ///
  /// In en, this message translates to:
  /// **'No new emails found.'**
  String get overview_invite_no_new_emails;

  /// No description provided for @overview_invite_added_msg.
  ///
  /// In en, this message translates to:
  /// **'Added {count} new people.'**
  String overview_invite_added_msg(int count);

  /// No description provided for @overview_invite_btn_send_new.
  ///
  /// In en, this message translates to:
  /// **'Send to New'**
  String get overview_invite_btn_send_new;

  /// No description provided for @overview_invite_btn_remind.
  ///
  /// In en, this message translates to:
  /// **'Remind Unfinished'**
  String get overview_invite_btn_remind;

  /// No description provided for @overview_invite_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Wait 30s...'**
  String get overview_invite_cooldown;

  /// No description provided for @overview_invite_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter emails...'**
  String get overview_invite_input_hint;

  /// No description provided for @respond_tasks_label.
  ///
  /// In en, this message translates to:
  /// **'Tasks:'**
  String get respond_tasks_label;

  /// No description provided for @respond_sign_hint.
  ///
  /// In en, this message translates to:
  /// **'Please sign below to confirm completion:'**
  String get respond_sign_hint;

  /// No description provided for @respond_btn_sign_send.
  ///
  /// In en, this message translates to:
  /// **'Sign & Send'**
  String get respond_btn_sign_send;

  /// No description provided for @respond_btn_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit ({count})'**
  String respond_btn_submit(int count);

  /// No description provided for @respond_all_completed.
  ///
  /// In en, this message translates to:
  /// **'All Tasks are Completed!'**
  String get respond_all_completed;

  /// No description provided for @respond_auth_required_title.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get respond_auth_required_title;

  /// No description provided for @respond_auth_required_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This task is private.'**
  String get respond_auth_required_subtitle;

  /// No description provided for @respond_sig_label.
  ///
  /// In en, this message translates to:
  /// **'Your name / signature'**
  String get respond_sig_label;

  /// No description provided for @respond_sig_signed_as.
  ///
  /// In en, this message translates to:
  /// **'Signed as: {name}'**
  String respond_sig_signed_as(String name);

  /// No description provided for @respond_completed_by.
  ///
  /// In en, this message translates to:
  /// **'Completed by: {name}'**
  String respond_completed_by(String name);

  /// No description provided for @error_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get error_access_denied;

  /// No description provided for @error_not_on_list.
  ///
  /// In en, this message translates to:
  /// **'Not on the list'**
  String get error_not_on_list;

  /// No description provided for @error_not_on_list_msg.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, this task list is only accessible to invited guests.'**
  String get error_not_on_list_msg;

  /// No description provided for @error_private_task.
  ///
  /// In en, this message translates to:
  /// **'Private Task'**
  String get error_private_task;

  /// No description provided for @error_private_task_msg.
  ///
  /// In en, this message translates to:
  /// **'You must log in to verify your invitation.'**
  String get error_private_task_msg;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'Task does not exist'**
  String get error_not_found;

  /// No description provided for @error_not_found_msg.
  ///
  /// In en, this message translates to:
  /// **'The link is invalid or the task has been deleted.'**
  String get error_not_found_msg;

  /// No description provided for @common_back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get common_back_to_home;

  /// No description provided for @nav_introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get nav_introduction;

  /// No description provided for @nav_my_tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get nav_my_tasks;

  /// No description provided for @dialog_invalid_emails_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid Domains Found'**
  String get dialog_invalid_emails_title;

  /// No description provided for @dialog_invalid_emails_msg.
  ///
  /// In en, this message translates to:
  /// **'The following emails were ignored because their domains do not exist:'**
  String get dialog_invalid_emails_msg;

  /// No description provided for @dialog_invalid_emails_footer.
  ///
  /// In en, this message translates to:
  /// **'Please check for typos.'**
  String get dialog_invalid_emails_footer;

  /// No description provided for @dialog_invalid_emails_btn.
  ///
  /// In en, this message translates to:
  /// **'OK, I\'ll fix them'**
  String get dialog_invalid_emails_btn;

  /// No description provided for @date_expired_today.
  ///
  /// In en, this message translates to:
  /// **'Expired today'**
  String get date_expired_today;

  /// No description provided for @date_expired_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Expired yesterday'**
  String get date_expired_yesterday;

  /// No description provided for @date_overdue_days_ago.
  ///
  /// In en, this message translates to:
  /// **'Overdue {days} days ago'**
  String date_overdue_days_ago(int days);

  /// No description provided for @date_today_at.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String date_today_at(String time);

  /// No description provided for @date_tomorrow_at.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow at {time}'**
  String date_tomorrow_at(String time);

  /// No description provided for @date_in_days.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String date_in_days(int days);

  /// No description provided for @date_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get date_just_now;

  /// No description provided for @date_mins_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String date_mins_ago(Object count);

  /// No description provided for @date_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String date_hours_ago(Object count);

  /// No description provided for @date_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String date_days_ago(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
