import 'package:flutter/material.dart';
import 'package:muffins_happy_place/pages/games_tab.dart';
import 'package:muffins_happy_place/pages/music_tab.dart';

import 'memories_tab.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({Key? key}) : super(key: key);

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding: const EdgeInsets.only(
                //     left: 20,
                //     top: 70,
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.menu, size: 30, color: Colors.black54),
                //       Expanded(child: Container()),
                //       Container(
                //         width: 30,
                //         height: 30,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(8),
                //           color: Colors.grey[500],
                //         ),
                //       ),
                //       SizedBox(
                //         width: 20,
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(
                //   height: 30,
                // ),
                // Container(
                //     padding: const EdgeInsets.only(left: 20),
                //     child: const BigAppText(text: "Discover", size: 30)),
                // const SizedBox(
                //   height: 30,
                // ),
                Container(
                  color: Colors.white12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                        indicator: CircleTabIndicator(
                          color: Colors.pink.shade100,
                          radius: 5,
                        ),
                        isScrollable: true,
                        labelPadding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        controller: _tabController,
                        labelColor: Colors.pink.shade200,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(
                            text: "Memories",
                          ),
                          Tab(
                            text: "Music",
                          ),
                          Tab(
                            text: "Games",
                          ),
                        ]),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: TabBarView(
                        controller: _tabController,
                        children: [MemoriesTab(), MusicTab(), GamesTab()]),
                  ),
                ),
                // const SizedBox(
                //   height: 30,
                // ),
                // Container(
                //     padding: const EdgeInsets.only(left: 20),
                //     child: BigAppText(text: "Explore more", size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final Color color;
  double radius;

  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final double radius;
  Color color;
  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    Paint _paint;
    _paint = Paint()..color = color;
    _paint = _paint..isAntiAlias = true;
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

class BigAppText extends StatelessWidget {
  final String text;
  final int size;
  const BigAppText({Key? key, required this.text, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size.toDouble(),
          color: Colors.black),
    );
  }
}
