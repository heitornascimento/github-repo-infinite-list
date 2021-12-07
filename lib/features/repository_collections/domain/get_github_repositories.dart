import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:github_repos/features/repository_collections/domain/exception/illegal_search_argument.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart'
    as domain;
import 'package:github_repos/features/repository_collections/domain/repository.dart';
import 'package:github_repos/features/repository_collections/domain/use_case.dart';

class GetGithubRepositories extends UseCase<domain.GithubRepos, String, int> {
  final Repository githubRepository;

  const GetGithubRepositories(this.githubRepository);

  @override
  Future<Either<Exception, domain.GithubRepos>> execute(
      [String? param1, int? param2]) async {
    try {
      if (param1 == null || param1.isEmpty) {
        return Left(IllegalArgumentSearch(
            'Illegal argument, please provide a search query'));
      }

      if (param2 == null || param2 < 0) {
        return Left(IllegalArgumentSearch(
            'Illegal argument, please provide a paging argument'));
      }

      final response = await githubRepository.getRepoByName(param1, param2);

      final result = domain.GithubRepos(
          repos: response.repoList
              .map((r) => domain.GithubRepo(
                  name: r.name,
                  fullName: r.fullName,
                  isPrivate: r.isPrivate,
                  startCount: r.startCount,
                  watcherCount: r.watcherCount,
                  userName: r.userName,
                  avatarUrl: r.avatarUrl))
              .toList(),
          totalCount: response.totalCount);

      return Right(result);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  List<domain.GithubRepo> sortAlpha(List<domain.GithubRepo> list) {
    list.sort((r1, r2) => r1.name.compareTo(r2.name));
    return list;
  }
}
