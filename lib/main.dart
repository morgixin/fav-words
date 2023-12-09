import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:favwords/favorite.dart';
import 'package:favwords/fav_helper.dart';


void main() {
  runApp(FavWords());
}

class FavWords extends StatelessWidget {
  const FavWords({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavWordsState(),
      child: MaterialApp(
        title: 'FavWords',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: Home(),
      ),
    );
  }
}

class FavWordsState extends ChangeNotifier {
  var current = WordPair.random();
  bool currentWasAdded = false;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  List<Favorite> favorites = [];
  var _db  = FavoriteHelper();

  void addFavorite() async {
    Favorite favorite = Favorite(current.toString());
    favorites.add(favorite);
    await _db.insertFavorite(favorite);
    getFavorites();

    notifyListeners();
  }

  late Database database;

  void removeFavorite(int id) async {
    await _db.deleteFavorite(id);
    favorites.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void getFavorites() async {
    List results = await _db.getFavorites();

    favorites.clear();

    for (var item in results) {
      Favorite fav = Favorite.fromMap(item);
      favorites.add(fav);
    }
    notifyListeners();
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritos'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<FavWordsState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Você não tem favoritos ainda.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Você possui '
              '${appState.favorites.length} palavras favoritadas:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.highlight_remove),
              onPressed: () {
                appState.removeFavorite(pair.id!);
                if (pair.name == appState.current.toString()) {
                  appState.currentWasAdded = false;
                }
              },),
            title: Text(pair.name.toLowerCase()),
          ),
      ],
    );
  }

}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<FavWordsState>();
    var pair = appState.current;

    IconData icon;
    if (appState.currentWasAdded) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (!appState.currentWasAdded) {
                    appState.currentWasAdded = true;
                    appState.addFavorite();
                  }
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  appState.currentWasAdded = false;
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
          ),
      ),
    );
  }
}