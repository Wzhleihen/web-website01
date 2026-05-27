---
title: "Python 面向对象：从类到魔术方法的完整指南"
description: "四大特性、访问控制、魔术方法速查表、Mixin 模式——Python OOP 的核心知识，附和 Java 的关键差异对比。"
date: 2026-05-27
draft: false
icon: "schema"
weight: 3
tags: ["Python", "面向对象", "OOP", "魔术方法"]
---

## 什么是面向对象

面向对象是一种认识世界的方法论：把万事万物抽象为**对象**，对象是数据（属性）和行为（方法）的封装。

类（Class）是模板，对象（Object）是根据模板造出来的实体。

> 你吃鱼。"你"是人类的实例，"鱼"是鱼类的实例，"吃"是人类的方法。

---

## 基本语法

```python
class Person:
    species = "human"           # 类属性（所有实例共享）

    def __init__(self, name, age):
        self.name = name        # 实例属性（每个实例独有）
        self.age = age

    def greet(self):            # 实例方法（第一个参数必须是 self）
        return f"I'm {self.name}"

    @classmethod
    def create(cls, name):      # 类方法（操作类本身）
        return cls(name, 0)

    @staticmethod
    def info():                 # 静态方法（不依赖实例或类）
        return "Homo sapiens"

p = Person("Alice", 25)
print(p.greet())                # I'm Alice
```

---

## 四大特性

| 特性 | 说明 | Python 写法 |
|---|---|---|
| **封装** | 把属性和方法绑定在类里，隐藏内部实现 | `__private_attr`（双下划线） |
| **继承** | 子类复用父类的属性和方法 | `class Child(Parent):` |
| **多态** | 同一方法在不同子类有不同实现 | 重写父类方法（override） |
| **抽象** | 提取共同特征，忽略不相关细节 | `from abc import ABC, abstractmethod` |

---

## 访问控制

```python
class Example:
    def __init__(self):
        self.public = "公开"          # 外部可直接访问
        self._protected = "保护"      # 约定内部使用，外部可访问但不推荐
        self.__private = "私有"       # 名称改写，外部需用 _Example__private 访问
```

Python 没有真正的私有，`__name` 只是被改写成 `_ClassName__name`，是约定而非强制。

---

## 魔术方法（Dunder Methods）

魔术方法让自定义类支持 Python 内置操作，是 OOP 最有意思的部分：

| 方法 | 触发时机 | 示例 |
|---|---|---|
| `__init__` | 实例化 `Person("Alice")` | 初始化属性 |
| `__str__` | `str(obj)` / `print(obj)` | 返回可读字符串 |
| `__repr__` | 调试显示 / `repr(obj)` | 返回开发者可读字符串 |
| `__len__` | `len(obj)` | 自定义长度 |
| `__eq__` | `obj1 == obj2` | 自定义相等逻辑 |
| `__hash__` | `hash(obj)` | 使对象可放入 set/dict |
| `__enter__` / `__exit__` | `with obj:` | 上下文管理器 |
| `__iter__` / `__next__` | `for x in obj:` | 使对象可迭代 |
| `__getitem__` | `obj[key]` | 支持下标访问 |
| `__add__` | `obj1 + obj2` | 运算符重载 |

**实际例子**：让自定义类支持 `with` 语句

```python
class DatabaseConnection:
    def __enter__(self):
        print("打开数据库连接")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("关闭数据库连接")
        return False    # 不压制异常

with DatabaseConnection() as db:
    print("执行查询")
# 输出：
# 打开数据库连接
# 执行查询
# 关闭数据库连接
```

---

## 继承与 Mixin 模式

```python
class Animal:
    def eat(self): print("eating")

class Flyable:          # Mixin：只提供一种能力
    def fly(self): print("flying")

class Swimmable:        # Mixin：只提供一种能力
    def swim(self): print("swimming")

class Duck(Animal, Flyable, Swimmable):     # 组合多种能力
    pass

duck = Duck()
duck.eat()    # eating
duck.fly()    # flying
duck.swim()   # swimming
```

**Mixin 的价值**：避免深层继承树，每个 Mixin 只做一件事，组合比继承更灵活。

SQLAlchemy 的模型、Flask 的 `MethodView` 都大量使用 Mixin 模式。

---

## 和 Java 的关键差异

| 特性 | Python | Java |
|---|---|---|
| 多继承 | ✅ 支持（MRO 解决冲突） | ❌ 不支持（用 interface 代替） |
| 访问控制 | 约定（`_` / `__`） | 强制（`private` / `protected`） |
| 抽象类 | `ABC` + `@abstractmethod` | `abstract class` |
| 接口 | 无原生接口，用 ABC 模拟 | `interface` 关键字 |
| 构造函数 | `__init__` | 与类同名方法 |

---

## SQLAlchemy 模型就是 OOP 的直接应用

```python
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):               # 继承 db.Model
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80))

    def __repr__(self):             # 魔术方法
        return f'<User {self.name}>'
```

理解了 OOP，SQLAlchemy 的模型定义就不再是"记语法"，而是"用 OOP 描述数据表"。
