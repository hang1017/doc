# rollup.js 和 babel.js 学习

## rollup.js

### 一、命令行

#### 1、最简命令

```bash
rollup src/main.js -f cjs
```

- `cjs`: CommonJS 在 Node.js 中运行。
- `-f`: `--output.format` 的缩写。

因为没有指定输出文件，所以会直接展示在 `stdout` 上。

#### 2、指定文件

```bash
rollup src/main.js -o bundle.js -f cjs
```

通过 `-o fileName` 将打包后的代码展示在指定的文件内。

#### 3、增加配置文件

根目录下增加 `rollup.config.js` 的文件。

```js
// rollup.config.js
export default {
  input: "src/main.js",
  output: {
    file: "bundle.js",
    format: "cjs",
  },
};
```

## babel.js
