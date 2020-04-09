import 'package:flutter/foundation.dart';

class Musik {

  String titre;
  String auteur;
  String imagepath;
  String musikURL;

  Musik(String titre, String auteur, String imagepath, String musikURL) {
    this.titre = titre;
    this.auteur = auteur;
    this.imagepath = imagepath;
    this.musikURL = musikURL;
  }
}