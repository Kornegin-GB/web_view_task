import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';

/// Entrypoint of the application.
void main() async {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String urlImage = "";
  bool _isShowMenu = false;

  ///[_toggleFullscreen] включает/отключает полноэкранный режим браузера
  void _toggleFullscreen() {
    // Проверяем открыт ли полноэкранный режим браузера
    if (document.fullscreenElement == null) {
      // Если нет то открываем
      document.documentElement?.requestFullscreen();
    } else {
      // Если да то закрываем
      document.exitFullscreen();
    }
  }

  ///[_openMenu] открывает контекстное меню
  void _openMenu() {
    setState(() {
      _isShowMenu = true;
    });
  }

  ///[_closeMenu] Закрывает контекстное меню
  void _closeMenu() {
    setState(() {
      _isShowMenu = false;
    });
  }

  ///[_enterFullscreen] включает полноэкранный режим браузера
  void _enterFullscreen() {
    if (document.fullscreenElement == null) {
      document.documentElement?.requestFullscreen();
    }
    _closeMenu();
  }

  ///[_exitFullscreen] выключает полноэкранный режим браузера
  void _exitFullscreen() {
    if (document.fullscreenElement != null) {
      document.exitFullscreen();
    }
    _closeMenu();
  }

  ///[_registerFactory] регистрирует параметры [viewType] как созданное
  ///пользовательское содержимое для виджета [HtmlElementView]
  void _registerFactory() {
    platformViewRegistry.registerViewFactory("imageView", (int id,
        {Object? param}) {
      // Создаём тег img
      final img = document.createElement("img");
      // Атрибуты к тегу img
      img.attributes = {
        "src": urlImage,
        "alt": "Изображение",
      };
      // Добавляем стили к тегу img
      img.style.width = "100%";
      img.style.height = "100%";
      img.style.objectFit = "cover";
      img.style.overflow = "hidden";
      return img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: urlImage.isNotEmpty
                            ? GestureDetector(
                                onDoubleTap: () => _toggleFullscreen(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: HtmlElementView(
                                    viewType: "imageView",
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(hintText: 'Image URL'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            urlImage = _controller.text;
                          });
                          _registerFactory();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: _isShowMenu ? Colors.black.withValues(alpha: 0.7) : null,
              ),
            ),
            // Меню над кнопкой
            Positioned(
              bottom: 80,
              right: 20,
              child: _isShowMenu
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: _enterFullscreen,
                            child: Text("Enter fullscreen"),
                          ),
                          TextButton(
                            onPressed: _exitFullscreen,
                            child: Text("Exit fullscreen"),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
        //Кнопка в правом нижнем углу экрана
        floatingActionButton: FloatingActionButton(
          onPressed: _openMenu,
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
