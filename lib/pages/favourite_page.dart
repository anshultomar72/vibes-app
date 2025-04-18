import 'package:flutter/cupertino.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text("Favourite Page"),
      ),
    );
  }
}
