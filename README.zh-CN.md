# Agent Scaffold

> LLM Agent 的辅助轮 — 需要时装上，内化后拆掉。

## 这是什么？

Agent Scaffold 是一套 **可选的训练辅助工具**，适用于 LLM Agent（Hermes、OpenClaw 等）。与知识库教"怎么做"不同，脚手架提供的是**机制**，帮助 Agent 建立好习惯：

- **统计** — 追踪使用了哪些 Skills
- **校验** — 检查输出是否符合标准
- **反馈** — 生成报告供人工审核

目标很简单：**帮助 Agent 内化良好实践，然后功成身退。**

## 理念

```
新手 → 装上辅助轮 → 建立习惯 → 内化 → 拆掉辅助轮 → 成熟
```

脚手架**不是强制规则**，而是可选辅助：
- 帮助新手建立良好工作流
- 提供 Agent 行为的可见性
- 习惯养成后可禁用
- 激活时会增加开销（token 消耗）

## 包含的脚手架

### 1. 任务执行报告器（task-execution-reporter）

**用途**：任务完成后生成执行报告

**功能**：
- 追踪加载了哪些 Skills
- 统计工具调用次数和执行时间
- 执行自动校验检查
- 提出改进建议

**何时使用**：
- ✅ 建立 Skill 选择习惯
- ✅ 监控执行质量
- ✅ 调试工作流问题

**何时禁用**：
- ✅ Skill 选择已经准确
- ✅ 简单任务不需要开销
- ✅ 用户说"不用报告"

### 2. 纯净输出（pure-output）

**用途**：消除 AI 腔调，提升 token 效率

**功能**：
- 禁止填充词（"好的！""我很乐意..."）
- 强制直接、简洁的沟通
- 推广主动语态和短句

**何时使用**：
- ✅ 写长文档
- ✅ 用户反馈"太啰嗦"
- ✅ 发现自己在用模板句式

**何时禁用**：
- ✅ 输出风格已经内化
- ✅ 日常对话不需要

### 3. 自验证（self-verification）

**用途**：确保输出真的正确

**功能**：
- 文件操作 → read 回来验证
- 命令执行 → 检查 exit code
- 数据处理 → 抽样验证
- 配置变更 → 立即验证

**何时使用**：
- ✅ 文件操作后
- ✅ 重要命令后
- ✅ 批量数据处理后

**何时禁用**：
- ✅ 验证习惯已经养成
- ✅ 简单操作不需要

## 安装

```bash
git clone https://github.com/JingWang-Star996/agent-scaffold.git
cd agent-scaffold
./install.sh
```

**选项**：

```bash
# 只安装到 Hermes
./install.sh --hermes

# 只安装到 OpenClaw
./install.sh --openclaw

# 安装所有脚手架（默认）
./install.sh

# 只安装特定脚手架
./install.sh --only task-execution-reporter,pure-output

# 自动检测并安装
./install.sh
```

## 使用

安装后，脚手架作为 Skills 可用：

**Hermes**：
```
/skill task-execution-reporter
```

**OpenClaw**：
```
Load skill: task-execution-reporter
```

脚手架根据触发条件自动激活。详见各脚手架文档。

## 禁用脚手架

脚手架是可选的。不再需要时可以禁用：

**临时**（当前会话）：
- 不加载脚手架 Skill

**永久**：
```bash
# Hermes
rm -rf ~/.hermes/skills/task-execution-reporter

# OpenClaw
rm -rf ~/.openclaw/skills/task-execution-reporter
```

或使用卸载脚本：
```bash
./uninstall.sh
```

## 工作原理

### 任务执行报告器流程

```
任务完成
    ↓
自动收集数据
  - 工具调用次数
  - 加载的 Skills
  - 执行时间
    ↓
执行校验检查
  - 输出风格（pure-output）
  - 验证步骤（self-verification）
  - 进度汇报
  - Skill 完整性
    ↓
生成报告
  - 任务概览
  - Skill 统计
  - 校验结果
  - 改进建议
    ↓
人工审核
  - 确认质量
  - 发现遗漏
  - 提供反馈
    ↓
持续改进
  - 更新 Skill 映射
  - 优化工作流
```

### 报告示例

```
📊 任务执行报告
═══════════════════════════════════════

## 任务概览
- 类型：代码重构
- 耗时：45 秒
- 工具调用：8 次
- Token 消耗：~12,000

## 加载的 Skills
| Skill | 用途 | 时机 |
|-------|------|------|
| pure-output | 输出风格 | 开始时 |
| self-verification | 验证清单 | 文件操作后 |

## 自动校验
- [✅] 输出风格：无 AI 腔调
- [✅] 验证执行：read 回来 3 个文件
- [✅] 进度汇报：中间汇报 2 次
- [✅] 交付完整：有明确交付物

## 待人工确认
- 是否遗漏了 architecture-decision-records？
- 代码质量是否符合预期？
- 是否需要补充单元测试？

## 改进建议
- 下次重构任务建议先加载 architecture-decision-records
- 考虑添加测试覆盖率检查
```

## 对比：ECC vs Scaffold

| 维度 | ECC | Agent Scaffold |
|------|-----|----------------|
| **本质** | 知识（最佳实践） | 机制（统计、校验） |
| **回答** | "怎么做" | "有没有做到" |
| **来源** | 从 Claude Code 移植 | 为 Hermes/OpenClaw 原创 |
| **依赖** | 依赖 ECC 仓库 | 独立 |
| **范围** | ECC skill 用户 | 所有 Agent 用户 |

**两者互补**：
- ECC = 做什么（知识）
- Scaffold = 有没有做（机制）
- 两者结合 = 完整训练系统

## 项目状态

**当前脚手架**：3 个
- task-execution-reporter
- pure-output
- self-verification

**计划中的脚手架**：
- skill-recommender — 根据任务类型推荐 Skills
- progress-tracker — 追踪长任务进度
- error-pattern-detector — 识别重复错误模式

## 贡献

欢迎贡献！改进方向：
- 添加更多脚手架
- 改进校验规则
- 添加语言特定的脚手架
- 翻译文档

## 许可证

MIT

## 致谢

- 灵感来自 Hermes/OpenClaw 社区对 **Agent 训练辅助** 的需求
- 基于 **LLM 是概率性的** 这一原理，需要脚手架而非仅仅规则
- 设计为**可选且可移除** — 目标是最终不再需要它们

---

**AI 时代的辅助轮** 🚲
