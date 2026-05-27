---
title: "Python 装饰器：从原理到 Flask 路由的完整拆解"
description: "彻底搞懂装饰器的核心原理、functools.wraps 的必要性、带参数装饰器的写法，以及它在 Flask 路由中的实际应用。"
date: 2026-05-27
draft: false
icon: "auto_fix_high"
weight: 2
tags: ["Python", "装饰器", "Flask", "高阶函数"]
---

## 一句话先说清楚

装饰器是**接受函数作为参数、返回新函数的高阶函数**，用于在不修改原函数代码的前提下扩展其行为。

`@my_decorator` 这个语法糖，等价于 `func = my_decorator(func)`，就这一句话，其他的都是它的推论。

---

## 核心原理

装饰器依赖 Python 函数的两个特性：

1. **函数是一等公民**：函数可以作为参数传递、作为返回值返回
2. **闭包**：内部函数能捕获并记住外部函数的变量

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("执行前")
        result = func(*args, **kwargs)   # 调用原函数
        print("执行后")
        return result
    return wrapper

@my_decorator           # 等价于 say_hello = my_decorator(say_hello)
def say_hello():
    print("Hello!")

say_hello()
# 输出：
# 执行前
# Hello!
# 执行后
```

---

## 为什么必须加 @wraps

这是一个容易忽略但很重要的细节。装饰器会**悄悄替换原函数的身份信息**：

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def say_hello():
    """这是 say_hello 函数"""
    pass

print(say_hello.__name__)   # 输出：wrapper  ← 不是 say_hello！
print(say_hello.__doc__)    # 输出：None      ← 文档丢了！
```

Flask 路由就因为这个问题会出现 `AssertionError: View function mapping is overwriting an existing endpoint function`——两个路由被装饰后 `__name__` 都变成了 `wrapper`，Flask 认为是重名冲突。

**解决：始终加 `@functools.wraps`**：

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)        # 把原函数的 __name__、__doc__ 等复制过来
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def say_hello():
    """这是 say_hello 函数"""
    pass

print(say_hello.__name__)   # 输出：say_hello  ← 正确
print(say_hello.__doc__)    # 输出：这是 say_hello 函数  ← 正确
```

---

## 带参数的装饰器

有时候需要给装饰器传参数，比如 `@repeat(3)`。这需要多套一层函数：

```python
def repeat(n):              # 第一层：接收装饰器参数
    def decorator(func):    # 第二层：接收被装饰的函数
        @wraps(func)
        def wrapper(*args, **kwargs):   # 第三层：实际执行逻辑
            for _ in range(n):
                func(*args, **kwargs)
        return wrapper
    return decorator

@repeat(3)
def hello():
    print("Hi")

hello()
# 输出：Hi Hi Hi
```

记忆方式：**参数几层，函数就几层加一**。

---

## Flask 路由就是装饰器

理解了装饰器，Flask 路由就完全透明了：

```python
@app.route('/hello')
def hello():
    return 'Hello World'

# 等价于：
def hello():
    return 'Hello World'
hello = app.route('/hello')(hello)
```

`app.route('/hello')` 返回一个装饰器，这个装饰器把 `hello` 函数注册到 Flask 的 URL 映射表里，同时返回原函数。

所以 Flask 路由叠加时，顺序很重要——`@app.route` 要写在最外层（最靠近 `def`），否则 Flask 拿到的不是原始函数。

---

## 常见应用场景

| 场景 | 例子 |
|---|---|
| 路由注册 | `@app.route('/')` |
| 权限校验 | `@login_required` |
| 日志记录 | 函数调用前后自动写日志 |
| 性能计时 | 测量执行耗时 |
| 缓存 | `@functools.lru_cache(maxsize=128)` |
| 重试机制 | 网络请求失败自动重试 |

---

## 总结

| 知识点 | 核心记忆 |
|---|---|
| 装饰器本质 | `func = decorator(func)`，语法糖而已 |
| 必须加 `@wraps` | 否则函数身份信息丢失，Flask 会报错 |
| 带参数装饰器 | 多套一层函数 |
| Flask 路由 | 就是装饰器，`@app.route` 在最外层 |
