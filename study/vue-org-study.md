## 一、vue 自定义指令基础详解

1、全局注册

```js
Vue.directive("color", {
  inserted: function (el, binding) {
    el.style.color = binding.value;
  },
});
```

使用

```js
<h1 v-color="color">自定义指令</h1>
```

2、局部注册

```js
export default {
  data() { return color: 'red' },
  directives: {
    color: {...}
  }
}
```

3、自定义指令的钩子函数

- `bind`: 只调用一次，在指令第一次绑定到元素时调用，可以在这里进行初始化设置。
- `inserted`: 被绑定元素插入父节点时调用。
- `update`: VNode 更新时调用，通过比较更新前后的值来忽略不必要的模版更新。
- `componentUpdated`: 全部更新后调用。
- `unbind`: 只调用一次，解绑时调用。

4、[自定义定时指令](https://juejin.cn/post/6844903910365200392#heading-4)

## 二、表单修饰符和事件修饰符

1、事件修饰符

- `.stop`: 阻止事件传递
- `.prevent`:阻止默认事件
- `.capture`:在捕获的过程舰艇，没有 capture 修饰符时都是默认冒泡过程监听
- `self`:当前绑定事件的元素才能触发
- `.once`:事件只触发一次
- `passive`:默认事件会立即触发。

2、表单修饰符

.number, .lazy, .trim

## 三、 `v-if` 和 `v-for` 优先级是什么？如果同时出现怎么优化性能？

当他们处于同一节点， `v-for` 的优先级比 `v-if` 更高。这意味着 `v-if` 将分别重复运行于每个 `vfor` 循环中。

如果只想为部分项渲染节点时，这种优先级会十分有用。

如果目的是有条件的跳过循环的执行，那么可以将 `v-if` 置于循环之外。

## 四、获取路由传递过来的参数

1、meta: 写在 routes 配置文件中

```js
{
  path: '/home',
  name: 'home',
  component: load('home'),
  meta: {
    title: '首页'
  }
}
```

通过 `this.$route.meta.title` 获取。

2、query

```js
this.$route.push({
  path: "/home",
  query: {
    userId: 123,
  },
});
```

通过 `this.$route.query.userId` 获取。

3、params:

首先在地址上做配置

```js
{
  path: '/home/:userId',
  name: 'home',
  component: load('home'),
  meta: {
    title: '首页'
  }
}
```

访问传参

```js
this.$router.push({ name: "home", params: { userId: 123 } });
```

浏览器地址：`http://localhost:8000/home/123`,

获取方式：`this.$route.params.userId`

## 五、路由怎么跳转打开新窗口？

```js
const obj = {
  path: xxx,
  query: { mid: data.id },
};
const { href } = this.$router.resolve(obj);
window.open(href, "_blank");
```

## 六、getter、mutation、action 怎么访问到全局的 state 和 getter?

- getter 第三个参数 rootState 和 rootGetters 可以访问到全局的 state 和 getter
- mutation 不能访问到全局的 state 和 getter
- action 第一个参数 `context` 可以访问到。

## 七、实战 vue3 笔记

#### 1、setup

通过在 `<script setup` 实现更灵活的逻辑实现。

#### 2、定义子组件类型参数

```js
const props = defineProps({
  title: {
    type: String,
    default: '',
  },
  leftArrow: {
    type: Boolean,
    default: true,
  },
  leftClick: {
    type: Function,
  },
  attrs: {
    type: Object,
  }
})
```

`type` 为类型，`default` 为默认值，参数的传递都为可选，所以不需要处理必传和非必传的判断。

事件通过以下传递即可，获取时只需要 `props.fun()`。

```js
const func = () => console.log(123);

<NavBar :func="func"/>
```

#### 3、传递样式

通过插槽实现

```js
// 父
<NavBar title="title1">
  <template v-slot:right>
    <div>right</div>
  </template>
</NavBar>

// 子
<template #right>
  <slot name='right'/>
</template> 
```

#### 4、vue3 生命周期各方法及使用

https://cn.vuejs.org/api/composition-api-lifecycle.html#onmounted