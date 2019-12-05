import 'dart:async';

import 'package:dcache_flutter_example/book_list_view.dart';
import 'package:dcache_flutter_example/dio_instance.dart';
import 'package:dcache_flutter_example/model/book_category_model.dart';
import 'package:dcache_flutter_example/xtoast.dart';
import 'package:flutter/material.dart';

class MenuView extends StatefulWidget {
  MenuView({Key key}) : super(key: key);

  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final categoryListStream = StreamController<List<BookCategoryModel>>();

  @override
  void initState() {
    super.initState();
    requestBookCategary();
  }

  @override
  void dispose() {
    categoryListStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Categary'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              requestBookCategary();
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: categoryListStream.stream,
        initialData: null,
        builder: (ctx, snap) {
          if (snap.data == null) {
            return Center(
              child: Text('empty'),
            );
          }
          final categoryList = snap.data as List<BookCategoryModel>;
          return ListView.builder(
            itemCount: categoryList.length,
            itemBuilder: (ctx, index) {
              final category = categoryList[index];
              return GestureDetector(
                child: ListTile(
                  leading: Text(category.catalog),
                  trailing: Icon(Icons.chevron_right),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return BookListView(category: category,);
                  }));
                },
              );
            },
          );
        },
      ),
    );
  }

  requestBookCategary() {
    String urlStr =
        'http://apis.juhe.cn/goodbook/catalog?dtype=&key=fba00d322aa212b984de3a66fc07dcd6';
    final uri = Uri.parse(urlStr);
    DioManager.getInstance().getUri(uri).then((resp) {
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final list = data['result'] as List;
        final cataList = list.map((f) {
          return BookCategoryModel.fromJson(f);
        }).toList();
        this.categoryListStream.add(cataList);
      } else {
        final err = '${resp.statusMessage}<${resp.statusCode}>';
        XToast.showText(context, err);
      }
    });
  }
}
