# esbuild-Plugin

> 插件 API 是新的，仍处于实验阶段。在 `esbuild` 版本 1.0.0 之前，随着新用例的发现，它可能会发生变化。您可以关注跟踪问题以获取有关此功能的更新。

插件 API 允许您将代码注入构建过程的各个部分。与 API 的其余部分不同，它不能从命令行获得。您必须编写 JavaScript 或 Go 代码才能使用插件 API。插件也只能与[构建 API](https://esbuild.github.io/api/#build-api)一起使用，而不能与[转换 API](https://esbuild.github.io/api/#transform-api)一起使用。

## 查找插件

如果您正在寻找现有的 esbuild 插件，您应该查看[现有的 esbuild 插件列表](https://github.com/esbuild/community-plugins)。此列表中的插件是作者故意添加的，旨在供 esbuild 社区中的其他人使用。

如果你想分享你的 esbuild 插件，你应该：

- 1、将其[发布到 npm](https://docs.npmjs.com/creating-and-publishing-unscoped-public-packages)，以便其他人可以安装。
- 2、将其添加到现有 esbuild 插件列表中，以便其他人可以找到它。

## 使用插件

esbuild 插件是一个具有 name 和 setup function 的对象。它们以数组形式传递给构建 API 调用。每次生成 API 调用都会运行一次设置函数。

下面是一个简单的插件示例，允许您在构建时导入当前环境变量：

```js
let envPlugin = {
  name: "env",
  setup(build) {
    // 拦截名为 env 的导入路径，以便 esbuild 不会尝试将其映射到文件系统位置。
    // 用 env ns 名称空间标记它们，为该插件保留它们。
    build.onResolve({ filter: /^env$/ }, (args) => ({
      path: args.path,
      namespace: "env-ns",
    }));

    // 加载带有 env ns 名称空间标记的路径
    // 它们的行为就像指向包含环境变量的JSON文件一样。
    build.onLoad({ filter: /.*/, namespace: "env-ns" }, () => ({
      contents: JSON.stringify(process.env),
      loader: "json",
    }));
  },
};

require("esbuild")
  .build({
    entryPoints: ["app.js"],
    bundle: true,
    outfile: "out.js",
    plugins: [envPlugin],
  })
  .catch(() => process.exit(1));
```

您可以这样使用它：

```js
import { PATH } from "env";
console.log(`PATH is ${PATH}`);
```

## 概念

为 esbuild 编写插件与为其他捆绑包编写插件有点不同。在开发插件之前，必须了解以下概念：

### Namespaces

每个模块都有一个相关的命名空间。默认情况下，esbuild 在文件命名空间中运行，该命名空间对应于文件系统中的文件。但是 esbuild 也可以处理文件系统中没有相应位置的“虚拟”模块。出现这种情况的一种情况是使用标准输入法提供模块。

### Filters

每个回调都必须提供一个正则表达式作为过滤器。当路径与其过滤器不匹配时，esbuild 使用此选项跳过调用回调，这是为了提高性能。从 esbuild 的高度并行内部调用单线程 JavaScript 代码代价高昂，应尽可能避免，以获得最大速度。

您应该尽可能使用过滤器正则表达式，而不是使用 JavaScript 代码进行过滤。这会更快，因为正则表达式是在 esbuild 内部进行计算的，根本不需要调用 JavaScript。例如，下面的示例 HTTP 插件使用^ ^https?:// 以确保运行插件的性能开销仅适用于以 http:// 或 https:// 开头的路径。

允许的正则表达式语法是 Go 正则表达式引擎支持的语法。这与 JavaScript 略有不同。具体来说，不支持向前看、向后看和反向引用。Go 的正则表达式引擎旨在避免可能影响 JavaScript 正则表达式的灾难性指数时间最坏情况性能问题。

注意，名称空间也可以用于过滤。回调必须提供过滤器正则表达式，但也可以选择提供命名空间，以进一步限制匹配的路径。这有助于“记住”虚拟模块的来源。请记住，名称空间是使用精确的字符串相等测试而不是正则表达式进行匹配的，因此与模块路径不同，它们不用于存储任意数据。

## On-resolve callbacks

使用 onResolve 添加的回调将在 esbuild 构建的每个模块中的每个导入路径上运行。回调可以自定义 esbuild 执行路径解析的方式。例如，它可以拦截导入路径并将其重定向到其他地方。它还可以将路径标记为外部路径。下面是一个示例：

```js
let exampleOnResolvePlugin = {
  name: "example",
  setup(build) {
    let path = require("path");

    // Redirect all paths starting with "images/" to "./public/images/"
    build.onResolve({ filter: /^images\// }, (args) => {
      return { path: path.join(args.resolveDir, "public", args.path) };
    });

    // Mark all paths starting with "http://" or "https://" as external
    build.onResolve({ filter: /^https?:\/\// }, (args) => {
      return { path: args.path, external: true };
    });
  },
};

require("esbuild")
  .build({
    entryPoints: ["app.js"],
    bundle: true,
    outfile: "out.js",
    plugins: [exampleOnResolvePlugin],
    loader: { ".png": "binary" },
  })
  .catch(() => process.exit(1));
```

回调可以返回，而不提供将路径解析责任传递给下一个回调的路径。对于给定的导入路径，来自所有插件的所有 onResolve 回调将按照它们注册的顺序运行，直到其中一个插件负责路径解析。如果没有回调返回路径，esbuild 将运行其默认路径解析逻辑。

请记住，许多回调可能同时运行。在 JavaScript 中，如果回调进行了昂贵的工作，而这些工作可以在另一个线程上运行(如 fs.existsSync())。您应该通过 callback async 并使用 await(在本例中为 fs.promises.exists())以允许其他代码同时运行。在 Go 中，每个回调可以在单独的 goroutine 上运行。如果你的插件使用任何共享数据结构，请确保你有适当的同步。

### On-resolve options

onResolve API 旨在在 setup 函数内调用，并注册在某些情况下触发的回调。这需要几个选项：

```js
interface OnResolveOptions {
  filter: RegExp;
  namespace?: string;
}
```

#### filter

每个回调必须提供一个过滤器，它是一个正则表达式。当路径与此筛选器不匹配时，将跳过注册的回调。您可以在[此处](https://esbuild.github.io/plugins/#filters)阅读有关过滤器的更多信息。

#### namespace

这是可选的。如果提供了回调，则回调仅在提供的命名空间中的模块内的路径上运行。您可以在[此处](https://esbuild.github.io/plugins/#namespaces)阅读有关名称空间的更多信息。

### On-resolve arguments

当 esbuild 调用 onResolve 注册的回调时，它将为这些参数提供有关导入路径的信息：

```js
interface OnResolveArgs {
  path: string;
  importer: string;
  namespace: string;
  resolveDir: string;
  kind: ResolveKind;
  pluginData: any;
}

type ResolveKind =
  | "entry-point"
  | "import-statement"
  | "require-call"
  | "dynamic-import"
  | "require-resolve"
  | "import-rule"
  | "url-token";
```

#### path

这是来自底层模块源代码的逐字未解析路径。它可以采用任何形式。虽然 esbuild 的默认行为是将导入路径解释为相对路径或包名，但可以使用插件引入新的路径形式。例如，下面的示例 HTTP 插件为以 `http://` 开头的路径赋予了特殊含义。

#### importer

这是包含要解析的导入的模块的路径。请注意，只有当名称空间为 `file` 时，才能保证此路径为文件系统路径。如果要解析相对于包含导入器模块的目录的路径，则应使用 `resolveDir`，因为这也适用于虚拟模块。

#### namespace

这是包含要解析的导入的模块的命名空间，由加载此文件的[on-load callback](https://esbuild.github.io/plugins/#on-load)设置。这默认为使用 esbuild 的默认行为加载的模块的 `file` 命名空间。您可以在[here](https://esbuild.github.io/plugins/#namespaces)中阅读有关名称空间的更多信息。

#### resolveDir

这是将导入路径解析为文件系统上的真实路径时要使用的文件系统目录。对于文件命名空间中的模块，该值默认为模块路径的目录部分。对于虚拟模块，该值默认为空，但[on-load callbacks](https://esbuild.github.io/plugins/#on-load)也可以选择为虚拟模块提供解析目录。如果发生这种情况，将提供它来解析该文件中未解析路径的回调。

#### kind

这表示如何导入要解析的路径。例如，`entry-point` 表示路径作为入口点路径提供给 API，`import-statement` 表示路径来自 JavaScript `import` 或 `export` 语句，`import-rule` 表示路径源自 CSS `@import` 规则。

#### pluginData

此属性是从上一个插件传递的，由加载此文件的[on-load callback](https://esbuild.github.io/plugins/#on-load) 设置。

### On-resolve results

这是可以通过使用 onResolve 添加的回调返回的对象，以提供自定义路径解析。如果您想在不提供路径的情况下从回调返回，只需返回默认值（在 JavaScript 中为 `undefined`，在 Go 中为`onresolvereult{}`）。以下是可以返回的可选属性：

```js
interface OnResolveResult {
  errors?: Message[];
  external?: boolean;
  namespace?: string;
  path?: string;
  pluginData?: any;
  pluginName?: string;
  sideEffects?: boolean;
  suffix?: string;
  warnings?: Message[];
  watchDirs?: string[];
  watchFiles?: string[];
}

interface Message {
  text: string;
  location: Location | null;
  detail: any; // The original error from a JavaScript plugin, if applicable
}

interface Location {
  file: string;
  namespace: string;
  line: number; // 1-based
  column: number; // 0-based, in bytes
  length: number; // in bytes
  lineText: string;
}
```
