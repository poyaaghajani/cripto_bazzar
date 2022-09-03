import 'package:api/data/constants/constants.dart';
import 'package:api/data/crypto.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CoinListScreen extends StatefulWidget {
  CoinListScreen({Key? key, this.cryptolist}) : super(key: key);
  List<Crypto>? cryptolist;

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptolist;

  bool isSearchVisibale = false;
  @override
  void initState() {
    super.initState();
    cryptolist = widget.cryptolist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'کریپتو بازار',
          style: TextStyle(fontFamily: 'mr'),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: blackColor,
      ),
      backgroundColor: blackColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  onChanged: (value) {
                    _filterList(value);
                  },
                  decoration: InputDecoration(
                      hintText: 'اسم رمز ارز معتبر را سرچ کنید',
                      hintStyle:
                          TextStyle(fontFamily: 'mr', color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      fillColor: greenColor),
                ),
              ),
            ),
            Visibility(
              visible: isSearchVisibale,
              child: Text(
                '...در حال اپدیت رمز ارزها',
                style: TextStyle(
                    fontFamily: 'mr', color: greenColor, fontSize: 18),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                  color: blackColor,
                  strokeWidth: 3,
                  backgroundColor: greenColor,
                  child: ListView.builder(
                    itemCount: cryptolist!.length,
                    itemBuilder: (context, index) {
                      return _getListTile(cryptolist![index]);
                    },
                  ),
                  onRefresh: () async {
                    List<Crypto> freshData = await _getData();
                    setState(() {
                      cryptolist = freshData;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListTile(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold, color: greenColor),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: greyColor),
      ),
      leading: SizedBox(
        width: 30,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[600]),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: greyColor),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getColorChangeText(crypto.changePercent24Hr),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 40,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24Hr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(Icons.trending_down, color: redColor)
        : Icon(Icons.trending_up, color: greenColor);
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');

    List<Crypto> cryptolist = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptolist;
  }

  Future<void> _filterList(String enteredKeyword) async {
    List<Crypto> cryptoResult = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchVisibale = true;
      });
      var result = await _getData();
      setState(() {
        cryptolist = result;
        isSearchVisibale = false;
      });
      return;
    }

    cryptoResult = cryptolist!
        .where(
          (element) => element.name.toLowerCase().contains(
                enteredKeyword.toLowerCase(),
              ),
        )
        .toList();

    setState(() {
      cryptolist = cryptoResult;
    });
  }
}
