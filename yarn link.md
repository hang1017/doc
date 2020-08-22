# 使用 yarn link 实现安装本地库的测试

## 新建 demo 项目

新建 `alita` 移动端项目。

执行 `yarn add @alitajs/dform` 实现 `dform` 包的安装。

将你的 dform 代码引入到 demo 项目中。

## dform 源码

执行 `yarn build` 打包。

打包后执行 `yarn link`

```bash
APPLEdeMacBook-Pro:dynamicForm apple$ yarn link
yarn link v1.22.4
success Registered "@alitajs/dform".
info You can now run `yarn link "@alitajs/dform"` in the projects where you want to use this package and it will be used instead.
✨  Done in 0.04s.
```

执行后，dform 包就被你 `link` 完了。

## 回到 demo 中

根据上面的 命令行提示，我们在demo 中执行 `yarn link "@alitajs/dform"`

好了。如此你就把本地包装到你的 demo 中了。

## 注意事项

### 一

当 dform 源码修改后，都需要重新执行 `yarn build` 打包操作步骤。

打包后，demo 项目会自动帮你重新安装最新的本地包。

如果你不放心的也可以在 demo 中执行 `yarn link "@alitajs/dform"` 重新 `link`。

### 二

demo 中有需要取消本地包的 `link`。执行 `yarn unlink @alitajs/dform`。

如果觉得还是不对，在demo 中删除 `node_modules` 和 `yarn.lock` 后重新 `yarn` 一下安装依赖包就行。

