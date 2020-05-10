# MongoDb

## 安装

在 mac 上的下载安装流程，可以直接参考[菜鸟教程](https://www.runoob.com/mongodb/mongodb-osx-install.html)


## 连接数据库

基础操作：`mongodb://admin:123456@localhost/`

如需更多连接操作请查看[菜鸟官网](https://www.runoob.com/mongodb/mongodb-connections.html)

## 数据库操作

```bash
sudo mkdir -p /data/db

sudo mongod

$ cd /usr/local/mongodb/bin 
$ ./mongo
```

`show dbs` 命令可以显示所有数据的列表。

`db` 命令可以显示当前数据库对象或集合。

`use ～` 可以连接到一个指定的数据库。

几个数据库是保留的：

- admin: `root` 数据库，要是将一个用户添加到这个数据库，该用户自动继承所有数据库的权限，
- local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合
- config: 当 Mongo 用于分片设置时，config数据库在内部使用，用于保存分片的相关信息

### 一、创建数据库

`use ~`: 用来创建数据库，如果数据库存在，则切换到指定的数据库。

当我们创建了新的数据库时，用 `show dbs` 命令并不能查看到该数据库，要显示它，我们需要新增一些数据。

### 二、删除数据库

`db.dropDatabase()`: 删除数据库命令，删除当前数据库，可以使用 `db` 查看当前数据库。

删除集合的操作：

```bash
use hangdb

# 创建集合，类似数据库中的表
db.createCollection("hangTable1")

# 查看当前数据库下有多少集合
show tables

# 删除集合操作
db.hangTable1.drop()
```

### 三、创建集合

`db.createCollection(name, options)` - 后面接集合名称和可选参数

`options`: 可选参数如下：

- capped：为 `true` 时创建固定集合，当达到最大值，会自动覆盖最早的文档，必须指定 `size` 参数。
- autoIndexId：自动在 `_id` 字段创建索引，默认为 `false`
- size：为固定集合指定一个最大值，以千字节计(KB)
- max： 固定集合中，包含文档的最大数量。

查看已有集合：`show collections` 或者 `show tables`

实例：

```bash
db.createCollection("hangdb", { capped: true, autoIndexed: true, size: 6142800, max: 10000 })
```

在 mongodb 中，不需要创建集合，当你新增文档时，就会自动创建集合

```bash
db.hangdb.insert({ "name" : "this is test" })
```

### 四、删除集合

`db.collection.drop()`

### 五、插入文档

```bash
# 进行文档的插入操作
db.col.insert({})

# 查询集合内容
db.col.find() 

document=({})
db.col.insert(document)
```

### 六、更新文档

``bash
db.collection.update(
  <query>,
  <update>,
  {
    upsert: <boolean>,
    multi: <boolean>,
    writeConcern: <document>
  }
)
```

```bash
db.col.insert({ "name": "hanghang" })

# 更新操作，只修改发现的第一条数据
db.col.update({'name': 'hanghang'}, {$set:{"name" : "hanghang1"}})

# 更新操作，修改发现的全部数据
db.col.update({'name': 'hanghang'}, {$set:{"name" : "hanghang1"}},{multi:true})
```

### 七、删除文档

```bash
db.collection.remove(
  <query>,
  {
    justOne: <boolean>,
    writeConcern: <document>
  }
)
```

- `justOne` : （可选）如果设为 true 或 1，则只删除一个文档，如果不设置该参数，或使用默认值 false，则删除所有匹配条件的文档

```bash
db.col.remove({'name': 'hanghang1'})

# 删除发现的第一条数据
db.col.remove({'name': 'hanghang1'}, { `justOne`: true or 1 })
```

### 查询文档

```bash
db.collection.find(query, projection)
```

- query: 可选，使用查询操作符指定查询条件
- projection: 可选，使用投影操作符指定返回的键。查询时返回文档中所有键值， 只需省略该参数即可（默认省略）

**查询条件**

|操作|格式|范例|类似语言|
|--|--|--|--|
|等于|{<key>:<value>}|db.col.find({"by":"菜鸟教程"}).pretty()|where by = '菜鸟教程'|
|小于|{<key>:{$lt:<value>}}|db.col.find({"likes":{$lt:50}}).pretty()|where likes < 50|
|小于或等于|{<key>:{$lte:<value>}}|db.col.find({"likes":{$lte:50}}).pretty()|where likes <= 50|
|大于|{<key>:{$gt:<value>}}|db.col.find({"likes":{$gt:50}}).pretty()|where likes > 50|
|大于或等于|{<key>:{$gte:<value>}}|db.col.find({"likes":{$gte:50}}).pretty()|where likes >= 50|
|不等于|{<key>:{$ne:<value>}}|db.col.find({"likes":{$ne:50}}).pretty()|where likes != 50|


**and 条件**

```bash
db.col.find({key1:value1, key2:value2}).pretty()
```

**or 条件**

```bash
db.col.find({$or: [{"by":"菜鸟教程"}, {"title": "MongoDB 教程"}]}).pretty()
```

**$type**

```bash
db.col.find({"title" : {$type : 2}})
或
db.col.find({"title" : {$type : 'string'}})
```

**limit 和 skip的方法**

使用方法：

```bash
db.collection.find().limit(number)

db.col.find({},{'title': 1}).limit(2).skip(1)
```

`limit` 用来读取指定数量的数据，`skip` 用来跳过指定数量的数据。

**排序**

`sort()` 来对数据进行排序，使用 `1` 和 `-1` 来指定排序的方式，`1` 为升序，`-1` 为降序

```bash
# title: 为按某个字段进行顺序的排列
db.col.find().sort({'title': 1})
```

**索引**

索引是特殊的数据结构，索引存储在一个易于遍历读取的数据集合中，索引是对数据库表中一列或多列的值进行排序的一种结构

```bash
db.col.createIndex({"title":1,"description":-1}, {"background": true})
```

若设置 `background` 则让创建工作在后台执行。

**聚合**

用于数据的处理。返回计算后的数据结果

`db.COLLECTION_NAME.aggregate(AGGREGATE_OPERATION)`

```bash
db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : 1}}}])

select by_user, count(*) from mycol group by by_user
```

需要其他操作请查看[菜鸟官网](https://www.runoob.com/mongodb/mongodb-aggregate.html)









