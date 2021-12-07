import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repos/features/repository_collections/domain/get_github_repositories.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_event.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_state.dart';
import 'package:stream_transform/stream_transform.dart';

class RepoBLoc extends Bloc<RepoEvent, RepoState> {
  GetGithubRepositories useCase;
  String query = "";
  static const _throttleDuration = Duration(milliseconds: 500);

  RepoBLoc({required this.useCase}) : super(const RepoState()) {
    on<RepoFetched>(_onRepoFetched,
        transformer: throttleDroppable(_throttleDuration));
    on<RepoReset>(_resetState,
        transformer: throttleDroppable(_throttleDuration));
    on<RepoLoading>(_loading,
        transformer: throttleDroppable(_throttleDuration));
  }

  EventTransformer<E> throttleDroppable<E>(Duration duration) {
    return (events, mapper) {
      return droppable<E>().call(events.throttle(duration), mapper);
    };
  }

  Future<void> _resetState(RepoReset event, Emitter<RepoState> emit) async {
    return emit(state.copyWith(status: RepoStatus.idle, repositoriesName: []));
  }

  Future<void> _loading(RepoLoading event, Emitter<RepoState> emit) async {
    return emit(state.copyWith(
        status: RepoStatus.loading,
        repositoriesName: [],
        hasReachedMax: false));
  }

  Future<void> _onRepoFetched(
      RepoFetched event, Emitter<RepoState> emit) async {
    if (state.hasReachedMax) return;

    try {
      query = event.query;
      if (event.query.isEmpty || event.query.length < 4) {
        return emit(
            state.copyWith(status: RepoStatus.idle, repositoriesName: []));
      }

      if (state.status == RepoStatus.loading) {
        emit(state.copyWith(status: RepoStatus.loading, repositoriesName: []));
        final result = await useCase.execute(
            event.query,
            state.repositoriesName.isEmpty
                ? 1
                : state.repositoriesName.length ~/ 30);

        return result.fold(
            (error) => {
                  //Call Crashlytics with this exception
                  emit(state.copyWith(status: RepoStatus.error))
                },
            (repoData) => {
                  emit(state.copyWith(
                      status: RepoStatus.success,
                      repositoriesName: repoData.repos,
                      hasReachedMax:
                          repoData.repos.length == repoData.totalCount))
                });
      }

      var page = state.repositoriesName.length ~/ 30;
      final result = await useCase.execute(
          event.query, ++page);

      return result.fold(
          (error) => {
                //Call Crashlytics with this exception
                emit(state.copyWith(status: RepoStatus.error))
              },
          (repoData) => repoData.repos.isEmpty
              ? emit(state.copyWith(hasReachedMax: true))
              : emit(state.copyWith(
                  status: RepoStatus.success,
                  repositoriesName: List.of(state.repositoriesName)
                    ..addAll(repoData.repos),
                  hasReachedMax:
                      state.repositoriesName.length == repoData.totalCount)));
    } catch (_) {
      if (state.repositoriesName.isEmpty) {
        emit(state.copyWith(status: RepoStatus.error));
      } else {
        emit(state.copyWith(
            status: RepoStatus.success,
            repositoriesName: state.repositoriesName));
      }
    }
  }
}
