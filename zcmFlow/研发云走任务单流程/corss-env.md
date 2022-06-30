## 一、设置变量

定义多个 build 命令对应不同的环境。

```json
{
  "scripts": {
    "build": "alita build",
    "builda": "cross-env AAAA='1' alita build"
  }
}
```

`config/config.ts`

```js
define: {
  AAAA: process.env.AAAA,
},
```

定义几个变量就在这里配置几个数据。
然后就可以在代码里获取到 `AAAA` 的数据了。

虽然 vscode 会红线提示报错。但是还是可以获取到这个数据。

```js
console.log(AAAA);
```

## 二、定义 deploy.sh 文件。

有几个环境就弄几个文件出来，放在根目录下，自己定义文件命名，比如：testDeploy.sh 、prodDeploy.sh 等。

然后不同的环境修改不同的 命令。
