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









