# Stocks

Flutter KLine Chart

## Desc

Tokens kline

### Servers

websocket

- Binance
- Huobi
- OKEX

## Screenshot

![main](./preview/1.png)
![search](./preview/2.png)

## Start

推荐运行在 Mac os 平台，其次 iOS，Android

## Attention

### 大陆

默认设置了本地代理，由于不可描述原因，需要代理，科学上网

set Proxy:  设置代理

lib/net/net_adapter.dart
 - http_proxy default: 127.0.0.1:7890
 - https_proxy default: 127.0.0.1:7890

close proxy: 关闭代理

lib/net/net_adapter.dart
 - http_proxy = ""  // 给空字符串
 - https_proxy = "" // 给空字符串

### Other Region

close Proxy:

lib/net/net_adapter.dart
 - http_proxy = ""
 - https_proxy = ""

## Warning

不要运行 web 平台，因为没有适配，可能会发生一些莫名其妙 bug
no run web

## Hope to help you

如代码有迷糊行为请吐槽，谢谢

### 要不请我喝杯奶茶胖死我 😜

<div>
<img src="./preview/wechat-m.jpeg" width = "300" alt=""/>
<img src="./preview/ali.jpg" width = "300" alt=""/>
</div>