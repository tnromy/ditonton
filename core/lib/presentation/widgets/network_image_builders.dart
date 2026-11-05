import 'package:flutter/material.dart';

Widget networkImagePlaceholder(BuildContext context, String url) =>
    const Center(child: CircularProgressIndicator());

Widget networkImageError(BuildContext context, String url, Object error) =>
    const Icon(Icons.error);
