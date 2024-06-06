import 'package:flutter/material.dart';

class BootomModelSheet extends StatelessWidget {

  final VoidCallback? onPressedGallery;
  final VoidCallback? onPressedCamera;
  const BootomModelSheet({super.key,this.onPressedGallery,this.onPressedCamera});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: onPressedGallery,
          leading: Icon(Icons.photo_camera_back_sharp),
          title: Text('Select Image From Gallery'),
        ),
        ListTile(
          onTap: onPressedCamera,
          leading: Icon(Icons.camera_alt),
          title: Text('Select Image From Camera'),
        ),
      ],
    );
  }
}
