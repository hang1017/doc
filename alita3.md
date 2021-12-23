# alita3 源码阅读

## 第一天

阅读 `/packages/alita/src/cli.ts` 粗略的梳理了下代码逻辑。

- 调用 umi 执行检查 node 版本的方法 和 是否是本地开发方法。
- 通过使用 `import { yParser } from'@umijs/utils'` 实现拿来取属性的操作。
- 通过 `process.argv.slice(2).\_[0]` 判断是否是开发环境，并使用 `process.env.NODE_ENV` 设置环境变量。
- 判断命令行内容，如果是 dev 就启动项目。是 `v or version` 就打印版本信息。

## 第二天

阅读 `/packages/plugins/src/mobile-layout.ts`

### 1、注册

在看到注册 `mobileLayout` 配置的时候，会怀疑为什么这个值改变的时候 `onChange` 不使用 `reload` 而是 `regenerateTmpFiles`。

这里先来看下 `ConfigChangeType` 的两个配置：

- `restart`，重启 dev 进程，默认是这个
- `regenerateTmpFiles`，重新生成临时文件

在业务项目中，如果不 `reload` 的话，怎么能够重新生成临时文件呢？

那么下一行的 `api.addRuntimePluginKey(() => ['mobileLayout']);`

`addRuntimePluginKey`：添加运行时插件的 key。 注册 runtime 配置。

当我们在 `app.ts` 上更改 `mobileLayout` 时，能够做到实时监听。

### 2、添加临时文件

通过 `onGenerateFiles` 生成 `.umi` 下的临时文件。

写文件的内容粗略的看了下和之前的代码保持一致。

唯一不理解的地方是：`Mustache.render` 这个是个啥？

通过阅读 `umi4` 的代码。发现这里是引入外部的压缩代码进来的。

然后对比下前后的模版区别。明白了可以通过 `Mustache.render` 实现模版字符串渲染。

新增了一个 `noPluginDir` 属性。用于是否直接在 `.umi` 下生成临时文件，还是会放到规定的 `plugin-${opts.api.plugin.key}` 下。应该是用于规范临时文件的路径用的，以免过多的临时文件导致难以查找。

最后

使用 `addUmiExports` 导出 `exports.ts` 的内容，可以在页面自定义配置 layout 的内容。

全部导出 `@alita/alita-layout/package` 用于获取 layout 下的类型定义等。

及在 `.umi/core/umiExports.ts` 下自动引入这些内容。

### 3、怎么实现全局 layout?

`umi4` 引入 `addLayouts` 的插件，能够使文件成为 `layout`。

## 第三天

阅读 `/packages/plugins/src/antdmobile.ts`

首先这个文件在 `/packages/plugins/src/index.ts` 里作为插件引入。并且在文件中没有看到关于未配置 `hd` 而被 `return` 的情况。说明在启动项目时都会执行这个文件。

注册 `hd` 的配置。

### 1、检测 `antd-mobile` 的版本配置

`checkAntdMobile` 通过文件名称以及返回的参数，我们可以知道该方法用于检测用户是否自行安装 `antd-mobile` 以及 `antd-mobile` 的版本号。

`api.pkg` 能够拿到项目中 `package.json` 下的 `json` 数据。

读取 `node_module` 下的 `antd-mobile` 版本信息。使用 `semver` 比较是否是 `v5` 版本。

### 2、addExtraBabelPlugins 配置额外的 babel plugin

这个配置是 `umi4` 新增的插件 API(不算新增,参考[modifyBabelPresetOpts](https://umijs.org/zh-CN/plugins/api#modifybabelpresetopts))，使用方式可以参考 `umijs/father` 库下的 [extraBabelPlugins](https://github.com/umijs/father#extrababelplugins)

通过 [antd-mobile 官网迁移指南](https://mobile.ant.design/zh/guide/migration) 可知，官网为 `v2` 发了一个影子包，所以我们可以直接给 `antd-mobile-v2` 增加按需加载的配置。

如果用户自行安装 `antd-mobile` 的版本，并且是 `v2` 版本。那么也需要给 `antd-mobile` 增加按需加载的配置。

### 3、chainWebpack 修改 webpack 配置

`getUserLibDir` 的作用读取 `node_module` 下某个依赖 `package.json` 的目录。这里几个方法可以讲解下：

- `resolve.sync(文件名, {basedir: 绝对路径})`: 读取 `node_module` 下 `and-mobile/package.json` 文件的绝对路径。
- `dirname`: 返回路径的目录名。

通过 `memo.resolve.alias.set` 优先设置用户自定义的 `antd-mobile-v2` 的版本。

通过 `memo.resolve.alias.set` 设置 `antd-mobile` 的版本，如果是 `v5` 的版本或者用户配置了 `hd`，则直接使用 `2x` 分支。

## 第四天

阅读 `/packages/plugins/src/hd.ts`

**hd 的插件的核心在于生成的临时文件的内容。**

### 1、modifyDefaultConfig

`hd` 的配置是 `obj` 对象。里面可传递 `theme`, `px2rem` 两个字段，这两个字段也是传递 `obj` 对象。

对于 `hd` 下的内容，要整合进配置中。使用 [modifyDefaultConfig](https://umijs.org/zh-CN/plugins/api#modifydefaultconfig)

先从方法出参中获取用户在 `config` 下的配置。然后通过 `api.userConfig.hd` 读取用户配置的 `hd` 数据(这里我觉得也可以从默认配置中获取到)。

`extraPostCSSPlugins`: 是为了给 `configPx2rem` 追加 `px2rem`。

通过阅读 `@alitajs/postcss-plugin-px2rem` [feat: support selectorDoubleRemList](https://github.com/alitajs/postcss-plugin-px2rem/commit/324d5eb00b408e51cca49ce8be40e362a8dfe282)
可知，这个操作会将 `px` 转化为 2 倍的 `rem`。

### 2、onGenerateFiles

生成 `.umi` 下的临时文件。这份临时文件才是重点。

### 3、addEntryImports

`getFile` 方法很好理解，不细说(看源码)。

想说为什么这个插件是用 `addEntryImports` 引入，而 `keepalive` 那些确是使用临时文件的方式通过 `React.createElement` 来引入。

因为 `keepalive`、`mobileLayout` 是以组件的形式创建的，而 `hd` 是通过全局引入的。所以两者需求一致，但是开发方式不同。

### 4、hd 临时文件

#### `l23~l34`:

> 有些兼容环境下, fontSize 为 100px 的时候, 结果 1rem=86px; 需要纠正 viewport;

所以我们需要创建一个宽度为 `1rem` 的 `div`，去获取真实的 `width`，比较下大小的一致性。如果不一致，就需要 `viewport`。

#### `l45~l63`:

获取 `meta[name="viewport"]`，如果没有就创建一个。

如果 `window != top` 说明是在 `iframe` 中打开 alita。

获取 `initial-scale` 的值，重新设置给 `meta[name="viewport"]` 下的 `initial-scale`、`maximum-scale`、`minimum-scale`。

这里有个疑问：在 `iframe` 中获取 `meta[name="viewport"]` 难道不会获取到 iframe 里的数据吗？

#### `l66~l99`:

处理屏幕缩放或者用户转动屏幕的情况。

取宽高中较小的值，乘于页面比例，再乘于缩放值。就是当前屏幕需要的 `fontsize` 值。

这里设置监听 `resize` 的意义是为了解决 `多次触发 resize 的情况，比如转动屏幕，有些手机会改变两次，有些只有一次` 的情况。

如果有弹出软键盘：`trueClient < 300` 也不纳入计算范围。

## 第五天

阅读 `/packages/plugins/src/keepalive.ts`

在业务项目中 `/src/.umi/plugin-keepalive` 下写入两个临时文件。

添加运行时插件 [addRuntimePlugin](https://umijs.org/zh-CN/plugins/api#addruntimeplugin)。

使用 `react-route6` 的功能。

先描述实现整体思路：

- 如果存在 keepalive 页面，则页面不销毁，隐藏起来。
- 通过 `Context.Provider` 传递配置 `keepalive` 数据。
- 使用 `useRef` 对已打开的 `keepalive` 页面元素进行存储。

---

- `useOutlet`: 类似 `children`, 可以通过 `const element = useOutlet();` 获取当前页面元素。
- `useLocation`: 通过使用 `const location = useLocation();` 获取 url 上的数据。

## 第六天

阅读 `/packages/plugins/src/aconsole.ts`

`aconsole` 的配置下有 `console` 和 `inspx` 两个参数，这两个参数都为 `obj` 类型。

分别配置对应的参数获取不同的功能。先看下 `console`

这里走三个步骤：

1、使用 `addHTMLStyles` 固定 `vConsole` 的样式。

2、使用 `addEntryImports` 导入 `vConsole` 的压缩文件。并命名为 `VConsole`。

3、使用 [`addEntryCode`](https://umijs.org/zh-CN/plugins/api#addentrycode) 在文件入口最后添加代码。引入 `VConsole` 并将配置数据作为入参。

接下来看 `inspx`：

判断运行环境，如果为开发环境或者强制指定 `production` 才会使用 `inspx`：

写入两个临时文件。

最后使用 [`addRuntimePlugin`](https://umijs.org/zh-CN/plugins/api#addruntimeplugin) 执行该插件。

参考 `inspx` git 使用教程，可以使用懒加载的方法加载 `inspx`。

这里有个疑问：下面这两行代码的作用是什么。

```js
const event = new CustomEvent("inspxswitch");
window.dispatchEvent(event);
```
