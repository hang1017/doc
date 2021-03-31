# Array.from()

**Array.from()方法就是将一个类数组对象或者可遍历对象转换成一个真正的数组。**

什么是类数组对象：具有 `length` 属性的对象。

## 若 `Array.from` 参数为类数组对象

将类数组对象转换成真正的数组必须具备一下条件：

- 该类数组对象必须具有 `length` 属性。如果没有，则会返回一个空数组。
- 该类数组的对象的 `key` 必须为数值型或者字符串型的数字。数组元素均为 `undefind`

例子：

```js
let array = {
  0: 'tom', 
  1: '65',
  2: '男',
  3: ['jane','john','Mary'],
}

console.log(Array.from(array)); // []

array.length = 4;

console.log(Array.from(array)); // ['tom','65','男',['jane','john','Mary']]

array.length = 5;
array.name = 'name';

console.log(Array.from(array)); // ['tom','65','男',['jane','john','Mary'], undefind]
```

## 若 `Array.from` 参数为字符串

```js
let  str = 'hello world!';
console.log(Array.from(str)) // ["h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d", "!"]
```

## 若 `Array.from` 存在两个参数

第二个参数为 `fun` 类型，可遍历每个元素，并对每个元素进行处理，将处理过的值放入返回的数组。

```js
let arr = [12,45,97,9797,564,134,45642]
let set = new Set(arr)
console.log(Array.from(set, item => item + 1)) // [ 13, 46, 98, 9798, 565, 135, 45643 ]
```




