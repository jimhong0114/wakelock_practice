import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '計時器 + Wakelock 切換 Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 0;//記錄經過幾秒
  Timer? _timer;//每秒觸發一次的計時器
  bool _wakelockEnabled = false;//記錄目前 wakelock 是否啟用，用來控制按鈕文字顯示

  @override
  void initState() { //是元件初始化時會執行的函式（畫面尚未顯示時）
    super.initState();

    // 啟用 wakelock
    WakelockPlus.enable();//啟用 wakelock，讓螢幕保持亮著，不會自動進入休眠狀態
    _wakelockEnabled = true;

    // 啟動計時器
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {  //啟動一個每秒觸發的 Timer
      setState(() {  //用 setState() 包起來，代表狀態有變化 → 重新建構畫面
        _seconds++;//每次觸發Timer時讓 _seconds 增加 1
      });
    });
  }

  @override
  void dispose() { //當 widget 被移除（例如跳到其他畫面）時
    _timer?.cancel();//停止計時器（避免資源浪費）
    WakelockPlus.disable();//停用 wakelock（讓螢幕恢復可以自動關閉）
    super.dispose();
  }

  // 切換 wakelock 狀態的函式
  void _toggleWakelock() async {
    final isEnabled = await WakelockPlus.enabled;//先取得目前 wakelock 是否啟用（非同步查詢）

    if (isEnabled) {
      await WakelockPlus.disable();
    } else {
      await WakelockPlus.enable();
    }// 根據目前狀態來啟用或停用 wakelock

    setState(() {
      _wakelockEnabled = !isEnabled;
    });//更新 _wakelockEnabled 這個變數的狀態，並觸發畫面重新建構（這樣按鈕文字會跟著改變）
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('計時中...')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '經過時間：$_seconds 秒',// 顯示計時秒數，使用變數 _seconds
              style: TextStyle(fontSize: 28),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleWakelock, // 一個按鈕，點擊時會呼叫 _toggleWakelock() 來切換 wakelock 狀態
              child: Text(
                _wakelockEnabled
                    ? '關閉螢幕常亮（wakelock）'
                    : '啟用螢幕常亮（wakelock）',//按鈕的文字根據目前狀態變化
              ),
            ),
          ],
        ),
      ),
    );
  }
}
