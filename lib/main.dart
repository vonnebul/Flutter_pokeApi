import "package:flutter/material.dart";
import "./constants/color_scheme.dart";
import "./pokemon.dart";
import "./request.dart";
import "package:flutter/services.dart";

void main() {
  runApp(const App());
}

abstract class PokemonApiRequest {
  late List<Map<String, dynamic>> results;
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme:
                const AppBarTheme(backgroundColor: AppColorsScheme.redPrimary),
            textTheme: const TextTheme(
                headline1: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                    color: AppColorsScheme.yellowPrimary))),
        home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Widget>> _pokemonsSheetFuture;
  late List<Widget> _pokemons;
  late int _offset;
  late int _limit;

  Future<List<Widget>> _loadPokemons([int? limit, int? offset]) async {
    List<Future<dynamic>> pokemonsSheet = [];
    Request request = Request(url: "www.pokeapi.co");
    var body = await request.getFromUri(
        uri: "api/v2/pokemon",
        params: {"limit": _limit.toString(), "offset": _offset.toString()});

    for (int i = 0; i < body["results"].length; i++) {
      pokemonsSheet.add(request.getFromUrl(body["results"][i]["url"]));
    }

    var pokemonSheetFutures = await Future.wait([...pokemonsSheet]);

    return pokemonSheetFutures
        .map((pokemonsSheet) => Pokemon(
            name: pokemonsSheet['name'],
            sprites: pokemonsSheet['sprites'],
            stats: pokemonsSheet['stats'],
            types: pokemonsSheet['types']))
        .map((pokemon) => 
            Container(
              decoration: const BoxDecoration(color: Colors.blue),
              constraints: const BoxConstraints(maxWidth: 800.0, minWidth: 700.0),
              child: 
          Image.network(
              pokemon.sprites["other"]["official-artwork"]["front_default"],
              fit: BoxFit.fill,
            ),
           

            ))
        .toList();
  }

  @override
  void initState() {
    _pokemonsSheetFuture = Future.value([]);
    _limit = 20;
    _offset = 0;
    _pokemons = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _pokemonsSheetFuture = _loadPokemons();
    return Scaffold(
        body: FutureBuilder<List<Widget>>(
          future: _pokemonsSheetFuture,
          builder: (context, data) {
            print(data.hasError);
            var scrollController = ScrollController();
            _pokemons = [..._pokemons, ...data.data ?? []];
            _pokemons.forEach(print);
            scrollController.addListener(() {
              double maxScroll = scrollController.position.maxScrollExtent;
              double currentScroll = scrollController.position.pixels;
              if (currentScroll == maxScroll) {
                setState(() {
                  _offset = _limit + _offset;
                  _pokemonsSheetFuture = _loadPokemons();
                });
              }
            });
            var gridView = GridView.extent(
              addRepaintBoundaries: false,
              maxCrossAxisExtent: 300,
              padding: const EdgeInsets.all(4),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              controller: scrollController,
              children: _pokemons,
            );
            return Container(
              child: gridView,
            );
          },
        ),
        appBar: AppBar(
          actions: [
            PopupMenuButton(
                offset: const Offset(50, 50),
                icon: const Icon(IconData(0xf623, fontFamily: 'MaterialIcons')),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        child: ListTile(
                          title: Text('item 1'),
                        ),
                      ),
                    ]),
          ],
          title: Text("Pokemon", style: Theme.of(context).textTheme.headline1),
        ));
  }
}
