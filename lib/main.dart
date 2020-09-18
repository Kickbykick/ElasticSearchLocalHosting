import 'package:elasticengine/elasticsearchdelegate.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Set up
  // final Database elasticSearchVar = ElasticSearch(
  //   host: "a5b6196df6064f3c8bd19a055d3c365c.us-central1.gcp.cloud.es.io",
  //   port: 9243,
  //   credentials: ElasticSearchPasswordCredentials(
  //       user: 'elastic', password: 'CCoBFkK5GdkdrLwoZk8K5Hxe'),
  // ).database();







  Future<void> mainSearchFunc() async {
  
    var response = await http.get('http://10.0.0.16:9200/');
    print('Response body: ${response.body}');

  }







  Future addGamesToList() async {
    final transport = ConsoleHttpTransport(Uri.parse('http://10.0.0.16:9200/'));
    final client = elastic.Client(transport);

    await client.updateDoc('games', '_doc', 'MK11',
        {'name': 'Mortal Kombat 11', 'release': 'October 8, 1992'});
    await client.updateDoc('games', '_doc', 'TK7',
        {'name': 'TEKKEN 7', 'release': 'March 18, 2015'});
    await client.updateDoc('games', '_doc', 'SF5',
        {'name': 'Street Fighter V', 'release': 'February 16, 2016'});
    await client.updateDoc('games', '_doc', 'FF21',
        {'name': 'FIFA 2021', 'release': 'October 6, 2020'});


    await transport.close();
  }

  Future addGameFromTextField(id, game, release) async {
    final transport = ConsoleHttpTransport(Uri.parse('http://10.0.0.16:9200/'));
    final client = elastic.Client(transport);

    await client.updateDoc('games', '_doc', id,
        {'name': game, 'release': release});

    await transport.close();
  }

  String id;
  String game;
  String release;
  TextEditingController _idController = TextEditingController();
  TextEditingController _gameController = TextEditingController();
  TextEditingController _releaseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),

            Text("Add more Games", style: TextStyle(fontSize:20),),

            SizedBox(height: 10),

            TextField(
              controller: _idController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter ID'
              ),
              onChanged: (str){
                setState(() {
                  id = str;
                });
              },
            ),
            TextField(
              controller: _gameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Game Name'
              ),
              onChanged: (str){
                setState(() {
                  game = str;
                });
              },
            ),
            TextField(
              controller: _releaseController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Game Release Date'
              ),
              onChanged: (str){
                setState(() {
                  release = str;
                });
              },
            ),

            SizedBox(height: 10),

            FlatButton(
              child: Text("Save Data", style: TextStyle(fontSize:20)),
              onPressed: () async {
                print(id);
                await addGameFromTextField(id, game, release);
                setState(() {
                  _idController.clear();
                  _gameController.clear();
                  _releaseController.clear();
                });
                print(id);
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await mainSearchFunc(); },
        child: Icon(Icons.search),
      ), 
    );
  }

  Future<void> _showSearch() async {
    await showSearch(
      context: context,
      delegate: ElasticSearchDelegate(),
      query: "",
    );
  }
}