# alita库 框架学习笔记

## 一、generate 包

该包功能在于通过命令行生成代码。

1、注册命令

`/src/index.ts`:

方法中导出的 `api: IApi` 为 `umi` 中的插件机制，提供一系列方法支撑大家使用。

`api.registerGenerator` 为注册生成器，用于生成模板文件等。

`registerGenerator` 下的两个方法：

- `key`: 命令行关键字，命令行通过 key 得知需要执行什么操作。
- `Generator`: 命令行执行操作的内容。

2、编写代码模版

`/src/generate/pages`

以 `tpl` 后缀命名的文件就是模版代码，模版代码可增加可配置的参数，通过 `{{{ ~ }}}` 可赋值，传参的方式下文介绍。

3、命令行操作

`/src/generate/pages/index.ts`

当终端监听到指定的命令行，通过上述 `Generator` 可进入到 `/generate/pages/index.ts`

文件初始化 `constructor(opts: any) {}` 的 `opts` 参数里包含一下参数：

- cwd：项目的当前地址
- args：命令行创建的命名

`writing()` 为将模版写入项目的操作，为异步，所以需要加 `async`。

`copyTpl` 为迁移模版的方法，可以思考下需要如何操作才能实现模版代码拷贝到项目的指定位置。

首先需要模版代码的位置，其次为拷贝到项目中的哪个位置，以及模版代码里需要增加哪些可配置的参数。

- `templatePath`: 为模版的位置 `__dirname` 是当前文件的文件夹位置。
- `target`: 目标位置，`api.paths` 提供了几个属性：`absPagesPath`-`pages` 文件夹下的路径，`absSrcPath`-`src` 下的路径。
- `context`: 可配置模版里的参数。最新的版本应该只需要用到 `componentName`。

4、alita g app 创建项目

`/src/generate/app.ts`

这里和上述第三点一样，唯一不同的地方是新建整个项目，所以是拷贝整个文件夹。

`copyTpl` 下有提供 `path` 的属性，指定到对应的目录下就行。

5、`jest` 测试

`/src/index.test.ts` 文件夹下：

`runGenerator` 执行命令行：`pages index`:

期望(`expect`) 异步存在 `existsSync`： cwd/pages/index/index.tsx  有文件。

测试成功后，删除测试生成的文件：`rimraf.sync(join(cwd, 'pages'));`。

6、非主流程功能和库

`chalk` 库：颜色的库，在 `generate` 包下用于配置终端颜色。

## 二、retain-log 包

关于 `api` 中提供的 `describe` 方法，可以在 [umi 官网-describe](https://umijs.org/zh-CN/plugins/api#describe-id-string-key-string-config--default-schema-onchange--)中看到使用方法：

**注册阶段执行，用于描述插件或插件集的 id、key、配置信息、启用方式等。**

1、api.describe

共提供4个方法：

- `default`: 为配置的默认值，用户没有配置时取这个
- `schema`:  用于声明配置的类型，基于 `joi`，如果你希望用户进行配置，这个是必须的，否则用户的配置无效
- `onChange`: 是 `dev` 阶段配置被修改后的处理机制，默认会重启 dev 进程，也可以修改为 `api.ConfigChangeType.regenerateTmpFiles` 只重新生成临时文件，还可以通过函数的格式自定义
- `enableBy`: 为启用方式，默认是注册启用，可更改为 `api.EnableBy.config`，还可以用自定义函数的方式决定其启用时机（动态生效）

通过 alita 的代码得知: `retainLog`，默认为 `false`

`schema`：`return joi.boolean();` 则为用户可进行配置，且数值为 boolean 类型。

2、执行

代码做了判断操作

`if (NODE_ENV === 'production' && !api.userConfig.retainLog)`

有小伙伴可能不知道 `userConfig` 是什么。不着急，[umi 官网-userConfig](https://umijs.org/zh-CN/plugins/api#userconfig)有使用说明。

**纯用户配置，就是 .umirc 或 config/config 里的内容，没有经过 defaultConfig 以及插件的任何处理。**

那么这个判断的意思就简单明了了：如果当前环境为生产，且 `retainLog` 配置为 `false`，则执行。

`addHTMLScripts`：在 HTML 尾部添加脚本。

删除控制台打印信息。


## 三、main-path 包

用于配置初始页面的路径

`config.ts/umirc` 下增加 `mainPath` 的配置。

根据代码 `if (api.userConfig.mainPath)` 判断如果用户设置了 `mainPath`，则执行以下方法。

在 [umi 官网-modifyRoutes](https://umijs.org/zh-CN/plugins/api#modifyroutes)，可得知：用于修改路由。

## 四、layout 包

该包为在 `config` 配置 `mobileLayout` 所用。当用户配置 `mobileLayout` 时会执行该包。

1、注册 key

```js
api.describe({
  key: 'mobileLayout',
  config: {
    default: {},
    schema(joi) {
      return joi.boolean();
    },
    onChange: api.ConfigChangeType.regenerateTmpFiles,
  },
});
```

通过 `describe` 注册 `mobileLayout` 时，看到代码中调用 `onChange` 的方法。**`onChange`: 是 `dev` 阶段配置被修改后的处理机制，默认会重启 `dev` 进程**。


`onChange` 执行 `api.ConfigChangeType`，该方法可参考[官网](https://umijs.org/zh-CN/plugins/api#configchangetype)，**当 `config` 改变时执行**。提供以下两种方法：

- `restart`: 重启 dev 进程，默认是这个。
- `regenerateTmpFiles`: 重新生成临时文件。

这里有个疑问：`config` 里配置 `mobileLayout` 修改为 `false` 则会重新编译，`.umi` 文件里就少了 `alita-layout`，这没问题。为啥我改回 `true` 就不重新编译了呢？`.umi` 文件夹里也没有重新生成 `alita-layout`。

第二个疑问：`api.addRuntimePluginKey` 是做什么用的？

2、编写临时文件

```js
api.onGenerateFiles(() => {
  api.writeTmpFile({
    path: RELATIVE_MODEL_PATH,
    content: getModelContent(),
  });
})
```

先看下[官网-onGenerateFiles](https://umijs.org/zh-CN/plugins/api#ongeneratefiles)对于 `onGenerateFiles` 的解释：**生成临时文件，触发时机在 `webpack` 编译之前。**

通过 `api.writeTmpFile` 将临时文件写进项目中。

- `path`: 文件路径、名称
- `content`: 文件内容

我们做一个测试：可以按着上面的代码，新建一份临时模版代码。将路径`path`、内容`content` 编写后，启动项目，能够在 `/src/.umi` 文件夹下找你新建的文件。

3、使用临时文件

```js
api.modifyRoutes((routes) => [
  {
    path: '/',
    component: utils.winPath(
      join(api.paths.absTmpPath || '', DIR_NAME, 'AlitaLayout.tsx'),
    ),
    routes,
  },
]);
```

因为 `layout` 为全局配置，所以要修改路由配置。

最外层由临时文件 `AlitaLayout` 包裹。

4、导出

最后一步：导出文件下的每个属性。

```js
api.addUmiExports(() => [
  {
    exportAll: true,
    source: '@alitajs/alita-layout',
  },
]);
```

`addUmiExports`: **添加需要 umi 额外导出的内容** [官网](https://umijs.org/zh-CN/plugins/api#addumiexports)

- `exportAll`: 是否全部导出
- `source`: 需要被导出的文件地址

5、`/src/layout/index.tsx` 文件阅读

这个文件在创建 `AlitaLayout.tsx` 临时模版的时候被进入。

```js
api.writeTmpFile({
  path: join(DIR_NAME, 'AlitaLayout.tsx'),
  content: getLayoutContent(
    utils.winPath(join(__dirname, './layout/index.js')),
    !!api.userConfig.keepalive,
    isMicroApp,
  ),
});
```

再阅读下 `AlitaLayout.tsx` 临时文件的代码：

**该文件功能为将页面级 `navBar` 配置替换到全局**

```js
return React.createElement(require('${path}').default, {
  layoutConfig,
  hasKeepAlive: ${hasKeepAlive},
  ...props,
  hideNavBar:${isMicroApp},
})
```

可以说明，项目启动时，会新建 `alita-layout` 下的两个模版并执行。

在 `AlitaLayout` 模版下，会找到依赖包中 `layout/index.tsx` 的位置并执行。

接下来正式进入 `/layout/index.tsx` 文件的阅读。

临时文件 `layoutState.ts` 里的方法在第四小节 `导出` 被导出到 `umi` 里。

所以该文件能够从 `umi` 中导出 `getPageNavBar`, `setPageNavBar`, `setTabBarList`, `getTabBarList`, `layoutEmitter` 等方法。

我们页面上调用 `setPageNavBar` 的方法，其实是执行到临时文件 `layoutState.ts` 里的方法。`layout/index.tsx` 监听到方法的执行，能够拿到最新的配置，进行更改。

获取到页面级的 `navBar` 和 `tabBar`，执行 `changeNavBarConfig` 和 `changeTabBarListConfig` 方法进行替换。

## 五、router 包

`router` 提供的方法是从 `history` 带过来的。

若 `alita` 要支持导出 `history` 则需要写临时文件。方法和第四小节 `layout` 包方法差不多。

编写临时文件，并导出文件中的方法。

```js
api.onGenerateFiles(() => {
  api.writeTmpFile({
    path: RELATIVE_MODEL_PATH,
    content: getContent(), // 为 /src/utils/getContent 的文件
  });
});

api.addUmiExports(() => [
  {
    exportAll: true, 
    source: `../${RELATIVE_MODEL}`, // 文件地址
  },
]);
```
`/src/utils/getContent` 文件里的内容自己解读即可。

## 六、keepalive 包

`/src/index.ts`

注册 `keepalive` 配置(支持修改时生成临时文件)，写入临时文件，导出临时文件里的字段和方法。

主要代码还是在生成的三个临时文件，接下来分析下三个文件的功能。

1、`/keep-alive/KeepAlive.tsx`：

```js
const KeepAliveLayout = (props:any) => {
  return React.createElement(require('${path}').default, {
    keepalive:[${keepalive}],
    ...props
  })
}
export {KeepAliveLayout}
```

这里的 `path` 为 `KeepAliveLayout.tsx` 文件。

创建 `KeepAliveLayout` 组件，将 `keepalive` 作为属性传入。

2、`/keep-alive/KeepAliveLayout.tsx`：

先对文件里的三个方法进行功能分析：

- `isKeepPath`: 是否是 keepalive 的页面。
- `getKeepAliveViewMap`: 获取所有 `keepalive` 的数据，并对数据结构进行改造，以 `'/path': {...props}` 的形式展示。
- `getView`: 获取当前页面的 `keepalive` 数据。

样式代码中，若是 `keepalive` 的页面放在 `rumtime-keep-alive-layout` div 下展示，若不是当前的页面则隐藏。

若非 `keepalive` 的页面，放到 `rumtime-keep-alive-layout-no` div 下展示。

3、`/keep-alive/KeepAliveModel.tsx`:

新增 `dropByCacheKey` 方法，用户消除某个页面的 `keepalive` 状态。

`LayoutInstance` 的数据在 `KeepAliveLayout.tsx` 的文件里初始化时被设置。

















