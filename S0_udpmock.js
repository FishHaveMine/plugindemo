const dgram = require('dgram');
const server = dgram.createSocket('udp4');
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
function getRandom0Or1() {
  return Math.floor(Math.random() * 2); // 生成 0 或 1
}
var timezone = "";

function gettimezone1() {
  return timezone; // 生成 0 或 1
}
// 处理接收到的消息
server.on('message', (msg, rinfo) => {
  try {
    // 解析接收到的消息
    const request = JSON.parse(msg);

    // console.log(`收到消息: ${JSON.stringify(request)} 来自 ${rinfo.address}:${rinfo.port} : ${request.op}`);
    var response;
    // 检查消息格式
    if (request.op === 'gettoken' && request.seq !== undefined) {
      // 构建响应对象
      response = {
        op: 'gettoken',
        seq: request.seq,
        isAck: 1,
        name: 'xxxx', // 假设一个固定的 name 值
        token: "token",
        sign: request.sign // 返回接收到的 sign
      };
    }
    if (request.op === 'set_config_common') {
      try {
        timezone = request.data["time"]["timezone"]
        console.log("set_config_common timezone: " + timezone);
      } catch (error) {

      }
      response = {
        "op": "set_config_common", "seq": 1, "isAck": 0, "data": {
          "wifi_sta": {
            "ssid": "test_AP", "pwd": "test123456",
            "ip": "192.168.1.1", "netmask": "192.168.1.1", "gateway": "192.168.1.1"
          }
        }, "token": "xxxxxxxx", "sign": "xxxxxxxx"
      };
    }
    if (request.op === 'get_device_status') {
      const timestampMillis = Date.now();
      var timList = [
        "GMT0", "EAT-3", "CET-1", "GMT0",
      ];
      var index = getRandomInt(0, 3);
      console.log({ "timestamp": timestampMillis.toString(), "timezone": gettimezone1() == "" ? timList[index] : gettimezone1() });
      response = {
        "op": "get_device_status", "seq": 117, "isAck": 1, "data": {
          "wifi_sta": {
            "ssid": "test_AP", "pwd": "test123456",
          },
          "time": { "timestamp": timestampMillis.toString(), "timezone": gettimezone1() == "" ? timList[index] : gettimezone1() },
          "eth": { "internet": 0, "ip": "192.168.100.129", "netmask": "255.255.255.0", "gateway": "192.168.100.1" },
          "hp": { "connect": getRandom0Or1() },

          "ibuilding": { "url": "mqtts://ecs3.mideaibp.com:18883", "connect": 2 },
          "dev_info": { "sn": "DDSHPC4D8D56CCDF8", "sw_ver": "V1.0.Aug 29 2024 09:34:44", "latest_reboot": "1725050369" }
        }, "errCode": 0
      };
    }
    // 处理 get_points 请求
    if (request.op === 'get_points') {
      /**
       * n	Int	点位下标, 从0开始
        name	String	点位名称, 区分大小写
        v	Double	点位当前值
        rw	Int	读写属性
        0只读, 1 读写
        statu	Int	状态
        0离线, 1在线
        min	Double	数值范围最小值, 具有写属性的点才有这个属性点
        max	Double	数值范围最大值, 具有写属性的点才有这个属性点
       */
      try {
        var wirtelimit = [];
        var readonlt = [];
        for (var size = 0; size < 133; size++) {
          readonlt.push({
            "n": "readonlt" + size.toString(), "name": "readonlt" + size.toString(),
            "v": size == 0 ? getRandom0Or1() : getRandomInt(3, 100).toString(), "min": "10", "max": "40",
            "rw": 0, "statu": getRandom0Or1()
          })
          wirtelimit.push({
            "n": "wirtelimit" + size.toString(),
            "name": "wirtelimit" + size.toString(),
            "v": getRandomInt(3, 100).toString(),
            "min": getRandomInt(0, 3).toString(),
            "max": getRandomInt(10, 30).toString,
            "rw": 1, "statu": getRandom0Or1()
          })
        }
        var all = [
          { "n": "0", "name": "onOffStatus", "v": "1", "rw": 1, "statu": 1 },
          { "n": "1", "name": "ModbusOnOffStatus", "v": "1", "rw": 1, "statu": 1 },
          ...wirtelimit,
          ...readonlt
        ];
        // 计算开始和结束索引
        const startIndex = request.data.offset;
        const endIndex = startIndex + 30;

        // 使用 slice 方法提取固定长度的子数组
        const fixedLengthArray = all.slice(startIndex, endIndex);
        console.log("request.data.offset:" + request.data.offset);
        response = {
          "op": "get_points", "seq": 1, "isAck": 1, "data": {
            "offset": request.data.offset, "total": all.length, "points": fixedLengthArray
          }, "errorCode": 1, "errorMsg": "unhandled config"
        };
      } catch (error) {
        console.log(error)
      }
    }
    // 处理 set_points 请求
    if (request.op === 'set_point') {
      response = {
        op: 'set_point',
        seq: request.seq,
        isAck: 1,
        data: request.data,
        errorCode: 0,
        errorMsg: "set points success"
      };
    }


    // 处理 set_points 请求
    if (request.op === 'device_control') {
      response = {
        op: 'device_control',
        seq: request.seq,
        isAck: 1,
        data: request.data,
        errorCode: 0,
        errorMsg: "set points success"
      };
    }

    // 发送响应
    const responseMessage = JSON.stringify(response);

    // 在 200 毫秒后发送响应
    setTimeout(() => {
      server.send(responseMessage, rinfo.port, rinfo.address, (err) => {
        if (err) {
          console.error(`发送响应失败: ${err}`);
        } else {
          console.log(`已发送响应（${rinfo.port}）: ${responseMessage}`);
        }
      });
    }, 200); // 延迟 200 毫秒

  } catch (err) {
    console.error(`消息解析错误: ${err}`);
  }
});

// 处理服务器错误
server.on('error', (err) => {
  console.error(`服务器错误:\n${err.stack}`);
  server.close();
});

// 服务器监听指定端口
server.on('listening', () => {
  const address = server.address();
  console.log(`UDP 服务器正在监听 ${address.address}:${address.port}`);
});

// 绑定端口
server.bind(8101);
