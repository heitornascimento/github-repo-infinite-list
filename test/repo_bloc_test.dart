import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_repos/features/repository_collections/domain/exception/illegal_search_argument.dart';
import 'package:github_repos/features/repository_collections/domain/get_github_repositories.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_bloc.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_event.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetGithubRepositories extends Mock implements GetGithubRepositories {}

void main() {

  const githubRepo = GithubRepo(
      name: "Flutter",
      fullName: "Flutter Repo",
      isPrivate: false,
      startCount: 100,
      watcherCount: 2000,
      avatarUrl: "https://google.com",
      userName: "Heitor");

  group("Should fetch Github repos", () {
    MockGetGithubRepositories useCaseMock = MockGetGithubRepositories();
    RepoBLoc repoBLoc = RepoBLoc(useCase: useCaseMock);

    final repos = GithubRepos(repos: [githubRepo], totalCount: 1);

    when(() => useCaseMock.execute("Flutter", 1))
        .thenAnswer((_) async => Right(repos));

    blocTest<RepoBLoc, RepoState>("Should emit success",
        build: () => repoBLoc,
        act: (bloc) => repoBLoc.add(RepoFetched(query: "Flutter")),
        expect: () => <RepoState>[
              const RepoState(
                  repositoriesName: [githubRepo],
                  hasReachedMax: false,
                  status: RepoStatus.success)
            ]);
  });

  group("Should valid when input is empty", () {
    MockGetGithubRepositories useCaseMock = MockGetGithubRepositories();
    RepoBLoc repoBLoc = RepoBLoc(useCase: useCaseMock);

    final repos = GithubRepos(repos: [githubRepo], totalCount: 1);

    when(() => useCaseMock.execute("", 1))
        .thenAnswer((_) async => Right(repos));

    blocTest<RepoBLoc, RepoState>("Should emit idle when query is empty",
        build: () => repoBLoc,
        act: (bloc) => repoBLoc.add(RepoFetched(query: "")),
        expect: () => <RepoState>[
              const RepoState(
                  repositoriesName: [],
                  hasReachedMax: false,
                  status: RepoStatus.idle)
            ]);
  });

  group("Should valid when input is less than 4", () {
    MockGetGithubRepositories useCaseMock = MockGetGithubRepositories();
    RepoBLoc repoBLoc = RepoBLoc(useCase: useCaseMock);

    final repos = GithubRepos(repos: [githubRepo], totalCount: 1);

    when(() => useCaseMock.execute("FL", 1))
        .thenAnswer((_) async => Right(repos));

    blocTest<RepoBLoc, RepoState>(
        "Should emit idle with amount of lower than 4",
        build: () => repoBLoc,
        act: (bloc) => repoBLoc.add(RepoFetched(query: "FL")),
        expect: () => <RepoState>[
              const RepoState(
                  repositoriesName: [],
                  hasReachedMax: false,
                  status: RepoStatus.idle)
            ]);
  });

  group("Should handle exception", () {
    MockGetGithubRepositories useCaseMock = MockGetGithubRepositories();
    RepoBLoc repoBLoc = RepoBLoc(useCase: useCaseMock);

    when(() => useCaseMock.execute("Flutter", 1))
        .thenThrow(IllegalArgumentSearch("Error"));

    blocTest<RepoBLoc, RepoState>("Should emit error when exception is thrown",
        build: () => repoBLoc,
        act: (bloc) => repoBLoc.add(RepoFetched(query: "Flutter")),
        expect: () => <RepoState>[
              const RepoState(
                  repositoriesName: [],
                  hasReachedMax: false,
                  status: RepoStatus.error)
            ]);
  });

  group("Should handle Error", () {
    MockGetGithubRepositories useCaseMock = MockGetGithubRepositories();
    RepoBLoc repoBLoc = RepoBLoc(useCase: useCaseMock);

    when(() => useCaseMock.execute("Flutter", 1))
        .thenAnswer((_) async => Left(IllegalArgumentSearch("Error")));

    blocTest<RepoBLoc, RepoState>("Should emit error when Either is Left",
        build: () => repoBLoc,
        act: (bloc) => repoBLoc.add(RepoFetched(query: "Flutter")),
        expect: () => <RepoState>[
              const RepoState(
                  repositoriesName: [],
                  hasReachedMax: false,
                  status: RepoStatus.error)
            ]);
  });
}
