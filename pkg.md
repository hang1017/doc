# 针对 package.json 的学习

## 一、关于 gitHooks

Git 能在特定的重要动作发生时触发自定义脚本

`pre-commit`: 钩子在键入提交信息前运行的(在我们新增一个commit前)，可以用来检查代码风格等操作，`git commit --no-verify` 可以绕过此环节

`prepare-commit-msg`: (在我们编辑一个commit的消息前调用)

`commit-msg`: (在我们编辑完一个commit的消息后调用)

`pre-push`: (在我们执行一次push操作前调用)

举例 `alita`: 

```js
"gitHooks": {
  "pre-commit": "lint-staged",
  "commit-msg": "node scripts/verifyCommit.js"
},
"lint-staged": {
  "**/*.less": "stylelint --syntax less",
  "**/*.{js,jsx}": "npm run lint-staged:js",
  "**/*.{js,ts,tsx,json,jsx,less}": [
    "npm run prettier",
    "git add"
  ]
},
```

## 二、lint-staged:

通俗的将是对 commit 的文件进行过滤

`*.js`: 对所有的 `.js` 后缀的名称进行匹配

`./*.js` 匹配 git repo 根目录中所有JS 文件，如 `/test.js` 但不匹配 `/foo/bar/test.js`

`foo/**/\*.js` 匹配 `/foo` 目录下的所有JS 文件，


