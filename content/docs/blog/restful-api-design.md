---
title: "RESTful API 设计规范：URL、HTTP 方法和状态码的正确用法"
description: "Roy Fielding 提出的 REST 核心理念、HTTP 方法语义、URL 命名规范、常用状态码，以及用 VS Code REST Client 测试接口的实用方法。"
date: 2026-05-27
draft: false
icon: "api"
weight: 4
tags: ["API", "REST", "HTTP", "Flask", "后端开发"]
---

## REST 是什么

REST（Representational State Transfer）是 Roy Fielding 在 2000 年博士论文中提出的 Web 架构风格，不是协议，不是标准，是一套**设计约定**。

遵循 REST 约定设计的接口叫 RESTful API。

核心思想很简单：**把系统里的一切抽象成"资源"，用 URL 标识资源，用 HTTP 方法表达对资源的操作。**

---

## 四个核心概念

| 概念 | 说明 |
|---|---|
| **资源（Resource）** | 系统中的实体——用户、订单、文章，每个资源有唯一 URL |
| **表现（Representation）** | 资源的数据格式，通常是 JSON |
| **状态转移（State Transfer）** | 客户端通过 HTTP 方法改变服务器上资源的状态 |
| **无状态** | 每个请求自带所有必要信息，服务器不记录会话 |

---

## HTTP 方法的正确语义

| 方法 | 语义 | 幂等 | 说明 |
|---|---|---|---|
| `GET` | 获取资源 | ✅ | 只读，不修改数据 |
| `POST` | 创建资源 | ❌ | 每次调用都会新建 |
| `PUT` | 全量更新 | ✅ | 替换整个资源 |
| `PATCH` | 部分更新 | ✅ | 只更新指定字段 |
| `DELETE` | 删除资源 | ✅ | 幂等——删两次和删一次结果一样 |

**幂等**的意思：同样的请求执行多次，结果和执行一次相同。网络超时重试时幂等接口是安全的。

---

## URL 设计：名词 + 复数 + 层级

```
✅ 推荐写法（名词复数，层级清晰）

GET    /users              获取用户列表
POST   /users              创建用户
GET    /users/123          获取 ID=123 的用户
PUT    /users/123          全量更新用户 123
PATCH  /users/123          部分更新用户 123
DELETE /users/123          删除用户 123
GET    /users/123/orders   获取用户 123 的订单列表

❌ 不推荐写法（动词，不 RESTful）

GET  /getUsers
POST /createUser
GET  /getUserById?id=123
POST /deleteUser/123
```

**判断标准**：URL 是名词还是动词？URL 代表"资源"，动作由 HTTP 方法表达，不要把动词塞进 URL。

---

## 状态码速查

| 状态码 | 含义 | 使用场景 |
|---|---|---|
| **200** | OK | 请求成功（GET/PUT/PATCH/DELETE） |
| **201** | Created | 创建成功（POST） |
| **204** | No Content | 成功但无返回体（DELETE） |
| **400** | Bad Request | 请求参数错误 |
| **401** | Unauthorized | 未登录 / Token 无效 |
| **403** | Forbidden | 已登录但无权限 |
| **404** | Not Found | 资源不存在 |
| **409** | Conflict | 资源冲突（如用户名已存在） |
| **500** | Internal Server Error | 服务器内部错误 |

**401 vs 403 的区别**：401 是"你是谁我不知道"，403 是"我知道你是谁，但你没权限"。

---

## Flask 实现示例

```python
from flask import Flask, jsonify, request

app = Flask(__name__)

users = {}

@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(list(users.values())), 200

@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user_id = len(users) + 1
    users[user_id] = {'id': user_id, 'name': data['name']}
    return jsonify(users[user_id]), 201     # 创建成功返回 201

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = users.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    return jsonify(user), 200

@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    users.pop(user_id, None)
    return '', 204      # 删除成功，无返回体
```

---

## 用 VS Code REST Client 测试

安装 VS Code 插件 **REST Client**，新建 `test.http` 文件：

```http
### 获取用户列表
GET http://localhost:5000/users
Accept: application/json

###

### 创建用户
POST http://localhost:5000/users
Content-Type: application/json

{
    "name": "Alice"
}

###

### 获取单个用户
GET http://localhost:5000/users/1

###

### 删除用户
DELETE http://localhost:5000/users/1
```

点击每个 `###` 上方的 **Send Request**，直接在编辑器里看响应——比 Postman 轻量，适合日常开发时快速验证接口。

---

## 总结

RESTful API 设计的三条核心原则：

1. **URL 是名词复数**，代表资源，不包含动词
2. **HTTP 方法表达操作**，GET/POST/PUT/PATCH/DELETE 各有语义
3. **状态码有意义**，201 ≠ 200，403 ≠ 401，不要全部返回 200
