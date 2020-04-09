import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'musik.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:volume/volume.dart';
import 'dart:async';
import 'package:flutter/services.dart';





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Musik',
      theme: ThemeData(
                primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Musik application'),
      debugShowCheckedModeBanner: false,

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

  List<Musik> musikList = [
    new Musik('Happier', 'Ed Sheeran', 'assets/happier.jpg', 'https://musik.ecs-id.com/happier.mp3'),
    new Musik('How do you feel', 'Ed Sheeran', 'assets/howdoyoufeel.jpg', 'https://musik.ecs-id.com/Howdoyoufeel.mp3'),
    new Musik('One', 'Ed Sheeran', 'assets/one.jpg', 'https://musik.ecs-id.com/One.mp3'),
    new Musik('Perfect', 'Ed Sheeran', 'assets/perfect.jpg', 'https://musik.ecs-id.com/Perfect.mp3'),
    new Musik('Photograph', 'Ed Sheeran', 'assets/photograph.jpg', 'https://musik.ecs-id.com/Photograph.mp3')
  ];


  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscrption;

  Musik actualMusik;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 30);
  PlayerState statut = PlayerState.STOPPED;
  int index = 0;
  bool mute = false;
  int maxVol = 0, currentVol = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actualMusik = musikList[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();

  }

  @override
  Widget build(BuildContext context) {

    double largeur = MediaQuery.of(context).size.width;
    int newVol = getVolumePourcent().toInt();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
        elevation: 20.0,
       ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              height : 200,
              width: 200,
              color: Colors.white,
              margin: EdgeInsets.only(top: 20.0),
              child: new Image.asset(actualMusik.imagepath),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0),
              child: new Text(
                actualMusik.titre,
                textScaleFactor: 3,
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top: 5.0),
              child: new Text(
                actualMusik.auteur,
                textScaleFactor: 2,
              ),
            ),
            new Container(
              height: largeur/5,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(
                      icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                      onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                    iconSize: 40
                  ),
                  new IconButton(icon: (mute) ? new Icon(Icons.headset_off) : Icon(Icons.headset), onPressed: muted),
                  new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward),
                  ],
                ),
              ),
            new Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textWithStyle(fromDuration(position), 0.8),
                  textWithStyle(fromDuration(duree), 0.8)
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: duree.inSeconds.toDouble(),
                  inactiveColor: Colors.grey[500],
                  activeColor: Colors.blue,
                  onChanged: (double d) {
                    setState(() {
                      audioPlayer.seek(d);
                    });
                  },
                  )
                ),

            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 5.0, right: 5.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.remove),
                      iconSize: 18,
                      onPressed: () {
                        if (!mute) {
                          Volume.volDown();
                          updateVolume();
                        }
                      },
                      ),
                  new Slider(
                    value : (mute) ? 0.0 : currentVol.toDouble(),
                    min: 0.0,
                    max: maxVol.toDouble(),
                    inactiveColor: (mute) ? Colors.red : Colors.grey[500],
                    activeColor: (mute) ? Colors.red : Colors.blue,
                    onChanged: (double d) {
                      setState(() {
                        if (!mute) {
                          Volume.setVol(d.toInt());
                          updateVolume();
                        }
                      });
                    },
                  ),
                  new Text((mute) ? 'Mute' : '$newVol%'),

                  new IconButton(
                      icon: new Icon(Icons.add),
                      iconSize: 18,
                      onPressed: () {
                        if (!mute) {
                          Volume.volUp();
                          updateVolume();
                        }
                      },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  /// récupérer le % de volume
  double getVolumePourcent() {
    return (currentVol/maxVol) * 100;
  }
  ///Initialiser le volume
  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  /// Update le volume
  updateVolume() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {
      /// en attente de quelque chose....
    });
  }
  /// Définir le volume
  setVol(int i) async {
    await Volume.setVol(i);
  }

  /// Gestion des textes avec style
  Text textWithStyle(String data, double scale) {
    return new Text(data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.black,
        fontSize: 15.0,
      ),
    );
  }

  /// Gestion des boutons
  IconButton bouton(IconData icone, double taille, ActionMusik action) {
    return new IconButton(
        icon: new Icon(icone),
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch(action) {
            case ActionMusik.PLAY:
              play();
              break;
            case ActionMusik.PAUSE:
              pause();
              break;
            case ActionMusik.REWIND:
              rewind();
              break;
            case ActionMusik.FORWARD:
              forward();
              break;
            default : break;

          }
        }
    );
  }

  /// configuration de l'audioPlayer
  void configAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });
      if (position >= duree) {
        position = new Duration(seconds: 0);
        // NEXT SONG par FORWARD;
      }
    });
    stateSubscrption = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      }
      else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.STOPPED;
        });
      }
    }, onError: (message) {
      print(message);
      setState(() {
        statut = PlayerState.STOPPED;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }
  Future play() async {
    await audioPlayer.play(actualMusik.musikURL);
    setState(() {
      statut = PlayerState.PLAYING;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.PAUSED;
    });
  }
  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      statut = PlayerState.STOPPED;
      position = new Duration();
    });
  }
  Future muted() async {
    await audioPlayer.mute(!mute);
    setState(() {
      mute = !mute;
    });
  }

  /// Passer à la musique suivante
  void forward() {
    if (index == musikList.length -1) {
      index=0;
    } else {
      index++;
    }
    actualMusik = musikList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();

  }

  /// Retour à la musique précédente
  void rewind() {
    if(position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if(index ==0) {
        index = musikList.length - 1;
      } else {
        index--;
      }
    }
    actualMusik = musikList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }

  String fromDuration(Duration duree){
    return duree.toString().split('.').first;
  }

}

enum ActionMusik {
  PLAY,
  PAUSE,
  REWIND,
  FORWARD
}
enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}