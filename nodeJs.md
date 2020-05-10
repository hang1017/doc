# Node.js 

## 一、简介

`node.js` 是基于 chrome v8 引擎的 JavaScirpt 运行环境。

每个连接都会生成一个新线程，一台系统只能支持特定的最大并发数。若要提高并发数量，会增加服务器成本，流量成本，人工成本等。

`node` 的解决办法：**更改连接到服务器的方式**，每个连接发射一个在 Node 引擎的进程中运行的事件，而不是为每个连接生成一个线程。

**优点**：使用事件驱动，非阻塞式 I/O 的模型，异步编程，使其轻量又高效。

**缺点**：单线程，单进程，只支持单核cpu，不能充分的利用多核cpu服务器。一旦这个线程崩了，整个 web 服务就崩了。

## 二、来个简单的demo

```js
var http = require('http');
var fs = require('fs');
var events = require('events');

// 创建服务器
http.createServer(function (request, response) {

    response.writeHead(200, {'Content-Type': 'text/plain'});

    const data = fs.readFileSync('input.txt');

    response.end('Hello World\n' + data);
}).listen(8888);

// 创建 eventsEmitter 对象
var eventsEmitter = new events.EventEmitter();

// 创建事件处理程序
var connectHandler = connected = (name) => {
    console.log('连接成功！' + name);
    // 触发 data_received 事件
    eventsEmitter.emit('data_received');
}
// 绑定 connection 事件
events.on('connection', (name) => {
    connectHandler(name);
});

// 用匿名事件绑定 `data_received` 事件
events.on('data_received', () => {
    console.log('接收成功！');
})

// 触发 connection 事件
events.emit('connection', '航航');


console.log('Server running at http://127.0.0.1:8888/');
```

```bath
node server.js
Server running at http://127.0.0.1:8888/
```

## 三、回调函数

已读取文件为例： 

- 阻塞代码实例：`const data = fs.readFileSync('input.txt')`
- 非阻塞代码实例：`fs.readFile('input.txt', function(err, data) {})`

## 四、EventEmitter

所有异步 I/O 操作都会发送一个事件到事件队列

**核心：事件触发与事件监听器功能的封装**

`on`: 用于绑定事件函数

`emit`: 用于触发一个事件

`addListener`: 绑定事件监听

`removeListener`: 移除事件监听器

`removeAllListeners`: 移除全部事件监听器

以及[其他方法](https://www.runoob.com/nodejs/nodejs-event.html)

## 五、Buffer 缓冲区

js 字符自身只有字符串数据类型，没有二进制数据类型。

在处理 TCP 或文件流，必须使用二进制数据。定义 buffer 类用来创建一个专门存放二进制的缓冲区

笔记代码：

```js
const buf = Buffer.from('hang', 'utf8');
console.log(buf);

// 创建一个长度为10 的Buffer
const buf1 = Buffer.alloc(256);
const len = buf1.write('hang123456');

// 读取数据
const buf2 = buf1.toString('utf8', 0, len);

// 缓冲区合并
const buf4 = Buffer.concat([buf1, buf3]);

// 比较
const buf6 = Buffer.from('abc');
const buf7 = Buffer.from('abcd');

const result = buf6.compare(buf7);
console.log('比较结果:' + result);

// copy
let buf8 = Buffer.from('hang123');
let buf9 = Buffer.from('abcd');
buf9.copy(buf8, 1);
console.log('copy:' + buf8);

// 裁剪
let buf10 = Buffer.from('123456789');
console.log('裁剪：' + buf10.slice(0, 4));
```

## 六、Stream 流

### 1、读取流

```js
var fs = require(fs);
let readerStream = fs.createReadStream('input.txt');
readerStream.setEncoding('UTF8');

readerStream.on('data', (val) => {})            // 当有数据可读时触发
readerStream.on('end', () => {})                // 没有更多的数据可读时触发
readerStream.on('error', (err) => {})           // 在接收和写入过程中发生错误时触发
readerStream.on('finish', (err) => {})          // 所有数据已被写入到底层系统时触发
```

### 2、写入流

```js
var fs = require('fs');
var data = '11';
var writerStream = fs.createWriterStream('aa.txt');
writerStream.write(data, 'UTF8');
writerStream.end();

writerStream.on('finish', () => {});
writerStream.on('error', (error) => {});

cat aa.txt                                  // 验证是否写入成功
```

### 3、管道流

如上面例子所示，我们可以先读取一个文件，再将内容写入到新文件中，如果想要更简便的方法，可以尝试管道流：

```js
var fs = require('fs');
var readStream = fs.createReaderStream('aa.txt');
var writerStream = fs.createWriterStream('bb.txt');

readStream.pipe(writerStream);
```

### 4、文件压缩操作

压缩和解压不能同时进行操作，否则会出现报错的情况。

```js
var fs = require('fs');
var zlib = require('zlib');

fs.createReadStream('aa.txt')
    .pipe(zlib.createGzip())
    .pipe(fs.createWriterStream('aa.txt.gz'))
console.log('压缩完成');

fs.createReadStream('aa.txt.gz')
    .pipe(zlib.createGunzip())
    .pipe(fs.createWriterStream('bb.txt'))
console.log('解压完成');
```

## 七、路由

获取url: `req.url`

获取url的全部参数：`arg = url.parse(req.url).query`

将url参数转化成对象：`querystring.parse(arg)` querystring 可以引入

代码：

```js
var http = require('http');
var url = require('url');
var querystring = require("querystring");

onRequest = (req, res) => {
  var arg = url.parse(req.url).query;
  var params = querystring.parse(arg);
  res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
  res.write('获取url的name + 参数：' + req.url + '\n');
  res.write('获取url的参数' + arg + '\n');
  res.write('获取url的某个参数' + params['addr'] + '\n');
  res.end();
}
http.createServer(onRequest).listen(8888);
```

## 八、全局对象

`__filename`: 当前正在执行的脚本的文件名，输出文件所在位置的绝对路径

`__dirname`: 当前执行脚本所在的目录

## 九、util

可以直接参考[官网](https://nodejs.org/api/util.html)

```js
const util = require('util');

util.inspect()  // 将对象转换成字符串的方法
```

## 十、GET/POST 请求

### 1、get 请求

参数可以通过 url 进行获取

### 2、post 请求

通过 `req.on` 来监听数据

```js
var http = require('http');
var querystring = require('querystring');

http.createServer((req, res) => {
    let body = '';
    req.on('data', (val) => {
        body += val;
    })
    req.on('end', () => {
        body = querystring.parse(body);
        res.writeHead(200, {'Content-Type': 'text/html; charset=utf8'});
        res.write(body);
    })
}).listen(3000);
```

## 十一、工具模块

### 1、OS模块

基本的系统操作函数

`os`: [官网地址](https://nodejs.org/api/os.html)

### 2、path模块

处理文件路径

`path`: [官网地址](https://nodejs.org/api/path.html)

```js
path.join('/text1', 'text2', 'text3') // 拼接路径 ‘text1/text2/text3’

path.resolve('main.js');            // 获取该文件的绝对路径

path.resolve('/foo/bar', '/tmp/file/');     // 第一个文件到第二个文件的绝对路径
```

### 3、net模块

用于底层的网络通信的小工具，包含了创建服务端和客户端的方法

笔记代码在 node 包中。

## 十二、Web 模块

### 1、web 服务器

web 服务器指网站服务器，其基本功能就是提供web信息浏览服务，只需支持 http协议，html文档格式，url。与客户端网络浏览器配合。

首先先创建一个简单的 `index.html` 页面。

其次开始 node 服务端代码编写

```js
var http = require('http');
var fs = require('fs');
var url = require('url');

http.createServer((request, response) => {
    const pathname = url.parse(request.url).pathname;
    // 输出请求的文件名
   console.log("Request for " + pathname + " received.");

    fs.readFile(pathnam.substr(1), (err, value) => {
        if(err) {
            response.writeHead(404, {'Content-Type': 'text/html'});
        } else {
            response.writeHead(200, {'Content-Type': 'text/html'});
            response.write(value.toString());
        }
        response.end();
    })
}).listen(8080);

console.log('Server running at http://127.0.0.1:8080/');
```

启动服务，输入 `http://localhost:8080/index.html`

### 2、客户端

```js
var http = require('http');

const options = {
    host: 'localhost',
    port: '8080',
    path: '/index.html'
}

const callBack = (response) => {
    let body = '';
    response.on('data', (val) => {
        body += val;
    })
    response.on('end', () => {
        console.log(body);
    })
}

const request = http.request(options, callBack);
req.end();
```

## 十三、Express 框架

### 1、基础使用

安装各种依赖：

```bath
yarn 
yarn add express
yarn add body-parser
yarn add cookie-parser
yarn add multer
```

```js
var express = require('express');
var app = express();

app.get('/', (req, res) => {
    res.send('hello world');
})

var server = app.listen(8080, () => {
    var host = server.address().address;
    var port = server.address().port;
    console.log(host, port);
})
```

框架用法如果有需要请参考[菜鸟教程](https://www.runoob.com/nodejs/nodejs-express-framework.html)

### 2、显示静态文件

使用 `app.use('/public', express.static('public'))` 进行处理静态文件的功能

在上面的代码基础上增加：

```js
app.use('/public', express.static('public'));
```

在浏览器上输入路径即可展示静态文件。

### 3、路由(get)

通过 form 表单进行页面跳转，通过 get 进行参数传递。

```js
var express = require('express');
var app = express();

app.get('/index.html', (req, res) => {              // 进行form 表单的页面展示
    app.readFile(__dirname + '/index.html');
})

app.get('/formSubmit', (req, res) => {              // 读 url 的数据
    const response = {
        'first_name': req.query.first_name,
        'second_name': req.query.second_name,
    }
    console.log(response);  
    res.send(JSON.stringify(response));
})

var server = app.listen(8080, () => {
    host = server.address().address;
    port = server.address().port;
    console.log(host, port);
})
```

### 4、路由(post)

通过 form 表单进行页面跳转，通过 post 进行参数传递

```js
var express = require('express');
var app = express();
var bodyParser = require('bodyParser');

// 创建 application/x-www-form-urlencoded 编码解析
var urlEncodedParser = bodyParser.urlencoded({ extended: false }); // 这个很重要，不写会报错

app.get('/index.html', (req, res) => {
    app.readFile(__dirname + '/index.html')
})

app.post('formPostSubmit', urlEncodedParser, (req, res) => {
    const response = {
        'first_name': req.body.first_name,
        'second_name': req.body.second_name,
    }
    console.log(response);
    res.send(JSON.stringify(response));
})
```

### 5、文件上传

```js
var express = require('express');
var bodyParser = require('bodyParser');
var multer = require('multer');
var fs = require('fs');
var app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(multer({ dest: '/tmp/' }).array('img'));        // 这里的 array 要和html 的 filename 保持一致，不然会报错

app.post('uploadFile', (req, res) => {
    res.writeHead(200,{'Content-Type':'text/html;charset=utf-8'});//设置response编码为utf-8
    console.log(req.files);  // 上传的文件信息
    var des_name = __dirname + '/' + req.files[0].originalname;
    fs.readFile(req.files[0].path, 'utf-8', (err, data) => {
        res.end(data);
        console.log(data.toString());
        fs.writerFile(des_name, data, (err) => {
            if (err) {
                console.log(err);
            } else {
                response = {
                filename: req.files[0].originalname
                };
                console.log(response);
                res.end(JSON.stringify(response));
            }
        })
    })
})
```

写个步骤：

- 先在上传后能够保持页面的正常跳转
- 能够读取到上传的文件内容
- 将内容写入到新的文件中。

## 十四、RESTful 

REST 表述性状态传递

REST 的四个基本方法：

- get: 用于获取数据
- put: 用于更新或添加数据
- delete: 用于删除数据
- post: 用于添加数据

使用步骤：

首先创建一个 `user.json` 数据存放一点内容进去

```json
{
  "user1": {
    "name": "hang1",
    "age": "11"
  }
}
```

```js
var express = require('express');
var fs = require('fs');
var app = express();

let user = {
    user4: {
        "name": "hang4",
        "age": "14"
    }
}

app.get('/user', 'utf-8', (req, res) => {
    res.writeHead(200, { "Content-Type": "text/html;charsetutf-8" });
    fs.readFile(__dirname + '/user.json', 'utf-8', (err, data) => {
        let newData = JSON.parse(data);
        newData['user4'] = user['user4'];
        delete newData['user1'];
        res.end(JSON.stringify(newData));
    })
})

var server = app.listen(8080, () => {
    const host = server.address().address;
    const port = server.address().port;
    console.log(host, port);
})
```

## 十五、express 框架(pug)

```bash
express --view=pug
```

`yarn` 后即可启动。

```js
// 用于配置页面文件的 `.ejs`文件 的根目录
app.set('views', path.join(__dirname, 'views'));
// 用于配置静态文件 `js css` 的根目录
app.use(express.static(path.join(__dirname, 'public')));
```

对于每次修改代码都要重启项目的烦恼，可以安装 `nodemon` 较为简便的自动化工具。

```bash
# 全局安装 nnodemon
sudo npm install -g nodemon

# 在项目中安装 nodemon
npm install --save-dev nodemon
```

`package.json` 文件定义依赖项和其他信息，以及一个调用应用入口（/bin/www，一个 JavaScript 文件）的启动脚本，

脚本中还设置了一些应用的错误处理，加载 app.js 来完成其余工作。

/routes 目录中用不同模块保存应用路由。/views 目录保存模板。

`cookie-parser`: 用于解析 cookie 头来填充 `req.cookies`(提供了访问 cookie 信息的便捷方法)

`morgan`: node 专用 HTTP 请求记录器中间件.

`/bin/www` 文件是应用的入口, 做的第一件事就是 `require` 真实的应用入口，app.js 会设置并返回 express() 应用对象。




























