

import 'package:github_repos/features/repository_collections/data/model/github_repo.dart';

class GithubResponse {
  List<GithubRepo> repoList;
  int totalCount;

  GithubResponse({required this.repoList, required this.totalCount});
}