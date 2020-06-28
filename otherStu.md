# 乱七八糟的学习

## 一、前端之巅-大部分教程不会告诉你的12个JS技巧-2019.04.14

### 一、过滤唯一值

```js
const array = [1,2,3,4,4,4,4,5,5,"hang","hang1","hang"];
const a = [...new Set(array)];
console.log(a);
```

`ES6` 的写法，该用法可以自动帮你过滤到重复值，但是如果数组包含对象，就不管用了。

### 二、在循环中缓存数组长度

```js
for(let i = 0,length = arr.length;i<length;i++){}
```

这样操作的话性能更优~

### 三、短路求值

三元运算符比较便捷，但有时候页比较复杂，我们可以使用 `&&` 和 `||` 来替代：

```js
let one = 1,two=2,thr = 3;
console.log(one && two && thr); //3
console.log(0 && one);          //0

console.log(one || two || thr); //1
console.log(0 || null);         //null
```

使用 `&&` 可以返回第一个 `false`。如果所有的操作数都是 `true`，将返回最后一个表达式

使用 `||` 可以返回第一个 `true`。如果所有的操作数都是 `false`，将返回最后一个表达式

例子：

```js
return (foo || []).length;
```

```js
return (this.state.data || 'Feching Data');
```

### 四、将 String 值转换成 int

```js
let i= "15";
let flag = true;
i = +i;         //转换成数字类型
flag = +flag;   //也转换成数字类型 ：1
```

### 五、快速幂运算

从 `ES7` 开始可以使用 `**` 进行幂运算

```js
console.log(2 ** 3);        //8

// 一下表达式是等效的
Math.pow(2,n);
2 << (n-1);
2**n;
```

### 六、快速取整

使用 `|` 运算符会更快，帮你去除小数部分

```js
console.log( 23.9 | 0);     //23
console.log(-23.9 | 0);     //-23
```

### 七、截取数组的两种方法

```js
let arr = [0,1,2,3,4,5,6,7];
arr.length = 4;             //操作更简洁
arr = arr.slice(0,4);       //速度更快
```

上面两种方法都可以，就看你注重效率还是简介

### 八、获取数组最后的元素

数组 `slice()` 可以接收负整数

```js
arr.slice(-1);      //输出数组的最后一个数
arr.slice(-2);      //输出数组的最后两个数
```


## 二、git 起冲突的代码操作

```bash
git stash
git pull
git stash pop
```

## 三、淘宝静态页面开发

### ul li

`list-style-type`: 列表项目前面的符号 如： `none`、实心圆、空心圆等等

`list-style-image`: 定义使用图片来代替项目符号 `url()`

`list-style-position`: 项目符号在列表中显示位置的属性 `outside \ inside`

## 四、border

`border-sizing: border-box`: 边框在盒子内部呈现，不占用外部的 px;

## 五、Javascript之把网页加入收藏夹功能

```js
<script>
function addFav(){
      var title = document.title;
      var URL = document.URL;
  if(document.all){
        window.external.addFavorite(URL,title );
  }else if(window.sidebar){
        window.sidebar.addPanel(title, URL,'');
    }
}
 
<a href="#" rel="sidebar" onclick="addFav();">加入收藏</a></div>
```

## 六、H5 调原生方式

### 第一种：

判断是 ios 还是 android:

```js
var pattern_phone = new RegExp("iphone", "i");
var userAgent = navigator.userAgent.toLowerCase();
var isIphone = pattern_phone.test(userAgent);
```

关于附件下载，如果是ios:

```js
window.webkit.messageHandlers.openFileFlow.postMessage({ filepath: 'aa' });
```

安卓的话可以不走原生，直接： `window.location.href`

### 第二种：走 corodva~插件

```js
export function getLocationInfoFromNative() {
      return new Promise((resolve, reject) => {
            const callback = (addr) => {
            resolve(addr);
            }
            try{
            const NativePlugin = cordova.plugins.NativePlugin;
            NativePlugin.getLocationInfo(callback);
            } catch(e) {}
      })
}
```

在 `corodva_plugin` 文件夹下导出方法

```ts 
interface NativePlugin {
  getLocationInfo: (callback: ((addr: string) => void)) => void;
  goToCheckMenu: () => void;
}
```

最后在 ios 和 android 包下进行配置：

`NativePlugin.m` 和 `NativePlugin.java`:

```ts
- (void)getLocationInfo:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = nil;
    NSDictionary *addr = @{@"addr": @"1"};
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:addr];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)goToCheckMenu:(CDVInvokedUrlCommand *)command {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
```

```ts
private void goToCheckMenu(CallbackContext callback) {
      JSONObject addr = new JSONObject();
      PluginResult result = new PluginResult(PluginResult.Status.OK);
      callback.sendPluginResult(result);
}

private void getLocationInfo(CallbackContext callback) {
      JSONObject addr = new JSONObject();
      String addr = 
      try {
      addr.put("addr", "1");
      } catch (JSONException e) {
      e.printStackTrace();
      }
      PluginResult result = new PluginResult(PluginResult.Status.OK, addr);
      callback.sendPluginResult(result);
}
```


## 七：修改 input 输入框 placeHolder 的方法

```less
.am-input-control input {
      color: #fff;
      text-align: left;
      background-color: transparent;
      &::placeholder {
      // 自定义样式
      color: #fff;
      }
}
```

## 八、alitaJs 动态表单库

1、`less` 文件中不要写 `rem`

2、通过父控件获取到的参数可以通过 `...otherProps` 往下进行传递

3、类型定义使用 `I` 做前缀

4、git 提交说明规范

```js
const commitRE = /^(revert: )?(feat|fix|docs|style|refactor|perf|test|workflow|build|ci|chore|types|wip|release|dep)(\(.+\))?: .{1,50}/;
```

5、引用某个库的类型定义的转化可以有以下写法(说不清楚，直接看代码吧)

```js
modeType?: DatePickerPropsType['mode'];
```

6、其他类型的强定义规范

```js
export interface INomarInputProps extends InputItemPropsType {
      inputType: InputItemPropsType['type'];
      coverStyle?: React.CSSProperties;
      imgExtraClick?: (e: React.MouseEvent<HTMLElement>) => void;
}
```

7、在 `interface` 通过 `extends` 扩展时，`Omit<INomarInputProps, 'inputType'>` 可以剔除调某些必须定义到的属性，多属性可以用 `[]`

## 九、commonjs 为什么没有按需加载？

[聊聊 `package.json` 中的 `module` 字段](https://loveky.github.io/2018/02/26/tree-shaking-and-pkg.module/)

模块只能通过 `exports` 对象向外暴露属性。所以要暴露的方法、变量都只能作为 `exports` 对象的一个属性出现。

`ES6` 出现后，其中的 `import` 和 `export` 都是静态的，意味着一个模块要引入或者暴露的所有方法，在编译阶段就全部确定了。所以打包阶段可以知道哪些模块未被使用，可以用 `bundle` 文件中剔除掉。减少 `bundle` 文件大小，提高脚本执行速度。

`babel` 打包的代码会屏蔽掉 `node_modules` 目录下的文件。如果用户是基于 `ES6` 的规范发布的包，就必须配置复杂的屏蔽规则将我们的包加入编译的白名单。

`pkg.main` 字段指向的是编译后的 `ES5` 版本的代码。

`pkg.module` 字段要指向的是**基于 `ES6` 模块规范的 `ES5` 语法书写的模块**

ES6模块可以享受按需加载的好处， ES5 为了用户在配置 babel 插件的时候可以放心屏蔽 `node_modules` 目录。

## 十、图片增加水印

```js
/**
   * 图片添加水印
   */
  picWaterMark = ({
      url = '',
      textAlign = 'left',
      textBaseline = 'middle',
      font = "30px Microsoft Yahei",
      fillStyle = 'rgba(255, 255, 255, 0.8)',
      content = '请勿外传',
      content2 = '请勿外传',
      cb = null,
    } = {}) => {
      const img = new Image();
      img.src = url;
      img.crossOrigin = 'anonymous';
      img.onload = function () {
        const canvas = document.createElement('canvas');
        let imageWidth = img.width / 2;   //压缩后图片的宽度，这里设置为缩小一半
        let imageHeight = img.height / 2;
        canvas.width = imageWidth;
        canvas.height = imageHeight;
        const ctx = canvas.getContext('2d');

        ctx.drawImage(img, 0, 0, imageWidth, imageHeight);
        ctx.textAlign = textAlign;
        ctx.textBaseline = textBaseline;
        ctx.font = font;
        ctx.fillStyle = fillStyle;
        ctx.fillText(content, 10, 20);
        ctx.fillText(content2, 10, 50);
        let base64Url = '';
        let size = Math.round(url.length/1024*100)/100;
        console.log(size);
        if(size < 1200) {
          base64Url = canvas.toDataURL();
        } else {
          console.log(parseFloat((1200/size).toFixed(1)));
          base64Url = canvas.toDataURL("image/jpeg", parseFloat((1200/size).toFixed(1)));
        }
        // const base64Url = canvas.toDataURL();
        
        cb && cb(base64Url);
      }
      
  }
```

## 十一、iframe 打开页面样式错乱问题

```js
// 设置iframe页面的meta
export function resetIframeViewPort() {  
    try {
        const meta = document.querySelector('meta[name="viewport"]');
        window._contentBackUp = meta.getAttribute('content');
        const scale = window._contentBackUp.split('initial-scale=')[1].split(',')[0];
        meta.setAttribute('content', 'user-scalable=no, initial-scale=1.0, maximum-scale=1.0 minimal-ui');
        const html = document.querySelector('html');
        window._fontSize = html.style.fontSize;
        html.style.fontSize = window._fontSize.split('px')[0] * scale + 'px';
    } catch (error) {
        console.log('tool_setIframeViewPort', error);
    }
    
}

// 还原iframe页面的meta
export function backIframeViewPort() {  
    try {
        // 容错
        if (window._fontSize && window._contentBackUp) {
            const meta = document.querySelector('meta[name="viewport"]');
            meta.setAttribute('content', window._contentBackUp);
            const html = document.querySelector('html');
            html.style.fontSize = window._fontSize;
        }
    } catch (error) {
        console.log('tool_backIframeViewPort', error);
    }
}
```

## 十二、本地部署测试

1、yarn buid  
2、yarn global add serve 
3、cd dist 
4、serve 
5、浏览器访问http://localhost:5000/

## 十三、王志翔前端知识体系

### 1、运行机制

`JavaScript` 语言是单线程,同一个时间只做一件事。

任务队列：

任务需排队，很多时候因为IO设备(网络读取数据)很慢，导致堵塞情况。

主线程的任务可以不管IO设备，挂起等待中的任务，继续往下执行。

所以任务分为两种：

- 宏任务：在主线程上排队执行的任务。
- 微任务：不进入主线程，而是进入任务队列(先进先出)，只有任务队列通知主线程，某个微任务可以执行了，才进入主线程执行。

- 常见的宏任务队列 比如：setTimeout、setInterval、script（整体代码）、 I/O 操作、UI 渲染等。
- 常见的微任务队列 比如: new Promise().then(回调)、MutationObserver(html5新特性) 等。

### 2、惰性函数

编写一个方法，方法返回第一次执行的内容。

```js
var foo = function() {
  var t = new Date();
  foo = function() {
      return t;
  };
  return foo();
}
```

适用场景：

- 固定不变，一次判定，在固定的应用环境中不会发生改变
- 比如对浏览器做能力检测

## 十四、serve 本地服务部署

如果打包后文件没有增加，可以尝试修改test，如果打包后，部署页面空白，可以尝试修改priority。本地部署调试方式是
1、yarn buid  
2、yarn global add serve 
3、cd dist 
4、serve 
5、浏览器访问http://localhost:5000/










