// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_create_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskCreateNotifier)
final taskCreateProvider = TaskCreateNotifierProvider._();

final class TaskCreateNotifierProvider
    extends $NotifierProvider<TaskCreateNotifier, TaskCreateModel> {
  TaskCreateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskCreateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskCreateNotifierHash();

  @$internal
  @override
  TaskCreateNotifier create() => TaskCreateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskCreateModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskCreateModel>(value),
    );
  }
}

String _$taskCreateNotifierHash() =>
    r'a621339bab09e9ab656d99560c8057da42f7b973';

abstract class _$TaskCreateNotifier extends $Notifier<TaskCreateModel> {
  TaskCreateModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskCreateModel, TaskCreateModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskCreateModel, TaskCreateModel>,
              TaskCreateModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
