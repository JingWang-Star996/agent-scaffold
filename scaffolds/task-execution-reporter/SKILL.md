---
name: task-execution-reporter
description: |
  [脚手架/辅助轮] 任务执行后自动生成报告，统计调用的 Skills、执行时间、Token 消耗，并进行自动校验。
  这是 LLM Agent 养成过程中的辅助工具——有需要时装上，用得上时保留，内化后拆掉。
  不是强制规则，是可选的养成辅助。
version: 1.1.0
author: Hermes
tags: [scaffold, reporting, verification, skill-tracking, optional]
---

# 任务执行报告系统（脚手架）

> **定位**：这是 LLM Agent 养成过程中的脚手架/辅助轮。
> - 新手期：装上，帮助建立习惯
> - 成熟期：内化后拆掉，减少开销
> - 可随时启用/禁用，不是强制规则

任务完成后自动生成执行报告，包含 Skill 调用统计、自动校验、待人工确认项。

## 何时使用

**启用场景**：
- 刚开始使用 Hermes，需要建立 Skill 调用习惯
- 想要监控自己的执行质量
- 需要数据来改进工作流
- 用户要求生成执行报告

**禁用场景**：
- 已经内化了输出风格、验证习惯
- Skill 选择已经准确，不需要提醒
- 简单任务，不需要报告开销
- 用户说"不用报告"

**触发条件**（启用后）：
- 用户明确说"完成"、"好了"、"结束"
- 任务交付物已生成（文件、代码、文档等）
- 连续 3 次以上工具调用后
- 任务执行时间 > 30 秒

## 报告格式

```
📊 任务执行报告
═══════════════════════════════════════

## 任务概览
- 任务类型：[代码重构/数据处理/文档编写/...]
- 执行时间：[X 秒]
- 工具调用：[N 次]
- Token 消耗：[预估]

## 调用的 Skills
| Skill | 用途 | 加载时机 |
|-------|------|---------|
| pure-output | 输出风格控制 | 任务开始时 |
| self-verification | 验证清单 | 文件操作后 |
| ... | ... | ... |

## 自动校验
- [✅/❌] 输出风格：无 AI 腔调
- [✅/❌] 验证执行：文件操作后 read 回来
- [✅/❌] 进度汇报：长任务有中间汇报
- [✅/❌] 交付完整：有明确交付物

## 待人工确认
- 是否遗漏了 [某 Skill]？（基于任务类型推断）
- 输出质量是否符合预期？
- 流程是否需要改进？

## 改进建议
- [基于本次执行的具体建议]
```

## 自动校验规则

### 1. 输出风格校验（pure-output）
```
检查项：
- 是否有"好的""我来帮您"等 AI 腔调
- 是否有"首先...其次...最后..."模板
- 是否有"需要注意的是"等填充词
- 是否主动语态、短句

通过条件：无上述模式
```

### 2. 验证执行校验（self-verification）
```
检查项：
- 文件操作后是否 read 回来
- 命令执行后是否检查 exit code
- 数据处理后是否抽样验证
- 配置变更后是否验证生效

通过条件：有验证步骤记录
```

### 3. 进度汇报校验（diting-auto-trigger）
```
检查项：
- 长任务（>30s）是否有中间汇报
- 多步骤任务是否分段汇报
- 遇到问题是否立即汇报

通过条件：有汇报记录
```

### 4. Skill 调用完整性
```
检查项：
- 任务类型对应的核心 Skill 是否加载
- 是否有"该加载但没加载"的情况

任务类型 → Skill 映射：
- 代码重构 → pure-output, self-verification, requesting-code-review
- 数据处理 → self-verification, diting-auto-trigger
- 文档编写 → pure-output, self-verification
- 架构设计 → architecture-decision-records, writing-plans
- 故障诊断 → systematic-debugging, diting-auto-trigger
- 配置变更 → self-verification

通过条件：核心 Skill 已加载
```

## 报告生成流程

```
任务完成
    ↓
1. 收集执行数据
   - 工具调用次数
   - 调用的 Skills 列表
   - 执行时间
   - 关键步骤记录
    ↓
2. 执行自动校验
   - 输出风格检查
   - 验证执行检查
   - 进度汇报检查
   - Skill 完整性检查
    ↓
3. 生成报告
   - 任务概览
   - Skill 调用统计
   - 自动校验结果
   - 待人工确认项
   - 改进建议
    ↓
4. 输出报告
   - 简洁格式（适合聊天）
   - 或详细格式（适合复盘）
```

## 示例报告

### 示例 1：代码重构任务

```
📊 任务执行报告
═══════════════════════════════════════

## 任务概览
- 任务类型：代码重构
- 执行时间：45 秒
- 工具调用：8 次
- Token 消耗：~12,000

## 调用的 Skills
| Skill | 用途 | 加载时机 |
|-------|------|---------|
| pure-output | 输出风格控制 | 任务开始时 |
| self-verification | 验证清单 | 文件操作后 |
| requesting-code-review | 代码审查流程 | 重构完成后 |

## 自动校验
- [✅] 输出风格：无 AI 腔调
- [✅] 验证执行：3 次文件操作后均 read 回来
- [✅] 进度汇报：中间汇报了 2 次进度
- [✅] 交付完整：重构后的代码 + 变更说明

## 待人工确认
- 是否遗漏了 architecture-decision-records？（重构涉及架构决策）
- 代码质量是否符合预期？
- 是否需要补充单元测试？

## 改进建议
- 下次重构任务建议先加载 architecture-decision-records
- 考虑添加测试覆盖率检查
```

### 示例 2：数据处理任务

```
📊 任务执行报告
═══════════════════════════════════════

## 任务概览
- 任务类型：数据处理
- 执行时间：120 秒
- 工具调用：15 次
- Token 消耗：~25,000

## 调用的 Skills
| Skill | 用途 | 加载时机 |
|-------|------|---------|
| self-verification | 验证清单 | 数据处理后 |
| diting-auto-trigger | 质量检查 | 任务完成后 |

## 自动校验
- [✅] 输出风格：简洁，无填充
- [✅] 验证执行：抽样验证了 10% 数据
- [✅] 进度汇报：每 30 秒汇报一次
- [✅] 交付完整：处理后的数据 + 统计报告

## 待人工确认
- 数据处理逻辑是否正确？
- 是否需要更详细的统计？
- 是否需要可视化图表？

## 改进建议
- 考虑添加数据质量检查步骤
- 大数据量时考虑使用脚本批量处理
```

## 报告存储

**短期**：每次任务后直接输出到聊天

**长期**（可选）：
- 存储到 `~/.hermes/task-reports/YYYY-MM-DD-HH-MM-SS.md`
- 定期汇总分析，发现模式
- 用于持续改进 Skill 推荐

## 与现有系统的集成

### 与 diting-auto-trigger 的关系
- diting-auto-trigger：质量检查（规则合规性）
- task-execution-reporter：执行报告（统计 + 校验）
- 两者互补，可以合并输出

### 与 memory 的关系
- 重要经验记录到 memory
- 执行报告不记录（临时数据）
- 但报告中的改进建议可以触发 memory 更新

## 语义验证（Semantic Verification）

> **解决的问题**：上下文污染导致 Agent 无法正确自检。
> 当对话历史很长时，Agent 容易被之前的操作模式锚定，无法客观判断"目标是否真正达成"。

### 核心思路

不在被污染的对话中自检，而是 **spawn 子会话** 进行独立验证。

子会话零上下文 = 没有操作惯性，只看证据指纹。

### Verification Manifest（验证清单）

主会话在检查点生成结构化清单，传给子会话。不是传对话历史（太大会 token 超标），而是传**证据指纹**：

```yaml
verification_manifest:
  # 1. 原始意图（一句话，从用户消息提取）
  original_intent: "验证 tree-sitter 是否已在项目中生效"
  task_type: "verification"  # installation | verification | configuration | creation | analysis
  
  # 2. 预期状态（什么算完成）
  expected_state:
    - check: "tree-sitter 配置文件存在"
      evidence_cmd: "ls .tree-sitter/config.json"
      expect: "file exists"
    - check: "代码中使用了 tree-sitter API"
      evidence_cmd: "grep -r 'tree_sitter' src/ | head -5"
      expect: "有匹配结果"
  
  # 3. 实际证据（主会话执行后采集，只保留关键输出）
  actual_evidence:
    - check: "tree-sitter 配置文件存在"
      output: ".tree-sitter/config.json"
      exit_code: 0
    - check: "代码中使用了 tree-sitter API"
      output: "(empty)"
      exit_code: 1
  
  # 4. 执行轨迹摘要（语义指纹）
  execution_trace:
    total_calls: 12
    categories: {install: 8, configure: 2, verify: 0, search: 2}
    # ↑ verify:0 本身就是红旗——意图是验证但零验证操作
```

### 子会话验证逻辑

子会话拿到 manifest（~300-500 tokens）后检查三项：

1. **意图-轨迹一致性**：task_type 是 verification，但 categories 里 verify:0 → 🚩 语义偏差
2. **预期-证据匹配**：expected vs actual 逐条比对 → 发现未达成的检查项
3. **操作模式偏差**：intent 说"验证"，trace 全是 install → 🚩 上下文污染信号

### 子会话 Prompt 模板

```
你是独立验证员，没有之前的对话上下文。
请基于以下验证清单进行客观检查：

## 验证清单
{verification_manifest}

## 检查项
1. 意图-轨迹一致性：task_type 与实际执行操作是否匹配？
2. 预期-证据匹配：每个 expected_state 是否都有对应的 actual_evidence 支持？
3. 操作模式偏差：执行轨迹中是否存在与意图不符的操作模式？

## 输出
- PASS：所有检查通过
- FAIL：说明具体问题和建议

只报告事实，不要猜测意图。
```

### 触发条件

语义验证**不是每次任务都触发**，只在以下情况启用：

- 任务涉及多轮工具调用（>5 次）
- 任务类型是 verification/analysis（容易被锚定）
- 用户明确要求"检查一下"
- 到达预设检查点

### 配置开关

```yaml
# 在 config 或 skill 配置中控制
semantic_verification:
  enabled: true          # 总开关
  trigger_threshold: 5   # 工具调用次数阈值
  task_types:            # 需要语义验证的任务类型
    - verification
    - analysis
    - diagnosis
  checkpoint_mode: false # 是否启用检查点模式（vs 仅完成后验证）
```

### 与现有校验的关系

| 校验类型 | 执行者 | 上下文 | 检测目标 |
|---------|--------|--------|---------|
| 自动校验（规则） | 主会话 | 有上下文 | 格式、步骤完整性 |
| 语义验证（子会话） | 子会话 | 零上下文 | 意图理解偏差、上下文污染 |

两者互补：
- 自动校验检查"有没有做"
- 语义验证检查"做的是不是对的"

### 示例：上下文污染检测

```
场景：用户说"检查一下 tree-sitter 有没有用上"
Agent 之前一直在装 tree-sitter，被锚定在"安装"模式

Verification Manifest:
  original_intent: "验证 tree-sitter 是否已生效"
  task_type: "verification"
  execution_trace:
    categories: {install: 8, configure: 2, verify: 0}
    
子会话检测:
  🚩 意图-轨迹不一致：task_type=verification 但 verify=0
  🚩 操作模式偏差：全是 install 操作，没有验证操作
  结论：FAIL - Agent 可能误解了"检查"的含义
```

## 何时加载此 Skill

- 任务完成后
- 用户要求生成执行报告
- 需要复盘任务执行情况
- 多轮工具调用后需要语义验证
