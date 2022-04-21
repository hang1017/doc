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

2、使用 `addEntryImports` 导入 `vConsole` 的压缩文件，**并追加到 `.umi/umi.ts` 文件下**。并命名为 `VConsole`。

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

可以看下[小虎 Oni-知识星球](https://wx.zsxq.com/dweb2/index/topic_detail/581522522811184)的详细讲解，粗略讲解如下：

当监听事件被定义在被引入的某个库时，我们可以通过创建 `const event = new CustomEvent('监听名称');` 并执行 `window.dispatchEvent(event);` 来出发监听事件。

`CustomEvent`：创建为用户出于任何目的而自定义的事件。并支持手动出发触发。

## 第七天

阅读 `/packages/plugins/src/request.ts`

这个插件的作用：内置 `ahooks` 的库，固定 `ahooks` 的版本，若用户显式安装了自定义的版本号，则用户安装的版本号优先。

`request` 引用 `@alita/request` 下的包，`useRequest` 引用业务项目中安装的 `ahooks` 的包。

好处：帮用户内置掉 `ahooks` 这个库，减少用户自行安装 `umi-request` 和 `ahooks` 这两个库。

这个文件的阅读就到这里，主要的要可以看下 `/packages/request/src/index.ts`。

接下来可以看下 `运行时配置` 的内容[feat: support runtime config](https://github.com/alitajs/alita/commit/8339c2a577d25c78ee3afcd8c63c57faa9fb8e92)：

## 第八天

### 1、什么是运行时配置？

`addRuntimePluginKey`

申明在 `app.ts` 里面可以使用某个配置，就像 `api.describe` 一样，声明 `config` 中多了什么配置。

`enableby`

开启当前插件的规则。

- config: 是可以根据 `modifyDefaultConfig` 等修改配置的 api 动态修改后启用或关闭。
- register: 就是用户写在 `config.ts` 或者 `umirc.ts` 下的配置。
- function: 可以自己判断开启时机，比如使用一些环境变量开启插件等就可以在这里判断。

### 2、阅读 [`Umi-next 源码阅读——插件机制`](https://www.yuque.com/docs/share/ad434e5a-79f9-4705-a12a-34e2d3a4dcc8?#)

整体流程如下：

#### （1）、init

加载各类配置信息，维护相应的子成员。

通过运行打印日志消息可以得到以下信息：

- `cwd`: 绝对路径
- `env`: 项目启动环境
- `args._`: 命令行参数。是通过使用 yParser 解析的命令后面携带的参数，常常我们会遇到如 `alita g page —explt=false` 这样的命令，`args` 就是除了 alita 后面的所有参数都有。
- `configManager`: 配置文件的路径、默认配置文件列表、`opts` 等信息。
- `userConfig`: 用户在配置文件下注册的数据，如 `config.ts`，`umirc.ts`

通过 `getPluginsAndPresets` 获取项目中完整的 `plugins` 和 `presets`。

主要通过 4 个地方进行数据的获取：

- opts
- env: 环境变量可以添加
- dependencies: umi 扫描符合插件命名的文件
- config

#### （2）、initPresets

在看这个内容之前，需要先知道 `presets` 和 `plugins` 的区别。

两者都为插件，`presets` 为内部文件，`plugins` 为外部插件的库。

注册 `presets`，获取 `config` 配置下的 `presets` 和 `plugins`；`plugins` 放队尾；`presets` 放队首(保证它们之间的相对顺序和关系)。

#### （3）、initPlugins

注册 `plugins`，

#### （4）、resloveConfig

整理各个插件对于 `config schema` 的定义。然后执行插件。

#### （5）、collectionAppData

执行 `modifyAppData` 的 hook 来维护 app 的元数据。

#### （6）、onCheck

执行 onCheck hook

#### （7）、onStart

执行 onStart hook

#### （8）、runCommand

运行当前 cli 要执行的 command

## 第九天

阅读 `packages/create-alita/src`

这个包的功能用于创建 app 和 plugin 模版。

`.cli.ts` 文件大致的内容就是判断命令行的准确性。并且调用 `index.ts` 的方法。

`args` 是通过使用 `yParser` 解析的命令后面携带的参数，常常我们会遇到如 `alita g page —explt=false` 这样的命令，`args` 就是除了 alita 后面的所有参数都有。

这里的 `args.default` 为了测试的时候，跳过 `prompts`。用户真实在创建 `alita` 项目时，是真的需要在终端一步步选择执行的。

剩下的重点在于 `BaseGenerator` 这里的内容，方法功能为执行模版复制的功能。后面细说，现在先来看下 `./index.test.ts` 的内容。

分别测试 创建项目和创建插件项目的方法。执行 `./index.ts` 文件，确认 `fixtures` 包下是否成功生成项目。

阅读 `BaseGenerator`

该功能的作用在于创建模版文件。

先解释 4 个入参：

- path：模版文件路径。
- target：目标路径。
- data：参数，比如模版的某些自定义的属性，用于替换模版的内容。
- questions：命令行执行异步的 questions。

进入核心代码，设计思路如下：

如果 `path` 是文件夹，则 `copy` 整个文件夹的内容到 `target` 上。

如果 `path` 是带 `tpl` 文件，说明要拷贝模版，记得带上包含 `data` 的 `context` 用于替换模版内容。

如果不是上面两种文件类型，则在业务项目上，创建同名文件，`copy` 内容。

## 第十天

dform:

完成 Grid 组件的开发。主要是为了学习 ts 的内容。

首先熟悉 Record 。

```ts
interface PageInfo {
  title: string;
}

type Page = "home" | "about" | "contact";

const nav: Record<Page, PageInfo> = {
  about: { title: "about" },
  contact: { title: "contact" },
  home: { title: "home" },
};
```

通过上面的代码可以看到 `Record` 后面的泛型就是对象键和值的类型。

然后看下 dform 的使用：

```ts
export interface NativeProps<S extends string = never> {
  className?: string;
  style?: CSSProperties & Partial<Record<S, string>>;
  tabIndex?: number;
}
```

这里的 `S` 是定义了一个范型，用户在使用 `NativeProps` 是可以通过 `NativeProps<'aa' | 'bb'>` 给 `S` 赋值。

使用场景如下：用户多次使用 `NativeProps` 但参数定义不相同的情况下可以使用。

`Partial`：将类型定义的所有属性都修改为可选。

拿上面的例子来说，`style` 可以定义为 `CSSProperties`，也可以使用用户自定义的参数类型，但是用户定义的参数类型都为可选，并非必填项。所以使用 `Partial<Record<S, string>>`。

最后一个定义 `never`。代表什么都没有，编译器用它来进行完整性检查。

开发 `Grid`，`GridItem` 需要对两者进行兼容，实现 `const { Item } = Grid`。

可以参考一下方法，并对该该方法进行讲解。

```ts
export function attachPropertiesToComponent<C, P extends Record<string, any>>(component: C, properties: P): C & P {
  const ret = component as any;
  for (const key in properties) {
    if (properties.hasOwnProperty(key)) {
      ret[key] = properties[key];
    }
  }
  return ret;
}
```

这里的 `C` 定义为组件，`P` 定义为 `key` 为 `string`, `value` 为 `any` 的对象。

最后的 `: C & P` 代表这个函数有返回值，并且可以为 `C` 或者 `P` 类型。

## 第十一天

阅读 `packages/plugins/src/dva.ts`

真的是完全看不懂，不过可以先从 `packages/plugins/src/utils/modelUtils.ts` 开始看。

`ModelUtils` 下提供的四个方法：

- `getAllModels`: 获取文件名为 `models` 下的所有文件，以及 `src` 下名为 `model` 的文件。功能就是获取所有 dva 模版。
- `getModels`:
- `isModelValid`:
- `getModelsContent`:
