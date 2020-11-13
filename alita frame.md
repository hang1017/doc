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

## 四、






