import 'dart:developer';

import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
    required this.drawerNavList,
    required this.onDestinationSelected,
    required this.selectedChatId,
    required this.onDelete,
  });

  final List drawerNavList;
  final Function(int) onDestinationSelected;
  final String selectedChatId;
  final Function(String) onDelete;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _hoveredIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollBehavior: const ScrollBehavior().copyWith(scrollbars: false),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox.square(dimension: 30)),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: ListTile(
                      title: const Text("New Chat"),
                      onTap: () => widget.onDestinationSelected(-1),
                      enabled: widget.selectedChatId != "",
                      leading: const Icon(Icons.add),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      tileColor:
                          Theme.of(context).primaryColorLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox.square(dimension: 30)),
            if (widget.drawerNavList.isNotEmpty)
              SliverToBoxAdapter(
                  child: Text("Recent",
                      style: Theme.of(context).textTheme.titleMedium)),
            ...widget.drawerNavList.map(
              (item) {
                final index = widget.drawerNavList.indexOf(item);
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(50),
                      onHover: (value) {
                        setState(() {
                          _hoveredIndex = value ? index : -1;
                        });
                      },
                      child: ListTile(
                        selected: widget.selectedChatId == item.id,
                        selectedTileColor: Theme.of(context).highlightColor,
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        onTap: () {
                          log("index: $index");
                          widget.onDestinationSelected(index);
                        },
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        trailing: _hoveredIndex == index
                            ? InkWell(
                                onTap: () => widget.onDelete(item.id),
                                borderRadius: BorderRadius.circular(50),
                                hoverColor: Theme.of(context).highlightColor,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.delete_outline_rounded,
                                      size: 20),
                                ),
                              )
                            : null,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: Text(
                            item.title[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
