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

**用途**：任务完成后生成执行报告 + 子会话语义验证

**功能**：
- 追踪加载了哪些 Skills
- 统计工具调用次数和执行时间
- 执行自动校验检查
- **spawn 零上下文子会话，检测意图漂移和上下文污染**
- 提出改进建议

**何时使用**：
- ✅ 建立 Skill 选择习惯
- ✅ 监控执行质量
- ✅ 调试工作流问题

**何时禁用**：
- ✅ Skill 选择已经准确
- ✅ 简单任务不需要开销
- ✅ 用户说"不用报告"

### 2. 自验证（self-verification）

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

### 3. 需求翻译官（requirement-mediator）

**用途**：任务执行后的需求符合度检查

**功能**：
- 任务执行后检查执行结果是否符合用户真实需求
- 从用户的抱怨、修正、妥协信号中推断需求偏离
- 检测隐式信号（否定、修正、妥协、迭代、沮丧）
- 发现偏离时提供修正选项

**何时使用**：
- ✅ 任务执行完成后
- ✅ 用户说"不是这样的"（否定信号）
- ✅ 用户说"算了就这样吧"（妥协信号）
- ✅ 建立"执行后检查需求符合度"的习惯

**何时禁用**：
- ✅ 简单明确的请求
- ✅ 用户说"不用检查"
- ✅ 低成本任务，迭代便宜
- ✅ 已经内化了需求理解能力

**哲学**："化繁就简" — 用 LLM 原生能力代替工程复杂度。一个 prompt，无复杂模块。后置检查而非前置澄清。

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
./install.sh --only task-execution-reporter,self-verification

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
| self-verification | 验证清单 | 文件操作后 |

## 自动校验
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

## 语义验证

Task Execution Reporter 的核心功能是**语义验证**——检测 Agent 是否因上下文污染而偏离了用户原始意图。

### 问题

当对话很长时，Agent 会被之前的操作模式锚定。例如：
- 用户说"检查一下 tree-sitter 有没有用上"
- Agent 之前一直在装 tree-sitter
- Agent 把"检查"理解为"再装一遍"而不是"验证是否生效"

这就是**上下文污染**——Agent 无法自检，因为它被困在同一个被污染的上下文中。

### 解决方案

spawn 一个**零上下文的子会话**，只接收结构化的**验证清单**（~300-500 tokens），而不是完整的对话历史：

```yaml
verification_manifest:
  original_intent: "验证 tree-sitter 是否已在项目中生效"
  task_type: "verification"
  expected_state:
    - check: "tree-sitter 配置文件存在"
      evidence_cmd: "ls .tree-sitter/config.json"
    - check: "代码中使用了 tree-sitter API"
      evidence_cmd: "grep -r 'tree_sitter' src/ | head -5"
  actual_evidence:
    - check: "tree-sitter 配置文件存在"
      output: ".tree-sitter/config.json"
      exit_code: 0
    - check: "代码中使用了 tree-sitter API"
      output: "(empty)"
      exit_code: 1
  execution_trace:
    total_calls: 12
    categories: {install: 8, configure: 2, verify: 0, search: 2}
    # ↑ verify:0 是红旗——意图是验证但零验证操作
```

子会话检查三项：
1. **意图-轨迹一致性**：task_type 是 verification 但 verify 计数为 0 → 🚩
2. **预期-证据匹配**：哪些预期状态缺少证据支持？
3. **操作模式偏差**：意图说"验证"但轨迹全是"安装" → 🚩

### 配置

```yaml
semantic_verification:
  enabled: true          # 总开关
  trigger_threshold: 5   # 触发阈值（工具调用次数）
  task_types:            # 需要语义验证的任务类型
    - verification
    - analysis
    - diagnosis
  checkpoint_mode: false # 检查点模式 vs 仅完成后验证
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
- self-verification
- requirement-mediator

**计划中的脚手架**：
- skill-recommender — 根据任务类型推荐 Skills
- progress-tracker — 追踪长任务进度
- error-pattern-detector — 识别重复错误模式

## 文档

- **[设计哲学](docs/PHILOSOPHY.md)** — 辅助轮哲学与设计原则
- **[后验证理论](docs/POST-VERIFICATION-THEORY.md)** — 语义验证、上下文污染、零上下文子会话的深度探讨

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
