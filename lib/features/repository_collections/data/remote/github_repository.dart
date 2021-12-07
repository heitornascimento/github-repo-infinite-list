import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:github_repos/features/repository_collections/data/model/github_repo.dart';
import 'package:github_repos/features/repository_collections/data/model/github_response.dart';
import 'package:github_repos/features/repository_collections/data/remote/core/github_api.dart';

import '../../domain/repository.dart';

class GithubRepository implements Repository {
  GithubAPI api;

  GithubRepository({required this.api});

  @override
  Future<GithubResponse> getRepoByName(String query, int page) async {
    dynamic response = await api.fetchRepoByName(query, page);
    List<GithubRepo> newList = response['items']
        .map<GithubRepo>((json) => GithubRepo.fromJson(json))
        .toList();
    return GithubResponse(
        repoList: newList, totalCount: response['total_count']);
  }
}
