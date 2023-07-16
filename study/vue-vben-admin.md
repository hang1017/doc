# 阅读 vue-vben-admin 源码 笔记

## 一、页面走向

Vue 整体走向先从根目录 `index.html` 开始。

通过 `script` 引入 `/src/main.ts` 开始实现创建应用实例的函数，并且要创建一个带 `id` 的 `div`。

`/src/main.ts`

- `createApp`
- 创建数据管理仓库
- 初始化内部系统配置：主题色、主题深浅模式、头部设置、导航栏设置等。
- 注册全局组件：组件注册后，既可以全局使用，不再需要重新引入。
- 国际化
- 路由配置
- 路由守卫
- 注册全局指令
- 配置全局错误处理

成功进入到 `/src/App.vue` 文件

进行全局配置，全局数据传递等操作，最终渲染 `<RouterView />` 。

`<router-view>` 暴露了一个 `v-slot` API，主要使用 `<transition>` 和 `<keep-alive>` 组件来包裹你的路由组件。

通过 `二、路由配置` 的内容，得知。页面将会从 `/@/layouts/default/index.vue` 开始。

这里可以看到页面的头部、侧边栏、主页内容的分布情况。

接下来进入到 `LayoutContent` 的内容：`/src/layouts/page/index.vue`

增加动画效果和 `keep-alive` 的配置。

至此，整个页面走向大致完成。

## 二、路由配置

通过 `/src/router/routes/index.ts` 的 `createRouter` 创建一个可以被 vue 应用程序使用的路由实例。

通过 `/src/main.ts` 的 `app.use(router);` 实现路由配置。

`routes` 被定义为 4 类。

- `/` 根目录路由，没有页面进行展示，会自动 `redirect` 到对应的配置页面。
- `/login` 登录页面。通过 `component` 和 `meta.title` 配置对应的页面和标题。
- `/main-out` 框架外的页面，及一个新的模块。
- `/:path(.*)*` 匹配的路由，增加 `LAYOUT` 的组件配置。

`src/router/routes/modules` 下的 `.ts` 文件会被视为一个路由模块。

除了 `layout` 对应的 `path` 前面需要加 `/`，其余子路由都不要以 `/` 开头。

## 三、路由守卫

## 四、keepalive

## 五、动画效果

## 六、多菜单导航

## 七、hook 逻辑

## 八、数据流

## 九、图表
