import 'package:elasticengine/modules.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;


class ElasticSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () async {
          query = '';
          await searchElasticServer(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: searchElasticServer(query),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return Center(child: Text("Still searching"));

        return  _displaySuperheroes(snapshot.data) ;
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder(
      future: searchElasticServer(query),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return Text("Still searching");

        return _displaySuperheroes(snapshot.data) ;
      },
    );
  }

  Widget _displaySuperheroes( List<SuperHero> superHeroList) {

    return ListView.builder(
      itemCount: superHeroList.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return DisplaySearchResult(name: superHeroList[index].name, appearanceDate: superHeroList[index].appearanceDate, powers: superHeroList[index].powers,);
      }
    );
  }

  Future searchElasticServer(searchQuery) async {
    final transport = ConsoleHttpTransport(Uri.parse('http://10.0.0.16:9200/'));
    final client = elastic.Client(transport);
    List<SuperHero> superHeroList = List<SuperHero> ();

    final searchResult = await client.search(
        'superhero', '_doc', elastic.Query.term('name', ['$searchQuery']),
        source: true);

    print("----------- Found ${searchResult.totalCount} $searchQuery ----------");
    for(final iter in searchResult.hits){
      Map<dynamic, dynamic> currDoc = iter.doc;
      print(currDoc);
      superHeroList.add(SuperHero(name: currDoc['name'].toString(), appearanceDate: currDoc['appearance-date'].toString(), powers: currDoc['powers'].toString(),));
    }

    await transport.close();

    if(searchResult.totalCount <= 0 )
      return null;
    else
      return superHeroList;
  }
}

class DisplaySearchResult extends StatelessWidget {
  final String name;
  final String appearanceDate;
  final powers;

  DisplaySearchResult({Key key, this.name, this.appearanceDate, this.powers}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text( name ?? "", style: TextStyle(color: Colors.black, fontSize: 20 ),),
        Text(appearanceDate ?? "", style: TextStyle(color: Colors.black, fontSize: 20 ), ),
        Text(powers.toString() ?? "", style: TextStyle(color: Colors.black, fontSize: 20 ),),
        Divider(color: Colors.black,),
        SizedBox(height: 20)
      ]
    );
  }
}
