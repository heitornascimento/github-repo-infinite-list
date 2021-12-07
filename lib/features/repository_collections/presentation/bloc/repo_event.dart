


import 'package:equatable/equatable.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';

abstract class RepoEvent extends Equatable{
  @override
  List<GithubRepo> get props => [];
}

class RepoFetched extends RepoEvent{
  final String query;

  RepoFetched({required this.query});
}

class RepoReset extends RepoEvent{
  RepoReset();
}

class RepoLoading extends RepoEvent{
  RepoLoading();
}