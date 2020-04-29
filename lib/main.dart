import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/services.dart';

import 'package:expense_plan/widgets/new_transaction.dart';
import 'package:expense_plan/models/transaction.dart';
import 'package:expense_plan/widgets/transaction_list.dart';
import 'package:expense_plan/widgets/chart.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoApp(
            title: 'Personal Expenses',
            theme: CupertinoThemeData(
                // primarySwatch: Colors.purple,
                // accentColor: Colors.amber,
                // fontFamily: 'Quicksand',
                // textTheme: ThemeData.light().textTheme.copyWith(
                //       title: TextStyle(
                //         fontSize: 18,
                //         fontFamily: 'OpenSans',
                //         fontWeight: FontWeight.bold,
                //       ),
                //       button: TextStyle(color: Colors.white),
                //     ),
                // appBarTheme: AppBarTheme(
                //   textTheme: ThemeData.light().textTheme.copyWith(
                //         title: TextStyle(
                //           fontSize: 20,
                //           fontFamily: 'OpenSans',
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                // ),
                ),
            home: MyHomePage(),
          )
        : MaterialApp(
            title: 'Personal Expenses',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.amber,
              fontFamily: 'Quicksand',
              textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                      fontSize: 18,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                    ),
                    button: TextStyle(color: Colors.white),
                  ),
              appBarTheme: AppBarTheme(
                textTheme: ThemeData.light().textTheme.copyWith(
                      title: TextStyle(
                        fontSize: 20,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            home: MyHomePage(),
          );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Personal Expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text('Personal Expenses'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: _pageBody(isLandScape, context, appBar),
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: _pageBody(isLandScape, context, appBar),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }

  Widget _pageBody(bool isLandScape, BuildContext context, AppBar appBar) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandScape)
              ..._buildLanscapeContent(
                context,
                appBar,
                isLandScape,
              ),
            if (!isLandScape)
              ..._buildPortraitContent(
                context,
                appBar,
                isLandScape,
              ),
            //if (!isLandScape) _buildTransactionList(context, appBar),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLanscapeContent(
      BuildContext context, AppBar appBar, bool isLandScape) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.title,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? _buildChart(context, appBar, isLandScape)
          : _buildTransactionList(context, appBar),
    ];
  }

  List<Widget> _buildPortraitContent(
      BuildContext context, AppBar appBar, bool isLandScape) {
    return [
      _buildChart(context, appBar, isLandScape),
      _buildTransactionList(context, appBar),
    ];
  }

  Container _buildChart(BuildContext context, AppBar appBar, bool isLandScape) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          (isLandScape ? 0.7 : 0.3),
      child: Chart(_recentTransactions),
    );
  }

  Container _buildTransactionList(BuildContext context, AppBar appBar) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(_addNewTransaction),
        );
      },
    );
  }

  void _addNewTransaction(String txTitle, double txAmount, DateTime txDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: txDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }
}
