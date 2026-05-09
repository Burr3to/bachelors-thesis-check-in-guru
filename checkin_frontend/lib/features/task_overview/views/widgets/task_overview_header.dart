import 'dart:async';
import 'package:checkin_frontend/core/shared_widgets/date_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';

// --- IMPORT PRE RESPONSIVE ---
import '../../../../core/utils/responsive.dart'; // Uprav cestu ak treba

class TaskOverviewHeader extends ConsumerStatefulWidget {
  final String taskId;
  final String taskLink;
  final DateTime createdDate;
  final DateTime deadlineDate;
  final DateTime lastModified;
  final bool requiresAuth;
  final String? allowedDomain;
  final TaskState currentState;
  final ValueChanged<TaskState> onStateChanged;

  final VoidCallback onDeadlineTap;
  final ValueChanged<bool> onAuthToggle;
  final Function(String?) onDomainChanged;
  final VoidCallback onDelete;

  const TaskOverviewHeader({
    super.key,
    required this.taskId,
    required this.taskLink,
    required this.createdDate,
    required this.deadlineDate,
    required this.lastModified,
    required this.requiresAuth,
    this.allowedDomain,
    required this.onDeadlineTap,
    required this.onAuthToggle,
    required this.onDomainChanged,
    required this.onDelete,
    required this.currentState,
    required this.onStateChanged,
  });

  @override
  ConsumerState<TaskOverviewHeader> createState() => _TaskOverviewHeaderState();
}

class _TaskOverviewHeaderState extends ConsumerState<TaskOverviewHeader> {
  bool _isCopied = false;
  Timer? _copyTimer;
  bool _isConfirmingDelete = false;
  Timer? _deleteTimer;

  // --- OPTIMISTIC UI STATES ---
  late bool _requiresAuth;
  late TaskState _currentState;
  late DateTime _deadlineDate;

  late bool _domainRestrictionActive;
  late TextEditingController _domainController;
  Timer? _debounce;
  bool? _isDomainValid;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _requiresAuth = widget.requiresAuth;
    _currentState = widget.currentState;
    _deadlineDate = widget.deadlineDate;

    _domainRestrictionActive = widget.allowedDomain != null;
    String cleanDomain = (widget.allowedDomain ?? '').replaceAll('@', '');
    _domainController = TextEditingController(text: cleanDomain);

    if (widget.allowedDomain != null) _isDomainValid = true;
  }

  @override
  void didUpdateWidget(TaskOverviewHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.requiresAuth != widget.requiresAuth) {
      _requiresAuth = widget.requiresAuth;
    }
    if (oldWidget.currentState != widget.currentState) {
      _currentState = widget.currentState;
    }
    if (oldWidget.deadlineDate != widget.deadlineDate) {
      _deadlineDate = widget.deadlineDate;
    }

    if (oldWidget.allowedDomain != widget.allowedDomain && !_isValidating) {
      String cleanDomain = (widget.allowedDomain ?? '').replaceAll('@', '');
      _domainController.text = cleanDomain;
      setState(() {
        _domainRestrictionActive = widget.allowedDomain != null;
        _isDomainValid = widget.allowedDomain != null ? true : null;
      });
    }
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    _deleteTimer?.cancel();
    _debounce?.cancel();
    _domainController.dispose();
    super.dispose();
  }

  void _validateDomain(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.isEmpty) {
      setState(() => _isDomainValid = null);
      widget.onDomainChanged(null);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isValidating = true);
      try {
        final api = ref.read(invitationApiServiceProvider);
        final isValid = await api.validateDomain(value);
        if (mounted) {
          setState(() {
            _isDomainValid = isValid;
            _isValidating = false;
          });
          if (isValid) widget.onDomainChanged(value);
        }
      } catch (e) {
        if (mounted) setState(() => _isValidating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    if (isMobile) {
      // --- MOBILE LAYOUT ---
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            // ==========================================
            // RIADOK 1: ACCESS MODE -> DOMAIN SELECT
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                  _buildAccessCell(cs),
                  if (_requiresAuth) ...[
                    const SizedBox(height: 16),
                    _buildDomainCell(cs),
                  ],
                ],
              ),
            ),

            Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),

            // ==========================================
            // RIADOK 2: DEADLINE -> ACTION BUTTONS
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      // Ľavá polovica: Deadline
                      Expanded(
                        child: _buildDeadlineCell(cs),
                      ),
                      const SizedBox(width: 12),
                      // Pravá polovica: Akčné tlačidlá (zalamovacie)
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 4,
                          runSpacing: 4,
                          children:[
                            _buildStateToggleButton(cs),
                            _buildCopyButton(cs),
                            _buildDeleteButton(cs),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMetadataFooter(cs),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // --- DESKTOP LAYOUT ---
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Expanded(child: _buildDeadlineCell(cs)),
                    _buildDivider(cs),
                    Expanded(child: _buildAccessCell(cs)),

                    if (_requiresAuth) ...[
                      _buildDivider(cs),
                      Expanded(child: _buildDomainCell(cs)),
                    ],
                  ],
                ),
              ),
            ),
            _buildDivider(cs),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          _buildCopyButton(cs),
                          const SizedBox(width: 8),
                          _buildDeleteButton(cs),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStateToggleButton(cs),
                    ],
                  ),
                  _buildMetadataFooter(cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCell(ColorScheme cs) {
    return _BaseCell(
      label: "DEADLINE",
      icon: Icons.calendar_today_outlined,
      onTap: widget.onDeadlineTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              Flexible(
                child: Text(
                  DateFormat('MMMM d').format(_deadlineDate),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: cs.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit, size: 14, color: cs.primary),
            ],
          ),
          const SizedBox(height: 2),
          DateDisplay(dateTime: _deadlineDate, icon: null, showRelative: true),
        ],
      ),
    );
  }

  Widget _buildAccessCell(ColorScheme cs) {
    return _BaseCell(
      label: "ACCESS",
      icon: _requiresAuth ? Icons.lock_outline : Icons.lock_open_outlined,
      onTap: () {
        setState(() => _requiresAuth = !_requiresAuth);
        widget.onAuthToggle(_requiresAuth);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Flexible(
            child: Text(
              _requiresAuth ? "Google sign-in only" : "Anyone with link",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: cs.primary),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.swap_horiz, size: 16, color: cs.primary.withAlpha(150)),
        ],
      ),
    );
  }

  Widget _buildDomainCell(ColorScheme cs) {
    return _BaseCell(
      label: "DOMAIN",
      icon: Icons.public,
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              // Flexible zabezpečí, že ak nie je miesto, "Restriction" sa skráti s 3 bodkami
              Flexible(
                child: Text(
                  "Restriction",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withAlpha(200),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 20,
                child: Transform.scale(
                  scale: 0.65,
                  child: Switch(
                    value: _domainRestrictionActive,
                    onChanged: (val) {
                      setState(() => _domainRestrictionActive = val);
                      if (!val) widget.onDomainChanged(null);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: "Restrict responses to a specific email domain",
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: cs.onSurfaceVariant.withAlpha(150),
                ),
              ),
            ],
          ),
          if (_domainRestrictionActive)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextField(
                controller: _domainController,
                onChanged: _validateDomain,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  prefixText: '@ ',
                  prefixStyle: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: "company.com",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  suffixIcon: _isValidating
                      ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : _isDomainValid != null
                      ? Icon(
                    _isDomainValid! ? Icons.check_circle_outline : Icons.error_outline,
                    color: _isDomainValid! ? Colors.green : cs.error,
                    size: 18,
                  )
                      : null,
                  suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(ColorScheme cs) {
    return TextButton.icon(
      onPressed: _handleCopy,
      icon: Icon(_isCopied ? Icons.check : Icons.content_copy, size: 16),
      label: Text(_isCopied ? "Copied!" : "Copy Link"),
      style: TextButton.styleFrom(
        foregroundColor: _isCopied ? Colors.green : cs.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildStateToggleButton(ColorScheme cs) {
    final isCompleted = _currentState == TaskState.completed;

    return TextButton.icon(
      onPressed: () {
        final newState = isCompleted ? TaskState.inProgress : TaskState.completed;
        setState(() => _currentState = newState);
        widget.onStateChanged(newState);
      },
      icon: Icon(
        isCompleted ? Icons.settings_backup_restore : Icons.check_circle_outline,
        size: 16,
      ),
      label: Text(isCompleted ? "Reopen Task" : "Complete Task"),
      style: TextButton.styleFrom(
        foregroundColor: isCompleted ? cs.primary : Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildDeleteButton(ColorScheme cs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        if (_isConfirmingDelete)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _isConfirmingDelete = false),
          ),
        OutlinedButton.icon(
          onPressed: _handleDeleteClick,
          icon: Icon(_isConfirmingDelete ? Icons.report_problem : Icons.delete_outline, size: 16),
          label: Text(_isConfirmingDelete ? "Confirm" : "Delete"),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error.withAlpha(100)),
            backgroundColor: _isConfirmingDelete ? cs.error.withAlpha(20) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataFooter(ColorScheme cs) {
    final created = widget.createdDate;
    final modified = widget.lastModified;
    final currentYear = DateTime.now().year;

    String createdStr;
    String modifiedStr;

    if (created.year == modified.year) {
      if (created.year == currentYear) {
        createdStr = DateFormat('MMM d').format(created);
        modifiedStr = DateFormat('MMM d').format(modified);
      } else {
        createdStr = DateFormat('MMM d').format(created);
        modifiedStr = DateFormat('MMM d, yyyy').format(modified);
      }
    } else {
      createdStr = DateFormat('MMM d, yyyy').format(created);
      modifiedStr = DateFormat('MMM d, yyyy').format(modified);
    }

    return Text(
      "Created $createdStr  •  Modified $modifiedStr",
      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withAlpha(150)),
      textAlign: TextAlign.right,
    );
  }

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.taskLink));
    setState(() => _isCopied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _handleDeleteClick() {
    if (!_isConfirmingDelete) {
      setState(() => _isConfirmingDelete = true);
      _deleteTimer?.cancel();
      _deleteTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isConfirmingDelete = false);
      });
    } else {
      widget.onDelete();
    }
  }

  Widget _buildDivider(ColorScheme cs) =>
      VerticalDivider(width: 32, color: cs.outlineVariant.withAlpha(80), thickness: 1);
}

// Interaktívna bunka
class _BaseCell extends StatefulWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  const _BaseCell({required this.label, required this.icon, required this.child, this.onTap});

  @override
  State<_BaseCell> createState() => _BaseCellState();
}

class _BaseCellState extends State<_BaseCell> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isInteractive = widget.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: isInteractive ? (val) => setState(() => _isHovering = val) : null,
        borderRadius: BorderRadius.circular(8),
        mouseCursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        hoverColor: Colors.transparent,
        splashColor: cs.primary.withAlpha(30),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovering ? cs.primary.withAlpha(15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovering ? cs.primary.withAlpha(40) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Icon(widget.icon, size: 14, color: cs.onSurfaceVariant.withAlpha(120)),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant.withAlpha(120),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}