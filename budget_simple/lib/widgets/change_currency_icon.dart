import 'package:budget_simple/main.dart';
import 'package:budget_simple/struct/database_global.dart';
import 'package:budget_simple/widgets/text_font.dart';
import 'package:flutter/material.dart';

class ChangeCurrencyIcon extends StatelessWidget {
  const ChangeCurrencyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // 用于保存临时输入的货币符号
    TextEditingController controller = TextEditingController(text: currencyIcon);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 5),
        child: TextFont(
          text: "Change Currency Icon",
          fontSize: 30,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ),
      IntrinsicWidth(
        child: TextFormField(
          controller: controller,
          maxLength: 5,
          decoration: InputDecoration(
            hintText: "\¥", // 使用固定的人民币符号作为提示文本
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 14,
            ),
          ),
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      const SizedBox(height: 35),
      // 添加取消和确定按钮
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 取消按钮
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 直接关闭弹出框，不保存更改
                  },
                  child: const TextFont(
                    text: "Cancel",
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // 确定按钮
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    String value = controller.text;
                    currencyIcon = value;
                    if (value.trim() == "") {
                      currencyIcon = "\$";
                    }
                    sharedPreferences.setString("currencyIcon", value);
                    initializeAppStateKey.currentState?.refreshAppState();
                    Navigator.pop(context);
                  },
                  child: const TextFont(
                    text: "Confirm",
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
