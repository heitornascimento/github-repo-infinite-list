import 'package:github_repos/features/repository_collections/data/model/github_response.dart';


abstract class Repository {
  Future<GithubResponse> getRepoByName(String query, int page);
}
