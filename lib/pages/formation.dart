import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../func/export.dart';

class Formations extends StatefulWidget {
  const Formations({super.key});

  @override
  State<Formations> createState() => _FormationsState();
}

class _FormationsState extends State<Formations> {
  List<dynamic> videos = [];
  load() async {
    var v = await getData("api/auth/all/videos/");
    print(v);
    if (v != null) {
      videos = v['data'];
    }
    setState(() {});
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => back(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          "VIDÉOS DE FORMATION",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                video["coverImage"],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
              ),
            ),
            title: Text(
              video["titre"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              video["categorie"],
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.play_circle_fill,
              color: Colors.blueAccent,
              size: 32,
            ),
            onTap: () {
              if (video['video'] != null) {
                String videoUrl =
                    "${apiBase}media${video['video'].toString().split("media")[1]}";
                navigatePage(
                  context,
                  Video(videoUrl: videoUrl, isNetwork: true),
                );
                return;
              }
              messageInfo(context, "Aucun lien n'est spécifié !");
            },
          );
        },
      ),
    );
  }
}
