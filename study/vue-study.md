# vue study

### 1、attribute 属性，响应式的绑定自定义属性：

```js
<div v-bind:id='dynamicId'></div>

// 等同于
<div :id='dynamicId' />

// 绑定多个属性值
const objectOfAttrs = {
  id: 'container',
  class: 'wrapper'
};
<div v-bind="objectOfAttrs" />

// js 表达式
<div :id="`list-${id}`"/>

// 事件
<div v-on:click="doSomething"/>
// 等同于
<div @click="doSomething"/>

// 动态参数
<a v-bind=[attributeName]='url'>...</a>
// 等同于
<a :[attributeName]='url'>...</a>

// 动态事件
<a v-on=[eventName]='doSomething'>...</a>
// 等同于
<a @[eventName]='url'>...</a>
```

### 2、响应式基础

```js
// 创建对象和数组
const state = reactive({ count: 0 });

// 创建响应式变量
const count = ref(0);
// 取值
console.log(count.value);

// 响应式语法糖
let count = $ref(0);
// 取值
console.log(count);
```

### 3、计算属性 computed

```js
// 计算属性缓存
const a = computed(() => {
  return book.length > 0 ? 'yes' : 'no'
})
// 方法
function b() {
  return book.length > 0 ? 'yes' : 'no'
}
```

- 计算属性值会基于其响应式依赖被缓存。一个计算属性只会在其响应式以来更新时才会重新计算。
- 方法总会在重渲染发生时再次执行函数。

```js
const firstName = ref('John')
const lastName = ref('Doe')

// 可写的计算属性
// 通过 getter 和 setter 来创建
const fullName = computed({
  get() {
    return firstName.value + ' ' + lastName.value;
  },
  set(newValue) {
    [firstName.value, lastName.value] = newValue.split(' ');
  }
})
```

> getter 中不要做异步请求或者更改 DOM。

### 4、class 与 style 绑定

```js
<div
  class='static'
  :class="{ active: isActive, 'text-danger': hasError}"
></div>

// 或

<div class="[active text-danger]"></div>

// 或
const classObj = reactive({
  active: true,
})

// 通过 `$attrs` 来绑定动态的元素
<p :class="$attrs.class"/>
```

### 5、条件渲染

`v-if` 和 `v-show`

`v-show`: 不论条件如何始终会被渲染。**不支持在 `template` 上使用。**

`v-if`: 只有当条件为 `true` 时才会重建，否则会被销毁。

### 6、列表渲染

```js
<li v-for="item in items">
  {{ item.message }}
</li>

// 或
<li v-for="(item, index) in items"/>

// for 与对象
<li v-for="(value, key) in myObj">
{{ key }}: {{ value }}
</li>
```

### 7、事件处理

```js
function greet(event) {

}
<div @click="greet"/>

// 或

function say(msg) {
  alert(msg);
}
<div @click="say('aaa')"/>

// 或
<div @click="warnFun('aa', $event)"/>
<div @click="(event) => warnFun('aa', event)"/>
```

事件修饰符

```js
// 单击事件将停止传递
<a @click.stop="doThis"/>

// 提交事件将不再重新加载页面
<form @submit.prevent="onSubmit"/>

// 修饰语可以使用链式书写
<a @click.stop.prevent="doThat"/>
```

### 8、生命周期

`onMounted`: 用来在组件完成初始渲染并创建 DOM 节点后运行。

`onUpdated` 和 `onUnmounted`

`Renderer` -> setup -> beforeCreate -> `init Options API` -> created -> beforeMount -> `initial render` -> mounted -> `Mounted` -> beforeUnmount -> unmounted

### 9、监听器 watch

```js
// 可接受多个来源的数组
watch([x, () => y.value], ([newX, newY]) => {})

/**
 * 深层监听器，支持对象内属性的监听
 * ps: 会监听所有层级的属性，若是大型数据结构，开销很大。
 */
watch(obj, () => {}, { deep: true })

/**
 * 创建监听器时立即调用一遍
 */
watch(source, () => {}, { immediate: true })

/**
 * 回调中访问 vue 更新后的 dom
 * 或者使用 watchPostEffect
 */
watch(source, callback, { flush: 'post' })
```

**`watchEffect`** 函数的优点

- 会自动立即执行，不需要指定 `immediate: true`，消除手动维护依赖列表的负担
- 会自动追踪 value 值作为依赖，不需要显式的定义
- 比深度监听器效率好，只监听回调用中被使用到的属性，而不是递归跟踪所有属性


```js
watchEffect(async () => {
  const response = await fetch(`https://jsonplaceholder.typicode.com/todos/${todoId.value}`);
  data.value = await response.json();
})
```

监听器必须用同步语句创建，如果异步回调创建一个监听器，不会被绑定到当前的组件上，并且必须手动停止它。

```js
const unwatch = watchEffect(() => {})

unwatch();
```

### 10、模版引用 ref

声明一个 `ref` 来存放该元素的引用，必须和模版里的 ref 同名。

```js
const input = ref(null);

onMounted(() => { input.value.focus() })

<input ref='input'/>
```

支持在 `v-for` 中使用 `ref`。ref 以数组的形式存放。**但是并不保证与源数组相同的顺序**

函数模版需要使用 `:ref`：<input :ref="(el) => {}"/> 当元素被卸载时会被调用一次。

在组件中绑定 `ref`。子组件需要通过 `defineExpose` 导出。

### 11、组件基础

父子组件的事件传递 `emit`：

```js
// 父组件
<Father @enlarge-text="fontSize += 0.1"/>

// 子组件
const emit = defineEmits(['enlarge-text'])
emit('enlarge-text');
```

### 12、props


一个对象绑定多个 props。下面的 post 是多个数据。

`<Comp v-bind="post" />`

### 13、组件 v-model

要实现组件的双向绑定，需要通过 `v-model` 对组件进行绑定。

```js
// 父组件
<CustomInput v-model='searchText' />

// 子组件
const props = defineProps(['modelValue']);
const emit = defineEmits(['update:modelValue']);
<template>
  <input :value="props.modelValue" @input="emit('update:modelValue', $event.target.value)" />
</template>
```

若希望子组件内部绑定的值可写，则可以通过 `computed` 属性。

```js
const value = computed({
  get() { return props.modelValue },
  set(value) { emit('update:modelValue', value) }
});

<template>
  <input v-model="value" />
</template>
```

默认使用 `modelValue` 当作绑定的参数名，如果希望修改名称可以使用 `v-model:title="bookTitle`，触发使用 `update:title` 来更新父组件。

并且支持多条 `v-model` 绑定，代码逻辑通同上。


