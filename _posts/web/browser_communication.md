浏览器内通信

## 不同窗口之间：
https://developer.mozilla.org/zh-CN/docs/Web/API/Window/postMessage

## 插件后台脚本与内容脚本之间

注意后台脚本与popup脚本不一样，后台脚本在menifest中通过`background`设置，在插件管理中”背景页“处调试。
而popup在menifest中通过`browser_actions`设置，在插件菜单按钮上通过”检查“打开调试窗口。

### 后台脚本、popup脚本向内容脚本
https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/connect
https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/API/tabs/sendMessage


### 内容脚本向后台脚本、popup脚本：

https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/connect

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/API/runtime/sendMessage



### 上面的通信方式有两种：一次性的与基于链接的。更多资料：


https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Content_scripts#connection-based_messaging

https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Content_scripts#choosing_between_one-off_messages_and_connection-based_messaging

## 与本地应用程序通信
https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/Native_messaging

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/API/runtime/connectNative

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/API/runtime/sendNativeMessage



