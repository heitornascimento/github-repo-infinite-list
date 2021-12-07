import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_repos/features/repository_collections/presentation/repo_view.dart';

class GithubApp extends StatelessWidget {
  const GithubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Github Repositories',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RepoView(),
        // 'repo_details': (context) => const TBD
      },
    );
  }
}
