import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_bloc.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_event.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_state.dart';
import 'package:github_repos/features/repository_collections/presentation/repo_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

class MockRepoBloc extends MockBloc<RepoEvent, RepoState> implements RepoBLoc {}

class FakeRepoEvent extends Fake implements RepoEvent {}

class FakeRepoState extends Fake implements RepoState {}

void main() {
  late MockRepoBloc repoBloc;

  setUpAll(() async {
    registerFallbackValue(FakeRepoEvent());
    registerFallbackValue(FakeRepoState());
  });

  tearDown(() async {});

  testWidgets("Should show idle view", (WidgetTester tester) async {
    const githubRepo = GithubRepo(
        name: "Flutter",
        fullName: "Flutter Repo",
        isPrivate: false,
        startCount: 100,
        watcherCount: 2000,
        avatarUrl: "https://google.com",
        userName: "Heitor");

    final repos = GithubRepos(repos: [githubRepo], totalCount: 1);

    const state = RepoState(
        repositoriesName: [], hasReachedMax: false, status: RepoStatus.idle);

    repoBloc = MockRepoBloc();
    when(() => repoBloc.state).thenAnswer((_) => state);

    await tester.pumpWidget(GithubAppTest(
      key: const Key("app_test"),
      mockRepoBloc: repoBloc,
    ));
    expect(find.text('Please, type at least 4 letters'), findsOneWidget);
  });

  testWidgets("Should search view ", (WidgetTester tester) async {
    const githubRepo = GithubRepo(
        name: "Flutter",
        fullName: "Flutter Repo",
        isPrivate: false,
        startCount: 100,
        watcherCount: 2000,
        avatarUrl: "https://google.com",
        userName: "Heitor");


    const githubRepo2 = GithubRepo(
        name: "Kotlin",
        fullName: "Kotlin Programming",
        isPrivate: false,
        startCount: 100,
        watcherCount: 2000,
        avatarUrl: "https://google.com",
        userName: "Heitor");

    const state = RepoState(
        repositoriesName: [githubRepo, githubRepo2],
        hasReachedMax: true,
        status: RepoStatus.success);

    repoBloc = MockRepoBloc();
    when(() => repoBloc.state).thenAnswer((_) => state);
    when(() => repoBloc.query).thenAnswer((_) => githubRepo.name);

    await mockNetworkImagesFor(() => tester.pumpWidget(GithubAppTest(
      key: const Key("app_test"),
      mockRepoBloc: repoBloc,
    )));

    final searchIcon = find
        .byKey(const ValueKey("search_icon"))
        .first
        .evaluate()
        .single
        .widget as IconButton;
    searchIcon.onPressed!();
    await tester.pump();

    final queryTextField = find.byKey(const ValueKey("input_search_query"));
    await tester.enterText(queryTextField, "Test");

    expect(find.text(githubRepo.name), findsOneWidget);
    expect(find.text(githubRepo.fullName), findsOneWidget);
    expect(find.text(githubRepo2.name), findsOneWidget);
    expect(find.text(githubRepo2.fullName), findsOneWidget);
  });

  testWidgets("Should search fail ", (WidgetTester tester) async {
    const state = RepoState(
        repositoriesName: [], hasReachedMax: true, status: RepoStatus.error);

    repoBloc = MockRepoBloc();
    when(() => repoBloc.state).thenAnswer((_) => state);
    when(() => repoBloc.query).thenAnswer((_) => "");


    await tester.pumpWidget(GithubAppTest(
      key: const Key("app_test"),
      mockRepoBloc: repoBloc,
    ));

    final searchIcon = find
        .byKey(const ValueKey("search_icon"))
        .first
        .evaluate()
        .single
        .widget as IconButton;
    searchIcon.onPressed!();
    await tester.pump();

    final queryTextField = find.byKey(const ValueKey("input_search_query"));
    await tester.enterText(queryTextField, "Flutter");

    expect(find.text('failed to fetch posts'), findsOneWidget);
  });
}

class GithubAppTest extends StatelessWidget {
  final MockRepoBloc mockRepoBloc;

  const GithubAppTest({required Key key, required this.mockRepoBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<RepoBLoc>.value(value: mockRepoBloc),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const RepoView(),
      ),
    );
  }
}
