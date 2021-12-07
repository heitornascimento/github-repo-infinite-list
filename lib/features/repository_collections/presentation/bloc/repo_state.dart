import 'package:equatable/equatable.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';

enum RepoStatus { loading, success, error, idle }

class RepoState extends Equatable {
  final RepoStatus status;
  final List<GithubRepo> repositoriesName;
  final bool hasReachedMax;

  const RepoState(
      {this.status = RepoStatus.idle,
      this.repositoriesName = const <GithubRepo>[],
      this.hasReachedMax = false});

  RepoState copyWith({
    RepoStatus? status,
    List<GithubRepo>? repositoriesName,
    bool? hasReachedMax,
  }) {
    return RepoState(
      status: status ?? this.status,
      repositoriesName: repositoriesName ?? this.repositoriesName,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, repositoriesName, hasReachedMax];
}
