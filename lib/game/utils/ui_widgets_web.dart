// Web-specific implementation using dart:html
import 'dart:html' as html show document;
import 'package:flutter/material.dart';

void toggleWebFullscreen(ValueNotifier<bool> isFullscreen) {
  if (html.document.fullscreenElement != null) {
    html.document.exitFullscreen();
    isFullscreen.value = false;
  } else {
    html.document.documentElement?.requestFullscreen();
    isFullscreen.value = true;
  }
}
