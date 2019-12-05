import 'dart:async';
import 'dart:math';

import 'package:dcache_flutter_example/dio_instance.dart';
import 'package:dcache_flutter_example/model/book_category_model.dart';
import 'package:dcache_flutter_example/model/book_model.dart';
import 'package:dcache_flutter_example/xtoast.dart';
import 'package:dcache_flutter/dcache.dart';
import 'package:dio/dio.dart';

/// 请求地址：http://apis.juhe.cn/goodbook/query
/// 请求参数：catalog_id=242&pn=&rn=&dtype=&key=fba00d322aa212b984de3a66fc07dcd6
/// 请求方式：GET

import 'package:flutter/material.dart';

class BookListView extends StatefulWidget {
  final BookCategoryModel category;
  BookListView({Key key, this.category}) : super(key: key);

  _BookListViewState createState() => _BookListViewState();
}

class _BookListViewState extends State<BookListView> {
  final bookListStream = StreamController<List<BookModel>>();

  final bookList = List<BookModel>();

  final pageSize = 10;
  int pageStart = 0;

  @override
  void dispose() {
    bookListStream.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book List'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: bookListStream.stream,
              builder: (ctx, snap) {
                if (snap.data == null) {
                  return Container(
                    child: Center(
                      child: Text('empty'),
                    ),
                  );
                }
                final list = snap.data as List<BookModel>;
                return Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, index) {
                      final book = list[index];
                      return ListTile(
                        title: Text(book.title),
                        subtitle: Text(book.sub1),
                      );
                    },
                  ),
                );
              },
            ),
            Container(
              height: 60,
              color: Colors.lightGreen[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Text('Refresh'),
                    onPressed: () {
                      refresh();
                    },
                  ),
                  FlatButton(
                    child: Text('Load more'),
                    onPressed: () {
                      loadMore();
                    },
                  ),
                  FlatButton(
                    child: Text('request with error'),
                    onPressed: () {
                      // Make an error request of server logic, which will be ignored by dcache.
                      requestBookList(
                          start: pageStart, categoryId: '', callback: null);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  requestBookList({
    int start,
    String categoryId,
    DCacheOptions option,
    Function(List<BookModel>) callback,
  }) {
    String urlStr =
        'http://apis.juhe.cn/goodbook/query?catalog_id=$categoryId&pn=$start&rn=$pageSize&dtype=&key=fba00d322aa212b984de3a66fc07dcd6';
    final uri = Uri.parse(urlStr);
    // Set a short enough timeout to cause a timeout error.
    // Then the cache data will be loaded.
    final mayTimeoutError = Random().nextBool() ? 1 : 1000;
    final reqOptions = Options(connectTimeout: mayTimeoutError);
    if (option != null) {
      reqOptions.extra = option.toJson();
    }
    DioManager.getInstance().getUri(uri, options: reqOptions).then((resp) {
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final resultcode = data['resultcode'] as String;
        if (resultcode != '200') {
          print('some error occured');
          print(data.toString());
          return;
        }
        final result = data['result'] as Map<String, dynamic>;
        final list = result['data'] as List;
        final aBookList = list.map((f) {
          return BookModel.fromJson(f);
        }).toList();
        if (callback != null) {
          callback(aBookList);
        }
      } else {
        final err = '${resp.statusMessage}<${resp.statusCode}>';
        XToast.showText(context, err);
        if (option.policy == DCachePolicy.refreshFirst) {
          print('The cache data is loaded if there is one');
        }
      }
    });
  }

  /// Refresh data from server first and read the cache if an error occurs.
  refresh() {
    final opt = DCacheOptions(policy: DCachePolicy.refreshFirst);
    requestBookList(
      start: 0,
      categoryId: widget.category.id,
      option: opt,
      callback: (bList) {
        bookList.clear();
        bookList.addAll(bList);
        pageStart = bookList.length;
        bookListStream.add(bookList);
      },
    );
  }

  /// Load from cache first, otherwise refresh from server.
  loadMore() {
    final opt = DCacheOptions(policy: DCachePolicy.cacheFirst);
    requestBookList(
      start: pageStart,
      categoryId: widget.category.id,
      option: opt,
      callback: (bList) {
        bookList.addAll(bList);
        pageStart = bookList.length;
        bookListStream.add(bookList);
      },
    );
  }
}
