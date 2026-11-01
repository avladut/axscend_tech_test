import 'package:app_ui/app_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// One album in a list.
class AlbumTile extends StatelessWidget {
  const new({required this.album, required this.onTap, super.key});

  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppListTile(
    leading: const Icon(Icons.photo_library_outlined),
    title: album.title,
    onTap: onTap,
  );
}
