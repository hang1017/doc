# vue2 jeecgBoot keepalive 解决方案

## 前言

经公司项目测试，jeecgboot vue2 开源框架，目前只支持一、二级路由缓存，三级及以上路由在 tabs 切换时会丢失数据。

因为没有缓存到页面，导致每次进入页面都会重新初始化。

## 解决方案

**在处理解决方案前，请先确认下该路由菜单是否已经在菜单页面上开启缓存路由的按钮**

### 1）框架层面

首先针对以上问题，我们需要在创建路由前，对当前页面的路由层级进行处理。

比如：当需要对三级路由进行 `keepalive` 操作时，我们在 `router.beforeEach` 获取到路由层级列表的中间层级其实只是个菜单，并没有什么真实的使用场景。因此我们可以删除掉中间的层级菜单，只保留第一条的首页数据和最后一条的页面路由数据即可。

`src/router/index.js`

```diff
router.beforeEach((to, from, next) => {
+    if (to.matched && to.matched.length > 3 && to.meta.keepAlive) {
+        to.matched.splice(1, to.matched.length - 3)
+    }
  next()    
})
```

解决了框架层面的问题，这是我们怀着尝试的内心进行测试，发现有些小伙伴可以，但是还是有些无法实现 keepalive；或者说有些页面可以，但是有些页面不行。

### 2）代码问题

根据 [vue 官网keepalive](https://cn.vuejs.org/guide/built-ins/keep-alive.html) 说明：

> `keepalive` 会根据组件的 `name` 选项进行匹配，所以组件如果想要条件性地被 `KeepAlive` 缓存，就必须显式声明一个 `name` 选项。

说明在开发页面级组件时，需要给页面增加一个 `name` 属性。这个 `name` 属性需要和路由菜单的配置一致，才会使 `keepalive` 生效。

因此我们在定义这个 `name` 时，可以先看下页面初始化时调用的接口 `/sys/permission/getUserPermissionByToken`

看下每个路由菜单下 `meta.componentName` 数据。只要 `name` 和 `meta.componentName` 保持一致。即可实现 `keepalive`。




