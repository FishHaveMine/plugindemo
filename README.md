# plugindemo

调用插件demo项目

# 开发环境

Flutter 3.3.0-0.5.pre • channel beta • https://github.com/flutter/flutter.git
Framework • revision 096162697a (2 年 2 个月前) • 2022-08-22 15:34:14 -0700
Engine • revision ad3d868e0d
Tools • Dart 2.18.0 (build 2.18.0-271.7.beta) • DevTools 2.15.0

# 加载插件

  kongplugin:
    git:
      url: https://github.com/FishHaveMine/kongplugin.git
      ref: main

# 模拟点位服务
    协议说明: DDS HP热泵通信协议.docx
    node: S0_udpmock.js (启动指令: node S0_udpmock.js  , 需要安装node)

# demo运行环境说明
    1.启动模拟服务 或 启动HP 网关，连接到Wi-Fi
    2.运行flutter run (真机调试)，手机连接到相同的Wi-Fi
    3.开始点击页面右下角 搜索🔍按钮 进行设备搜索，app5秒内发送多条登录指令广播
    4.弹框显示搜索到的设备列表 按 设备名-IP 进行展示，点击对应的条目进行设备连接
    5.连接设备后，页面显示连接的设备ip，页面底部显示对应提供的功能 get config、set config、get point、set point、restart
    6.注意事项：
        6.1 set config 仅模拟Wi-Fi配置项下发，按文档说明 还能进行时区等设置，如：
        // 获取当前时间
        DateTime now = DateTime.now();
        // 获取当前时间的时间戳（毫秒级别）
        int timestamp = now.millisecondsSinceEpoch;

        var back = await _con?.post({
          "op": "set_config_common",
          "data": {
            "time": {"timestamp": "$timestamp", "timezone": "Asia/Shanghai"}
          },
        });

        时区列表对象文件: timezone.dart

        6.2 set point 方法： var back = await KongpluginHp().setPointVal("wirtelimit0", "10");  参数一是 get point 获取到的点位列表的点位对象 n 的属性值，参数二是下发修改的点位值
