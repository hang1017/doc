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

## 第三天

阅读 `/packages/plugins/src/antdmobile.ts`

首先这个文件在 `/packages/plugins/src/index.ts` 里作为插件引入。并且在文件中没有看到关于未配置 `hd` 而被 `return` 的情况。说明在启动项目时都会执行这个文件。

注册 `hd` 的配置。

### 1、检测 `antd-mobile` 的版本配置

`checkAntdMobile` 通过文件名称以及返回的参数，我们可以知道该方法用于检测用户是否自行安装 `antd-mobile` 以及 `antd-mobile` 的版本号。

`api.pkg` 能够拿到项目中 `package.json` 下的 `json` 数据。

读取 `node_module` 下的 `antd-mobile` 版本信息。使用 `semver` 比较是否是 `v5` 版本。

### 2、addExtraBabelPlugins 配置额外的 babel plugin

这个配置是 `umi4` 新增的插件 API，使用方式可以参考 `umijs/father` 库下的 [extraBabelPlugins](https://github.com/umijs/father#extrababelplugins)

通过 [antd-mobile 官网迁移指南](https://mobile.ant.design/zh/guide/migration) 可知，官网为 `v2` 发了一个影子包，所以我们可以直接给 `antd-mobile-v2` 增加按需加载的配置。

如果用户自行安装 `antd-mobile` 的版本，并且是 `v2` 版本。那么也需要给 `antd-mobile` 增加按需加载的配置。

### 3、chainWebpack 修改 webpack 配置

`getUserLibDir` 的作用读取 `node_module` 下某个依赖 `package.json` 的目录。这里几个方法可以讲解下：

- `resolve.sync(文件名, {basedir: 绝对路径})`: 读取 `node_module` 下 `and-mobile/package.json` 文件的绝对路径。
- `dirname`: 返回路径的目录名。

通过 `memo.resolve.alias.set` 优先设置用户自定义的 `antd-mobile-v2` 的版本。

通过 `memo.resolve.alias.set` 设置 `antd-mobile` 的版本，如果是 `v5` 的版本或者用户配置了 `hd`，则直接使用 `2x` 分支。
