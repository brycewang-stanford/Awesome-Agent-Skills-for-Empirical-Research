# 分支管理策略详解

## 分支类型

| 分支类型 | 命名规范          | 说明                       | 生命周期       |
| :------- | :---------------- | :------------------------- | :------------- |
| master   | `master`          | 主分支，始终保持可发布状态 | 永久           |
| develop  | `develop`         | 开发分支，集成最新开发代码 | 永久           |
| feature  | `feature/功能名`  | 功能分支                   | 开发完成后删除 |
| bugfix   | `bugfix/问题描述` | Bug修复分支                | 修复完成后删除 |
| hotfix   | `hotfix/问题描述` | 紧急修复分支               | 修复完成后删除 |
| release  | `release/版本号`  | 发布分支                   | 发布完成后删除 |

## 分支命名规范

### 功能分支

```
feature/user-management          # ✅ 用户管理功能
feature/123-add-export          # ✅ 关联Issue的功能
```

### Bug修复分支

```
bugfix/login-error              # ✅ 登录错误修复
bugfix/456-fix-timeout          # ✅ 关联Issue的修复
```

### 紧急修复分支

```
hotfix/security-vulnerability   # ✅ 安全漏洞修复
hotfix/v1.0.1                   # ✅ 版本号修复
```

### 发布分支

```
release/v1.0.0                  # ✅ 版本发布
release/v2.0.0-beta.1           # ✅ 预发布版本
```

## 分支保护规则

### master 分支

- 禁止直接推送
- 必须通过 Pull Request 合并
- 必须通过 CI 检查
- 必须至少一人 Code Review

### develop 分支

- 限制直接推送
- 建议通过 Pull Request 合并
- 必须通过 CI 检查

## 分支操作命令

### 创建功能分支

```bash
git checkout develop
git pull origin develop
git checkout -b feature/user-management
```

### 创建Bug修复分支

```bash
git checkout develop
git pull origin develop
git checkout -b bugfix/login-error
```

### 创建紧急修复分支（从master创建）

```bash
git checkout master
git pull origin master
git checkout -b hotfix/security-fix
```

### 删除分支

```bash
git branch -d feature/user-management     # 删除本地分支
git push origin -d feature/user-management # 删除远程分支
```

## 工作流程详解

### 日常开发流程

```bash
# 1. 同步最新代码
git checkout develop
git pull origin develop

# 2. 创建功能分支
git checkout -b feature/user-management

# 3. 开发并提交
git add .
git commit -m "feat(user): 添加用户列表页面"

# 4. 推送到远程
git push -u origin feature/user-management

# 5. 创建 Pull Request 并请求 Code Review

# 6. 合并到 develop（通过 PR）

# 7. 删除功能分支
git branch -d feature/user-management
git push origin -d feature/user-management
```

### 紧急修复流程

```bash
# 1. 从 master 创建修复分支
git checkout master
git pull origin master
git checkout -b hotfix/critical-bug

# 2. 修复并提交
git add .
git commit -m "fix(auth): 修复认证绕过漏洞"

# 3. 合并到 master
git checkout master
git merge --no-ff hotfix/critical-bug
git tag -a v1.0.1 -m "hotfix: 修复认证绕过漏洞"
git push origin master --tags

# 4. 同步到 develop
git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop

# 5. 删除修复分支
git branch -d hotfix/critical-bug
```

### 版本发布流程

```bash
# 1. 创建发布分支
git checkout develop
git checkout -b release/v1.0.0

# 2. 更新版本号和文档
# 修改 package.json 版本号
# 更新 CHANGELOG.md

# 3. 提交版本更新
git add .
git commit -m "chore(release): 准备发布 v1.0.0"

# 4. 合并到 master
git checkout master
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "release: v1.0.0 正式版本"
git push origin master --tags

# 5. 同步到 develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# 6. 删除发布分支
git branch -d release/v1.0.0
```
