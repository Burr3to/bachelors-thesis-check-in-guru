// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get home => 'Domov';

  @override
  String get tasks => 'Úlohy';

  @override
  String get login => 'Prihlásiť sa';

  @override
  String get logout => 'Odhlásiť sa';

  @override
  String get auth_askforlogin => 'Prosím, prihláste sa.';

  @override
  String get auth_googlelogin => 'Prihlásiť sa cez Google';

  @override
  String get home_hero_chip => 'Zdieľané • Kolaboratívne • Verejné • Súkromné';

  @override
  String get home_hero_title =>
      'Inteligentné checklisty.\nJednoduché odpovede.';

  @override
  String get home_hero_subtitle =>
      'Profesionálny spôsob zberu dát. Vy vytvoríte úlohu,\noni ju splnia za pár sekúnd — bez nutnosti registrácie respondentov.';

  @override
  String get home_hero_cta => 'Vytvoriť úlohu';

  @override
  String get home_sec1_title => 'Dva módy. Nekonečná kontrola.';

  @override
  String get home_sec1_desc =>
      'Zvoľte **Kolaboratívny** mód pre spoločné tímové ciele, alebo **Zdieľaný**, aby každý respondent dostal vlastnú kópiu checklistu.';

  @override
  String get home_sec2_title => 'Jednoduché zapojenie.';

  @override
  String get home_sec2_desc =>
      'Respondenti sa pridajú cez jednoduchú URL. Pre verejné úlohy **nie je potrebné prihlásenie** — stačí zadať meno. Rýchle, priame a efektívne.';

  @override
  String get home_sec3_title => 'Vaše dáta, vaše pravidlá.';

  @override
  String get home_sec3_desc =>
      'Potrebujete overené odpovede? Prepnite na **Súkromný mód** s vyžadovaním overenia identity. Chcete maximálny dosah? Použite **Verejný mód** pre prístup bez bariér.';

  @override
  String get home_feature_ready => 'Pripravené za sekundy';

  @override
  String get home_footer_subtitle => 'Efektívny spôsob správy úloh.';

  @override
  String get home_footer_copyright => '© 2026 CheckIn • Beží na Flutter Web';

  @override
  String get task_create_err_required => 'Termín a názov sú povinné';

  @override
  String get task_create_err_generic => 'Chyba pri vytváraní úlohy';

  @override
  String get task_create_header_title => 'Vytvoriť novú úlohu';

  @override
  String get task_create_header_subtitle =>
      'Budujte kolaboratívne procesy s presnosťou';

  @override
  String get task_create_btn_invite => 'Pozvať ľudí';

  @override
  String get task_create_btn_subtasks => 'Pridať podúlohy';

  @override
  String get task_create_optional => 'Voliteľné';

  @override
  String get task_create_btn_create => 'Vytvoriť úlohu';

  @override
  String get task_create_basic_title_label => 'Názov *';

  @override
  String get task_create_basic_title_hint => 'Zadajte názov úlohy';

  @override
  String get task_create_basic_desc_placeholder => 'Zadajte popis úlohy';

  @override
  String get task_create_subtasks_title => 'Podúlohy';

  @override
  String get task_create_subtasks_remove => 'Odobrať sekciu';

  @override
  String get task_create_subtasks_hint => 'Zadajte názov podúlohy...';

  @override
  String get task_create_subtasks_desc_hint => 'Pridať popis...';

  @override
  String get task_create_invite_title => 'Pozvať členov tímu';

  @override
  String get task_create_invite_hint =>
      'Zadajte alebo vložte e-maily v ľubovoľnom formáte';

  @override
  String get task_create_invite_parse => 'Spracovať';

  @override
  String get task_create_invite_remove_all => 'Odobrať všetko';

  @override
  String get task_create_invite_send_label => 'Odoslať pozvánky:';

  @override
  String get task_create_invite_immediately => 'Ihneď';

  @override
  String get task_create_invite_later => 'Neskôr (manuálne)';

  @override
  String get task_create_settings_deadline => 'Termín';

  @override
  String get task_create_settings_set_date => 'Nastaviť dátum';

  @override
  String get task_create_settings_day => '1 deň';

  @override
  String get task_create_settings_week => '1 týždeň';

  @override
  String get task_create_settings_month => '1 mesiac';

  @override
  String get task_create_mode_collab => 'Kolaboratívny';

  @override
  String get task_create_mode_indep => 'Nezávislý';

  @override
  String get task_create_mode_collab_tip =>
      'Jeden zdieľaný zoznam pre všetkých';

  @override
  String get task_create_mode_indep_tip => 'Individuálna kópia pre každého';

  @override
  String get task_create_auth_verified => 'Overené';

  @override
  String get task_create_auth_public => 'Verejné';

  @override
  String get task_create_auth_verified_tip => 'Iba prihlásení cez Google';

  @override
  String get task_create_auth_public_tip => 'Ktokoľvek s odkazom';

  @override
  String tasks_error(String error) {
    return 'Chyba: $error';
  }

  @override
  String get tasks_empty => 'Žiadne úlohy sa nenašli';

  @override
  String get tasks_card_no_desc => 'Bez popisu';

  @override
  String get tasks_card_created => 'Vytvorené';

  @override
  String get tasks_filter_title => 'Filtre a zoradenie';

  @override
  String get tasks_filter_sort_by => 'Zoradiť podľa';

  @override
  String get tasks_filter_created_at => 'Dátumu vytvorenia';

  @override
  String get tasks_filter_deadline => 'Termínu';

  @override
  String get tasks_filter_title_field => 'Názvu';

  @override
  String get tasks_filter_descending => 'Zostupne';

  @override
  String get tasks_filter_mode => 'Mód spolupráce';

  @override
  String get tasks_filter_visibility => 'Viditeľnosť';

  @override
  String get tasks_filter_status => 'Stav úloh';

  @override
  String get tasks_filter_active_only => 'Iba aktívne';

  @override
  String get tasks_filter_active_subtitle => 'Úlohy pred termínom';

  @override
  String get tasks_filter_overdue_only => 'Po termíne';

  @override
  String get tasks_filter_overdue_subtitle => 'Úlohy po termíne';

  @override
  String get tasks_filter_reset => 'Resetovať všetky filtre';

  @override
  String get tasks_header_search_hint => 'Hľadať úlohy podľa názvu...';

  @override
  String get tasks_pagination_page => 'Strana';

  @override
  String get common_cancel => 'Zrušiť';

  @override
  String get common_save => 'Uložiť';

  @override
  String get common_add => 'Pridať';

  @override
  String get common_edit => 'Upraviť';

  @override
  String get common_delete => 'Vymazať';

  @override
  String get common_retry => 'Skúsiť znova';

  @override
  String get common_unknown => 'Neznáme';

  @override
  String get overview_msg_emails_sent =>
      'Všetky e-maily boli úspešne odoslané.';

  @override
  String get overview_msg_emails_failed =>
      'Chyba pri odosielaní e-mailov. Skontrolujte nastavenia SMTP.';

  @override
  String get overview_msg_task_updated => 'Úloha bola úspešne upravená';

  @override
  String overview_err_update(String error) {
    return 'Úprava zlyhala: $error';
  }

  @override
  String get overview_msg_task_deleted => 'Úloha bola vymazaná';

  @override
  String get overview_err_load_structure =>
      'Nepodarilo sa načítať štruktúru úlohy';

  @override
  String get overview_err_load_progress => 'Nepodarilo sa načítať progres';

  @override
  String get overview_checklist_title => 'Checklist úlohy';

  @override
  String get overview_progress_title => 'Progres podúloh';

  @override
  String get overview_err_load_task => 'Nepodarilo sa načítať úlohu';

  @override
  String get overview_notes_empty => 'Bez popisu. Kliknite pre pridanie...';

  @override
  String get overview_notes_hint => 'Zadajte popis úlohy';

  @override
  String get overview_btn_save_changes => 'Uložiť zmeny';

  @override
  String get overview_results_signatures => 'Dokončené podpisy';

  @override
  String get overview_results_empty => 'Zatiaľ žiadne podpisy.';

  @override
  String get overview_results_confirmed => 'Potvrdené';

  @override
  String get overview_msg_subtask_added => 'Podúloha úspešne pridaná';

  @override
  String get overview_msg_subtask_deleted => 'Podúloha vymazaná';

  @override
  String get overview_msg_changes_saved => 'Zmeny uložené';

  @override
  String get overview_msg_sync => 'Všetky zmeny zosynchronizované';

  @override
  String get overview_progress_empty => 'Zatiaľ žiadny zaznamenaný progres.';

  @override
  String get overview_progress_not_started => 'Neznáme / Nezačaté';

  @override
  String overview_progress_completed_count(int completed, int total) {
    return '$completed/$total Dokončené';
  }

  @override
  String get overview_btn_confirm => 'Potvrdiť';

  @override
  String get overview_btn_copy_link => 'Kopírovať odkaz';

  @override
  String get overview_msg_copied => 'Skopírované do schránky';

  @override
  String get overview_info_created => 'Vytvorené';

  @override
  String get overview_info_modified => 'Posledná zmena';

  @override
  String get overview_info_identity => 'Overenie identity';

  @override
  String get overview_info_required => 'Vyžadované';

  @override
  String get overview_info_not_required => 'Nevyžadované';

  @override
  String overview_invite_title(int count) {
    return 'Pozvaní ($count)';
  }

  @override
  String get overview_invite_remove => 'Odobrať';

  @override
  String overview_invite_delete_count(int count) {
    return 'Vymazať ($count)';
  }

  @override
  String get overview_invite_sending_msg => 'Odosielam pozvánky na pozadí...';

  @override
  String get overview_invite_err_sending =>
      'Nepodarilo sa spustiť odosielanie.';

  @override
  String overview_invite_removed_msg(int count) {
    return 'Odobraných $count ľudí.';
  }

  @override
  String get overview_invite_no_new_emails => 'Nenašli sa žiadne nové e-maily.';

  @override
  String overview_invite_added_msg(int count) {
    return 'Pridaných $count nových ľudí.';
  }

  @override
  String get overview_invite_btn_send_new => 'Poslať novým';

  @override
  String get overview_invite_btn_remind => 'Pripomenúť nedokončeným';

  @override
  String get overview_invite_cooldown => 'Počkajte 30s...';

  @override
  String get overview_invite_input_hint => 'Zadajte e-maily...';

  @override
  String get respond_tasks_label => 'Úlohy:';

  @override
  String get respond_sign_hint => 'Prosím, podpíšte sa nižšie pre potvrdenie:';

  @override
  String get respond_btn_sign_send => 'Podpísať a odoslať';

  @override
  String respond_btn_submit(int count) {
    return 'Odoslať ($count)';
  }

  @override
  String get respond_all_completed => 'Všetky úlohy sú splnené!';

  @override
  String get respond_auth_required_title => 'Vyžaduje sa overenie';

  @override
  String get respond_auth_required_subtitle => 'Táto úloha je súkromná.';

  @override
  String get respond_sig_label => 'Vaše meno / podpis';

  @override
  String respond_sig_signed_as(String name) {
    return 'Podpísaný ako: $name';
  }

  @override
  String respond_completed_by(String name) {
    return 'Splnil: $name';
  }

  @override
  String get error_access_denied => 'Prístup zamietnutý';

  @override
  String get error_not_on_list => 'Nie ste na zozname';

  @override
  String get error_not_on_list_msg =>
      'Bohužiaľ, tento zoznam úloh je prístupný len pre pozvaných hostí.';

  @override
  String get error_private_task => 'Súkromná úloha';

  @override
  String get error_private_task_msg =>
      'Pre overenie vašej pozvánky sa musíte prihlásiť.';

  @override
  String get error_not_found => 'Úloha neexistuje';

  @override
  String get error_not_found_msg =>
      'Odkaz je neplatný alebo úloha bola zmazaná.';

  @override
  String get common_back_to_home => 'Späť na úvod';

  @override
  String get nav_introduction => 'Úvod';

  @override
  String get nav_my_tasks => 'Moje úlohy';

  @override
  String get dialog_invalid_emails_title => 'Nájdené neplatné domény';

  @override
  String get dialog_invalid_emails_msg =>
      'Nasledujúce e-maily boli ignorované, pretože ich domény neexistujú:';

  @override
  String get dialog_invalid_emails_footer => 'Skontrolujte si prosím preklepy.';

  @override
  String get dialog_invalid_emails_btn => 'OK, opravím to';

  @override
  String get date_expired_today => 'Expirovalo dnes';

  @override
  String get date_expired_yesterday => 'Expirovalo včera';

  @override
  String date_overdue_days_ago(int days) {
    return 'Po termíne $days dní';
  }

  @override
  String date_today_at(String time) {
    return 'Dnes o $time';
  }

  @override
  String date_tomorrow_at(String time) {
    return 'Zajtra o $time';
  }

  @override
  String date_in_days(int days) {
    return 'O $days dní';
  }

  @override
  String get date_just_now => 'Práve teraz';

  @override
  String date_mins_ago(Object count) {
    return 'pred ${count}m';
  }

  @override
  String date_hours_ago(Object count) {
    return 'pred ${count}h';
  }

  @override
  String date_days_ago(Object count) {
    return 'pred ${count}d';
  }
}
