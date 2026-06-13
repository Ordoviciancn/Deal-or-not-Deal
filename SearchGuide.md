# 高级联网搜索指南

> 面向 AI Agent 的多引擎搜索策略框架

---

## 📋 概述

本文档定义了 AI Agent 在进行联网搜索时的标准化操作流程。通过多引擎协同策略，平衡搜索效率、结果质量与隐私保护需求。

---

## 🎯 核心原则

| 优先级 | 原则 | 说明 |
|--------|------|------|
| P0 | 多引擎冗余 | 单引擎失败时自动切换备选 |
| P1 | 场景适配 | 根据内容类型选择最优引擎 |
| P2 | 隐私优先 | 敏感场景使用隐私搜索引擎 |
| P3 | 结果去重 | 跨引擎结果智能去重 |

---

## 🔍 引擎矩阵

### 中文生态

| 引擎 | 适用场景 | 优先级 | 备注 |
|------|----------|--------|------|
| Baidu | 中文网页、百科 | ⭐⭐⭐ | 中文内容覆盖最全 |
| Bing CN | 微软搜索、翻译 | ⭐⭐⭐ | 结果相对客观 |
| Sogou | 微信内容、搜狗 | ⭐⭐ | 适合社交媒体内容 |
| Toutiao | 今日头条、资讯 | ⭐ | 实时新闻热点 |

### 国际生态

| 引擎 | 适用场景 | 优先级 | 备注 |
|------|----------|--------|------|
| Google | 技术文档、学术 | ⭐⭐⭐ | 索引量最大 |
| Brave | 隐私搜索 | ⭐⭐ | 无追踪 |
| DuckDuckGo | 隐私保护 | ⭐⭐ | 简洁快速 |
| Bing | 微软生态 | ⭐⭐ | 英文首选 |

### 垂直领域

| 引擎 | 领域 | 说明 |
|------|------|------|
| WolframAlpha | 知识计算 | 数学、天气、计算 |
| Stack Overflow | 技术问答 | `!so` 标记 |
| GitHub | 代码搜索 | `site:github.com` |

---

## 🔧 搜索语法

### 基础Operators

```bash
# 站内搜索
site:github.com <关键词>
site:stackoverflow.com <问题>

# 文件类型
filetype:pdf <主题>
filetype:md <主题>
filetype:doc <主题>

# 精确匹配
"<精确短语>"

# 排除词
<关键词> -<排除词>

# 组合示例
site:github.com "machine learning" filetype:pdf -tutorial
```

### 时间过滤

```bash
# 过去一周
&tbs=qdr:w

# 过去一个月
&tbs=qdr:m

# 过去一年
&tbs=qdr:y

# 自定义日期
&tbs=cdr:1,pdMax:<日期>
```

---

## 🛡️ 隐私保护

### 敏感场景识别

以下场景**必须**使用隐私搜索引擎：
- 医疗健康相关查询
- 政治敏感话题
- 个人隐私信息
- 金融敏感数据
- 法律咨询

### 推荐引擎

| 引擎 | 特点 | 总部 |
|------|------|------|
| DuckDuckGo | 无追踪记录 | 美国 |
| Startpage | Google 结果，隐私层 | 荷兰 |
| Brave | 匿名浏览 | 美国 |
| Qwant | GDPR 合规 | 法国 |

---

## 📝 调用示例

### Web Fetch

```javascript
// 中文技术搜索
web_fetch({
  "url": "https://www.baidu.com/s?wd=python+机器学习+教程"
})

// 英文学术搜索
web_fetch({
  "url": "https://scholar.google.com/scholar?q=neural+network+transformer"
})

// GitHub 代码搜索
web_fetch({
  "url": "https://github.com/search?q=react+hooks&type=code"
})

// 隐私模式搜索
web_fetch({
  "url": "https://duckduckgo.com/html/?q=隐私保护+工具"
})

// 知识计算
web_fetch({
  "url": "https://www.wolframalpha.com/input?i=微分方程+x^2+y"
})
```

---

## ⚡ 性能优化

### 搜索策略

1. **预判引擎失败**: 主要引擎超时(>5s)自动切换
2. **结果缓存**: 热门查询缓存 24 小时
3. **并发请求**: 重要场景可同时请求多引擎
4. **结果置信度**: 多引擎结果取交集提高准确率

### 速率限制

| 引擎 | 请求限制 | 建议 |
|------|----------|------|
| Google | 100/天 (未认证) | 配合代理 |
| Baidu | 1000/天 | 较宽松 |
| Bing | 100/天 | 适中 |

---

## 🔄 降级策略

当主引擎不可用时：

```
Primary: Baidu → Fallback: Sogou → Fallback: Bing CN
Primary: Google → Fallback: Brave → Fallback: DuckDuckGo
```

---

## 📌 触发规则

**必须**使用多引擎搜索的场景：

| 场景 | 示例 |
|------|------|
| 用户明确搜索 | "搜索...", "查一下..." |
| 实时资讯 | 新闻、热点事件 |
| 技术文档 | API、教程、文档 |
| 问题求解 | 报错解决、方案查找 |
| 知识查询 | 概念、定义、背景 |

---

## 📖 最佳实践

1. **先思考再搜索**: 明确搜索目标，选用最匹配引擎
2. **结果交叉验证**: 关键信息多引擎确认
3. **尊重 robots.txt**: 遵守站点爬虫协议
4. **记录搜索历史**: 避免重复搜索相同内容
5. **增量查询**: 从宽泛到精确，逐步缩小范围

---

*本文档由 OpenClaw Agent 自动维护*
*版本: 2.0 | 更新日期: 2026-03-18*
