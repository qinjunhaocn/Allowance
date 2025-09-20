import 'package:budget_simple/main.dart';
import 'package:budget_simple/pages/main_page_layout.dart';
import 'package:budget_simple/struct/database_global.dart';
import 'package:budget_simple/struct/functions.dart';
import 'package:budget_simple/struct/notifications.dart';
import 'package:budget_simple/struct/translations.dart';
import 'package:budget_simple/widgets/amount_button.dart';
import 'package:budget_simple/widgets/change_currency_icon.dart';
import 'package:budget_simple/widgets/home_message.dart';
import 'package:budget_simple/widgets/increase_limit.dart';
import 'package:budget_simple/widgets/spending_trajectory.dart';
import 'package:budget_simple/widgets/support_developer.dart';
import 'package:budget_simple/widgets/tappable.dart';
import 'package:budget_simple/widgets/text_font.dart';
import 'package:budget_simple/widgets/top_header_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:budget_simple/database/tables.dart';

bool enableKeyboardListen = true;

initializeAppWithUI(BuildContext context) async {
  await setDailyNotificationOnLaunch(context);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String amountCalculated = "";
  String formattedOutput = "";
  bool showedWarningSnackbar = false;
  late TextEditingController _textController;
  FocusNode focusNodeTextInput = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: "");
    Future.delayed(
      const Duration(milliseconds: 0),
      () {
        initializeAppWithUI(context);
      },
    );

    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (enableKeyboardListen == false) return false;
    if (Navigator.canPop(context)) return false;
    if (focusNodeTextInput.hasFocus) return false;
    if (event.runtimeType == KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.digit0) {
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad0) {
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad1) {
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad2) {
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad3) {
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad4) {
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad5) {
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad6) {
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad7) {
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad8) {
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad9) {
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.add) {
        addToAmount("+");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        addToAmount("+");
      } else if (event.logicalKey == LogicalKeyboardKey.period) {
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.comma &&
          getDecimalSeparator() == ",") {
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        addToAmount("<");
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        addToAmount("<");
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        addToAmount(">");
      }
    }

    return false;
  }

  removeAllAmount() {
    amountCalculated = "";
    formattedOutput = "";
    _textController.value = const TextEditingValue(
      text: "",
    );
    setState(() {});
  }

  addToAmount(String action) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (sharedPreferences.getBool("hapticFeedback") ?? true) {
      if (action == ">" || action == "+") {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    if (action == "<") {
      if (amountCalculated.isNotEmpty) {
        amountCalculated =
            amountCalculated.substring(0, amountCalculated.length - 1);
      }
    } else if (action == ">") {
      if (amountCalculated != "") {
        if ((double.tryParse(amountCalculated) ?? 0) > MAX_AMOUNT) {
          amountCalculated = MAX_AMOUNT.toString();
        }
        await database.createTransaction(
          TransactionsCompanion.insert(
            amount: double.tryParse(amountCalculated) ?? 0,
            name: _textController.text,
          ),
        );
        removeAllAmount();
      } else {
        if (showedWarningSnackbar == false) {
          final snackBar = SnackBar(
            content: Text(translateText('Enter an amount')),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          showedWarningSnackbar = true;
        }
      }
    } else if (action == "+") {
      if (amountCalculated != "") {
        if ((double.tryParse(amountCalculated) ?? 0) > MAX_AMOUNT) {
          amountCalculated = MAX_AMOUNT.toString();
        }

        await database.createTransaction(
          TransactionsCompanion.insert(
            amount: (double.tryParse(amountCalculated) ?? 0) * -1,
            name: _textController.text,
          ),
        );
        removeAllAmount();
      } else {
        if (showedWarningSnackbar == false) {
          final snackBar = SnackBar(
            content: Text(translateText('Enter an amount')),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          showedWarningSnackbar = true;
        }
      }
    } else if (action == "." || action == ",") {
      if (amountCalculated == "") {
        amountCalculated += "0.";
      } else if (!amountCalculated.contains(".")) {
        amountCalculated += ".";
      }
    } else {
      if (amountCalculated.split('.').length > 1 &&
          amountCalculated.toString().split('.')[1].length >= 2) {
        return;
      }
      if ((double.tryParse(amountCalculated) ?? 0) < MAX_AMOUNT) {
        showedWarningSnackbar = false;
        amountCalculated += action;
      }
    }

    if (amountCalculated == "") {
      formattedOutput = "";
      setState(() {});
      return;
    }

    NumberFormat currency =
        getNumberFormat(decimals: amountCalculated.contains(".") ? 2 : 0);
    formattedOutput = currency.format(double.tryParse(amountCalculated));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 400;
    BoxConstraints constraints = BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > maxWidth
            ? maxWidth
            : MediaQuery.of(context).size.width);

    Widget amountRemainingWidget = Tappable(
      color: Colors.transparent,
      onTap: () {
        addAmountBottomSheet(context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<SpendingLimitData>(
              stream: database.watchSpendingLimit(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const SizedBox();
                }
                return StreamBuilder<double?>(
                  stream:
                      database.totalSpendAfterDay(snapshot.data!.dateCreated),
                  builder: (context, snapshotTotalSpent) {
                    NumberFormat currency = getNumberFormat();
                    double amount =
                        snapshot.data!.amount - (snapshotTotalSpent.data ?? 0);
                    int moreDays = (snapshot.data!.dateCreatedUntil
                                .difference(DateTime.now())
                                .inHours /
                            24)
                        .ceil();
                    if (moreDays < 0) moreDays = 0;
                    moreDays = moreDays.abs();
                    return Column(
                      children: [
                        HomeMessage(
                            onClose: () {
                              dismissedPopupOver = true;
                              sharedPreferences.setBool(
                                  "dismissedPopupOver", true);
                              initializeAppStateKey.currentState
                                  ?.refreshAppState();
                            },
                            show: amount < 0 && dismissedPopupOver == false,
                            title: "Over budget!",
                            message:
                                "You overspent on your allowance. It is recommended to reset your allowance when your term ends to track how much you overspent."),
                        HomeMessage(
                            onClose: () {
                              dismissedPopupAchieved = true;
                              sharedPreferences.setBool(
                                  "dismissedPopupAchieved", true);
                              initializeAppStateKey.currentState
                                  ?.refreshAppState();
                            },
                            show: dismissedPopupAchieved == false &&
                                amount >= 0 &&
                                moreDays <= 0,
                            title: "Budget Achieved!",
                            message:
                                "Congratulations on finishing your allowance with money to spare! Reset your allowance by tapping the amount below."),
                        HomeMessage(
                            onClose: () {
                              dismissedPopupDoneOver = true;
                              dismissedPopupAchieved = true;
                              sharedPreferences.setBool(
                                  "dismissedPopupDoneOver", true);
                              initializeAppStateKey.currentState
                                  ?.refreshAppState();
                            },
                            show: dismissedPopupDoneOver == false &&
                                amount < 0 &&
                                moreDays <= 0,
                            title: "Term Completed Over Budget",
                            message:
                                "Your budget term has ended but overspent. Adjust your spending habits or budget goals for the next cycle. Reset your allowance by tapping the amount below."),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Column(
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                clipBehavior: Clip.none,
                                curve: Curves.elasticOut,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  switchInCurve: const ElasticOutCurve(0.6),
                                  switchOutCurve: const ElasticInCurve(0.6),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    final inAnimation = Tween<Offset>(
                                            begin: const Offset(0.0, 1),
                                            end: const Offset(0.0, 0.0))
                                        .animate(animation);
                                    return ClipRect(
                                      clipper: BottomClipper(),
                                      child: SlideTransition(
                                        position: inAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    key: ValueKey(snapshotTotalSpent.data),
                                    height: 67,
                                    child: TextFont(
                                      text: currency
                                          .format(amount < 0 ? 0 : amount),
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      autoSizeText: true,
                                      minFontSize: 15,
                                      maxFontSize: 55,
                                      maxLines: 2,
                                      translate: false,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 100),
                                  child: amount < 0
                                      ? TextFont(
                                          key: ValueKey(amount),
                                          text:
                                              "${currency.format(amount.abs())} ${translateText("overspent")}",
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontSize: 15,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                        )
                                      : const SizedBox.shrink(), // 注释掉'为了xxx更多的天'文本
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    Widget amountEnteredWidget = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeInOutCubicEmphasized,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final inAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation);
                return ClipRect(
                  clipper: BottomClipper(),
                  child: SlideTransition(
                    position: inAnimation,
                    child: child,
                  ),
                );
              },
              child: AnimatedSize(
                key: ValueKey(formattedOutput == ""),
                duration: const Duration(milliseconds: 300),
                clipBehavior: Clip.none,
                curve: Curves.elasticOut,
                child: SizedBox(
                  height: 55,
                  child: TextFont(
                    text: formattedOutput,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    autoSizeText: true,
                    minFontSize: 15,
                    maxFontSize: 55,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );

    Widget transactionNameFieldWidget = Stack(
      alignment: Alignment.bottomLeft,
      children: [
        TextField(
          controller: _textController,
          focusNode: focusNodeTextInput,
          textAlign: TextAlign.right,
          maxLength: 60,
          scrollPadding: const EdgeInsets.all(10),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            hintText: translateText("Transaction Name"),
            counterText: "",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
        ),
        // Income and Expense button beside text field, instead we use a big (+) button in the calculator
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 2, left: 5),
        //   child: Tappable(
        //     onTap: () {},
        //     color: Theme.of(context)
        //         .colorScheme
        //         .secondaryContainer
        //         .withOpacity(0.4),
        //     borderRadius: 10,
        //     child: IntrinsicHeight(
        //       child: IntrinsicWidth(
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(10),
        //           child: Stack(
        //             alignment: Alignment.topCenter,
        //             children: [
        //               FractionallySizedBox(
        //                 heightFactor: 0.5,
        //                 child: Container(
        //                   color:
        //                       Theme.of(context).colorScheme.secondaryContainer,
        //                 ),
        //               ),
        //               const Padding(
        //                 padding:
        //                     EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        //                 child: Column(
        //                   children: [
        //                     TextFont(
        //                       text: "Expense",
        //                       fontSize: 13,
        //                     ),
        //                     SizedBox(height: 8),
        //                     TextFont(
        //                       text: "Income",
        //                       fontSize: 13,
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );

    Widget amountButtonsTopWidget = SizedBox(
      width: constraints.maxWidth,
      child: Row(
        children: <Widget>[
          AmountButton(
            constraints: constraints,
            text: "7",
            addToAmount: addToAmount,
          ),
          AmountButton(
            constraints: constraints,
            text: "8",
            addToAmount: addToAmount,
          ),
          AmountButton(
            constraints: constraints,
            text: "9",
            addToAmount: addToAmount,
          ),
          AmountButton(
            constraints: constraints,
            text: "<",
            addToAmount: addToAmount,
            onLongPress: removeAllAmount,
            child: const Icon(Icons.backspace_outlined),
          ),
        ],
      ),
    );

    Widget amountButtonsBottomWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.75,
              child: Row(
                children: <Widget>[
                  AmountButton(
                    constraints: constraints,
                    text: "4",
                    addToAmount: addToAmount,
                  ),
                  AmountButton(
                    constraints: constraints,
                    text: "5",
                    addToAmount: addToAmount,
                  ),
                  AmountButton(
                    constraints: constraints,
                    text: "6",
                    addToAmount: addToAmount,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.75,
              child: Row(
                children: <Widget>[
                  AmountButton(
                    constraints: constraints,
                    text: "1",
                    addToAmount: addToAmount,
                  ),
                  AmountButton(
                    constraints: constraints,
                    text: "2",
                    addToAmount: addToAmount,
                  ),
                  AmountButton(
                    constraints: constraints,
                    text: "3",
                    addToAmount: addToAmount,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.75,
              child: Row(
                children: <Widget>[
                  AmountButton(
                    constraints: constraints,
                    text: "0",
                    widthRatio: 0.5,
                    addToAmount: addToAmount,
                    animationScale: 0.93,
                  ),
                  AmountButton(
                    constraints: constraints,
                    text: getDecimalSeparator(),
                    addToAmount: (_) => addToAmount("."),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: [
            AmountButton(
              constraints: constraints,
              text: "+",
              addToAmount: addToAmount,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: const Icon(Icons.add_rounded),
            ),
            AmountButton(
              animationScale: 0.96,
              constraints: constraints,
              text: ">",
              addToAmount: addToAmount,
              heightRatio: 0.5,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Icon(Icons.check), SizedBox(height: 30)],
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          //Minimize keyboard when tap non interactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                bottom: true,
                left: false,
                right: false,
                top: true,
                child: Column(
                  children: [
                    getIsFullScreen(context)
                        ? const SizedBox(height: 50)
                        : const TopHeaderButtons(large: false),
                    numberLogins == 8 ||
                            numberLogins == 17 ||
                            numberLogins == 30 ||
                            numberLogins == 50 ||
                            numberLogins == 100
                        ? const CashewPromoPopup()
                        : const SizedBox.shrink(),
                    const Spacer(),
                    amountRemainingWidget,
                    const Spacer(),
                    amountEnteredWidget,
                    transactionNameFieldWidget,
                    const SizedBox(height: 10),
                    amountButtonsTopWidget,
                    amountButtonsBottomWidget,
                    // 注释掉today进度条
                    // StreamBuilder<SpendingLimitData>(
                    //   stream: database.watchSpendingLimit(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.data == null) {
                    //       return const SizedBox();
                    //     }
                    //     double amountForPeriod = snapshot.data!.amount;
                    //     return StreamBuilder<double?>(
                    //       stream: database
                    //           .totalSpendAfterDay(snapshot.data!.dateCreated),
                    //       builder: (context, snapshotTotalSpent) {
                    //         DateTime currentDate = DateTime.now();
                    //         double amount = snapshot.data!.amount -
                    //             (snapshotTotalSpent.data ?? 0);
                    //         double percentSpent = 
                    //             1 - (amount / amountForPeriod).abs();
                    //         if (percentSpent > 1 || amount < 0) {
                    //           percentSpent = 1;
                    //         } else if (percentSpent < 0) {
                    //           percentSpent = 0;
                    //         }
                    //         double percentToday = 1 -
                    //             (snapshot.data!.dateCreatedUntil
                    //                         .millisecondsSinceEpoch -
                    //                     currentDate.millisecondsSinceEpoch) /
                    //                 (snapshot.data!.dateCreatedUntil
                    //                         .millisecondsSinceEpoch -
                    //                     snapshot.data!.dateCreated
                    //                         .millisecondsSinceEpoch);
                    //         if (percentToday > 1) {
                    //           percentToday = 1;
                    //         } else if (percentToday < 0) {
                    //           percentToday = 0;
                    //         }
                    //         return SpendingTrajectory(
                    //           height: 50,
                    //           percent: percentSpent,
                    //           todayPercent: percentToday,
                    //         );
                    //       },
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

addAmountBottomSheet(context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 350),
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const IncreaseLimit(),
      );
    },
  );
}

changeCurrencyIconBottomSheet(context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 350),
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const ChangeCurrencyIcon(),
      );
    },
  );
}

class BottomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0.0,
      size.height - 250,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
