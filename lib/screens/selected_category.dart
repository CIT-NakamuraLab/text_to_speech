import 'dart:io';
import 'package:flutter/material.dart';
import 'package:text_to_speech_demo/models/opinion.dart';
import '../db/sql.dart';
import '../models/sample_model.dart';
import '../widgets/text_to_speech.dart';
import '../widgets/adding_edit_modal.dart';
import '../widgets/shake.dart';
import '../widgets/delete_dialog.dart';

class SelectedCategory extends StatefulWidget {
  static const routeName = "/selected-category";
  final String category;
  final String title;
  final IconData iconData;

  const SelectedCategory({
    super.key,
    required this.category,
    required this.title,
    required this.iconData,
  });

  @override
  State<SelectedCategory> createState() => _SelectedCategoryState();
}

class _SelectedCategoryState extends State<SelectedCategory> {
  late String categoryTitle;
  late List<Opinion> detailsItem;
  late IconData iconData;
  late String category;
  bool _loadedData = true;
  List<Map<String, dynamic>> cardItems = [];
  @override
  void initState() {
    // TODO: implement initState
    Shake.detector.startListening();
    category = widget.category;
    iconData = widget.iconData;
    categoryTitle = widget.title;
    print("initState");
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // initState -> didChangeDependencies
    // initStateにはcontextが作成されていないため
    if (_loadedData) {
      // final routeArgs =
      //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      // final String category = routeArgs["category"]!;
      // iconData = routeArgs["iconData"]!;
      // categoryTitle = routeArgs["title"]!;
      print("didChangeDependencies");
      await initData();
      await refreshItems(category: category);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Shake.detector.stopListening();
    super.dispose();
  }

  Future<void> initData() async {
    final db = await Sql.getAllItems();
    print(db.isEmpty);
    if (db.isEmpty) {
      SAMPLE_DATA.map(
        (data) async {
          await Sql.createItem(
              title: data.title,
              description: data.description,
              categories: data.categories);
        },
      ).toList();
    }
  }

  Future<void> refreshItems({required String? category}) async {
    print("refreshItems");
    final data = await Sql.refreshAndInitJournals(category: category!);
    // final data = await Sql.refreshAndFavoriteJournals();
    setState(() {
      cardItems = data;
      _loadedData = false;
    });
  }

  void _modal({required int? id, required String category}) async {
    // 宣言しているcategoryを引数とする理由は､lateであるため､buildまでにinitializedしていないためnull
    showModalBottomSheet(
      context: context,
      elevation: 20,
      isScrollControlled: true,
      builder: (context) {
        return AddingEditModal(
          id: id,
          category: category,
          journals: cardItems,
          refreshJournals: refreshItems,
          routeName: SelectedCategory.routeName,
        );
      },
    );
  }

  Future<void> _updateFavorite(
      {required int id, required int index, required String category}) async {
    int favorite = cardItems[index]["favorite"];
    if (cardItems[index]["favorite"] == 0) {
      favorite = 1;
    } else {
      favorite = 0;
    }
    await Sql.updateItemFavorite(id: id, favorite: favorite);
    refreshItems(category: category);
  }

  void buttonTapProcess(int index) {
    TextToSpeech.speak(
      cardItems[index]["description"],
    );
  }

  bool isDarkMode(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Platform.isIOS
              ? const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
          onPressed: () {
            // ここで任意の処理
            TextToSpeech.speak("1つ前のページに戻りました");
            Navigator.of(context).pop(); // 前の画面へ遷移
          },
        ),
        title: Text(
          categoryTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: _loadedData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: deviceHeight * 0.9,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        TextToSpeech.speak("情報を更新しました");
                        await refreshItems(category: category);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        child: ListView.builder(
                          itemCount: cardItems.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => buttonTapProcess(index),
                                  onLongPress: () => buttonTapProcess(index),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    leading: IconButton(
                                      onPressed: () => _updateFavorite(
                                        index: index,
                                        id: cardItems[index]["id"],
                                        category: category,
                                      ),
                                      icon: Icon(
                                        cardItems[index]["favorite"] != 0
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border,
                                        color: isDarkMode(context)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .inversePrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                    ),
                                    title: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        cardItems[index]["title"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                        key: const Key(
                                            "selected_category_title"),
                                      ),
                                    ),
                                    trailing: Wrap(
                                      alignment: WrapAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              _modal(
                                                id: cardItems[index]['id'],
                                                category: category,
                                              );
                                            },
                                            onLongPress: () {
                                              _modal(
                                                id: cardItems[index]['id'],
                                                category: category,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              key:
                                                  Key("selected_category_edit"),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return DeleteDialog(
                                                    index: index,
                                                    journals: cardItems,
                                                    category: category,
                                                    refreshJournals:
                                                        refreshItems,
                                                    routeName: SelectedCategory
                                                        .routeName,
                                                  );
                                                },
                                              );
                                            },
                                            onLongPress: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return DeleteDialog(
                                                    index: index,
                                                    journals: cardItems,
                                                    category: category,
                                                    refreshJournals:
                                                        refreshItems,
                                                    routeName: SelectedCategory
                                                        .routeName,
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(Icons.delete),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => _modal(
          id: null,
          category: category,
        ),
      ),
    );
  }
}
