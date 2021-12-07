import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repos/features/repository_collections/domain/get_github_repositories.dart';
import 'package:github_repos/features/repository_collections/domain/model/github_repo.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_bloc.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_event.dart';
import 'package:github_repos/features/repository_collections/presentation/bloc/repo_state.dart';
import 'package:provider/provider.dart';

class RepoView extends StatefulWidget {
  const RepoView({Key? key}) : super(key: key);

  @override
  State<RepoView> createState() => _RepoViewState();
}

class _RepoViewState extends State<RepoView> {
  final TextEditingController _querySearchController = TextEditingController();
  late final RepoBLoc repoBLoc;

  //TODO
  Icon searchIcon = const Icon(Icons.search);
  Widget searchView = const Text('Repository List');

  void _onSearch() {
    if (searchIcon.icon == Icons.search) {
      setState(() {
        searchView = _SearchTextField(
          controller: _querySearchController,
        );
        searchIcon = const Icon(Icons.close);
      });
    } else {
      setState(() {
        _querySearchController.text = "";
        repoBLoc.add(RepoReset());
        searchIcon = const Icon(Icons.search);
        searchView = const Text('Repository List');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _querySearchController.addListener(_onQuerySearch);
    repoBLoc = context.read<
        RepoBLoc>(); //RepoBLoc(useCase: context.read<GetGithubRepositories>());
  }

  void _onQuerySearch() {
    if (_querySearchController.text.length >= 4) {
      repoBLoc.add(RepoLoading());
      repoBLoc.add(RepoFetched(query: _querySearchController.text));
    } else {
      repoBLoc.add(RepoReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchView,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              key: const Key("search_icon"),
              onPressed: _onSearch,
              icon: searchIcon)
        ],
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => repoBLoc,
        child: _RepoListView(
          querySearch: _querySearchController.text,
        ),
      ),
    );
  }
}

class _SearchTextField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.search,
        color: Colors.white,
        size: 28,
      ),
      title: TextField(
        key: const Key("input_search_query"),
        autofocus: true,
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Insert repository name...',
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RepoListView extends StatefulWidget {
  final String querySearch;

  const _RepoListView({required this.querySearch});

  @override
  State<_RepoListView> createState() => _RepoListViewState();
}

class _RepoListViewState extends State<_RepoListView> {
  final _scrollController = ScrollController();
  String query = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RepoBLoc>().add(RepoFetched(query: query));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // _scrollToBottom();
    return currentScroll >= (maxScroll * 0.9);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());

    return BlocBuilder<RepoBLoc, RepoState>(
      // buildWhen: ,
      builder: (context, state) {
        switch (state.status) {
          case RepoStatus.error:
            return const Center(child: Text('failed to fetch posts'));
          case RepoStatus.idle:
            return const Center(child: Text('Please, type at least 4 letters'));
          case RepoStatus.success:
            if (state.repositoriesName.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            query = context.read<RepoBLoc>().query;

            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.repositoriesName.length
                    ? const BottomLoader(
                        key: Key("bottom_view"),
                      )
                    : RepoListItem(repo: state.repositoriesName[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.repositoriesName.length
                  : state.repositoriesName.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

class RepoListItem extends StatelessWidget {
  const RepoListItem({Key? key, required this.repo}) : super(key: key);
  final GithubRepo repo;


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: InkWell(
        onTap: () => {},
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.network(repo.avatarUrl),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(repo.userName),
                    const SizedBox(
                      width: 8,
                    ),
                    const Icon(
                      Icons.star,
                      size: 16.0,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(repo.startCount.toString())
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(repo.name, style: textTheme.caption),
                const SizedBox(
                  height: 8,
                ),
                Text(repo.fullName)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
