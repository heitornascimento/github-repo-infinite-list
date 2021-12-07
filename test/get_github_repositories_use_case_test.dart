import 'package:flutter_test/flutter_test.dart';
import 'package:github_repos/features/repository_collections/data/model/github_repo.dart';
import 'package:github_repos/features/repository_collections/data/model/github_response.dart';
import 'package:github_repos/features/repository_collections/data/remote/github_repository.dart';
import 'package:github_repos/features/repository_collections/domain/get_github_repositories.dart';
import 'package:github_repos/features/repository_collections/domain/exception/illegal_search_argument.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements GithubRepository {}

void main() {
  final mockRepo = MockRepo();
  final githubRepo = GithubRepo(
      name: "Flutter",
      fullName: "Flutter Repo",
      isPrivate: false,
      startCount: 100,
      watcherCount: 2000,
      nodeId: "123",
      htmlUrl: "https://github.com",
      id: 123,
      avatarUrl: "https://github.com",
      userName: "Heitor");

  test('Should return a valid Github Repositories with Either Right', () async {
    final githubResponse =
        GithubResponse(repoList: [githubRepo], totalCount: 1);

    when(() => mockRepo.getRepoByName(any(), any()))
        .thenAnswer((_) => Future.value(githubResponse));

    final useCase = GetGithubRepositories(mockRepo);
    final result = await useCase.execute("Flutter", 1);
    result.fold((l) => expect(l, isNull), (r) => expect(r.repos.length, 1));
  });

  test('Should throw Exception with Either Left', () async {
    final githubResponse =
        GithubResponse(repoList: [githubRepo], totalCount: 1);

    when(() => mockRepo.getRepoByName(any(), any())).thenThrow(Exception());

    final useCase = GetGithubRepositories(mockRepo);
    final result = await useCase.execute("Flutter", 1);
    result.fold((l) => expect(l, isA<Exception>()), (r) => expect(r, isNull));
  });

  test('Should throw IllegalArgumentException with Either Left', () async {
    final githubRepo = GithubRepo(
        name: "Flutter",
        fullName: "Flutter Repo",
        isPrivate: false,
        startCount: 100,
        watcherCount: 2000,
        nodeId: "123",
        htmlUrl: "https://github.com",
        id: 123,
        avatarUrl: "https://github.com",
        userName: "Heitor");

    final githubResponse =
        GithubResponse(repoList: [githubRepo], totalCount: 1);

    when(() => mockRepo.getRepoByName(any(), any()))
        .thenThrow(Future.value(githubResponse));

    final useCase = GetGithubRepositories(mockRepo);
    final result = await useCase.execute(null, 1);
    result.fold((l) => expect(l, isA<IllegalArgumentSearch>()),
        (r) => expect(r, isNull));
  });

  test('Should throw IllegalArgumentException with Either Left', () async {
    final githubResponse =
        GithubResponse(repoList: [githubRepo], totalCount: 1);
    when(() => mockRepo.getRepoByName(any(), any()))
        .thenThrow(Future.value(githubResponse));

    final useCase = GetGithubRepositories(mockRepo);
    final result = await useCase.execute("Flutter", null);
    result.fold((l) => expect(l, isA<IllegalArgumentSearch>()),
        (r) => expect(r, isNull));
  });
}
