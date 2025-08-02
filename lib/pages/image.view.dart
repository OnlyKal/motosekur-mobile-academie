import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../func/export.dart';

class ViewImage extends StatelessWidget {
  final image;
  final page;
  const ViewImage({super.key, required this.image, required this.page});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainClr,
        leading: IconButton(
          onPressed: () => navigatePage(context, page),
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "IMAGE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: PhotoView(
        imageProvider: image!.isNotEmpty
            ? NetworkImage(urlImage(image!))
            : const AssetImage('assets/images/logo.png') as ImageProvider,
      ),
    );
  }
}
