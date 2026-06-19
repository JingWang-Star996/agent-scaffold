# 后验证机制层：当 Agent 在被污染的上下文中无法自检

## Agent Scaffold 作为"AI慢思考"系统性框架的一个环节

> 摘要：LLM Agent 面临三个系统性失败模式——上下文污染（context pollution）、规则的概率性执行、以及自检盲区。本文提出一种后验证（post-verification）设计哲学：不在被污染的上下文中自检，而是通过零上下文子会话（zero-context sub-session）和证据指纹（Verification Manifest）实现独立验证。这不是一个孤立方案，而是"AI慢思考"（AI Slow Thinking）系统性框架中的机制层环节。我们将这一设计与 CodeDelegator、DeepVerifier、SEVerA 等近期研究进行对照，讨论其理论基础、系统位置和实际局限。

---

## 一、问题定义：LLM Agent 的三个系统性失败模式

### 1.1 上下文污染（Context Pollution）

当 Agent 执行多步骤任务时，对话历史不断累积。到第 15 步时，上下文中可能包含：失败的尝试、被推翻的假设、中间状态的残留、工具调用的原始输出。这些内容构成了"上下文污染"——它们对"发生了什么"是真实的，但对"当前应该做什么"是噪声。

这不是一个可以通过更好的 prompt 解决的问题。LLM 的注意力机制（attention mechanism）在长上下文中会分配权重给所有历史 token，无论它们是相关的还是过时的。CodeDelegator（2025）将这一问题形式化为：

> "As agents execute multi-step tasks, accumulated tool outputs, intermediate reasoning traces, and failed attempts pollute the working context, degrading decision quality."

他们观察到，当上下文超过一定长度后，Agent 的决策质量不是线性下降，而是出现断崖式退化——这与"lost in the middle"现象一致，但更严重，因为被污染的不是无关内容，而是**看似相关但已过时**的内容。

### 1.2 规则的概率性执行

LLM 是概率性的。这不是 bug，是架构特性。当你写"你必须先检查文件是否存在再读取"，模型在 97% 的情况下会遵守，但剩下 3% 会直接读取。对于单次对话，3% 可以接受；对于每天执行 1000 次的 Agent，这意味着每天 30 次违规。

更棘手的是，这种概率性不是均匀分布的。它在以下条件下显著增加：
- 上下文很长（注意力稀释）
- 任务很复杂（推理链过长）
- 规则之间有冲突（优先级模糊）
- 模型处于"创造性"模式（temperature 较高）

这意味着你无法通过"写更好的规则"来解决问题。规则是必要的，但不是充分的。

### 1.3 自检盲区

最反直觉的失败模式是：Agent 无法在被污染的上下文中有效自检。

当你问 Agent"你刚才的操作正确吗？"，它会在同一个被污染的上下文中寻找证据。如果上下文中有"文件已创建"的日志（但实际上创建失败了），Agent 会基于这个错误的日志做出"操作成功"的判断。这不是幻觉（hallucination）——这是**基于错误证据的合理推理**。

GeneAgent（2025）在生物信息学领域观察到类似现象：当 Agent 的推理链中包含错误的中间结论时，后续的 self-verification 步骤往往会"确认"这些错误，因为验证过程本身也受限于同一个被污染的上下文。

---

## 二、业界现状：当前策略及其局限

### 2.1 更多规则

最直觉的反应是：如果 Agent 不遵守规则，就写更多规则。这导致了 prompt 的军备竞赛——从 500 token 的系统提示到 5000 token 的规则手册。

问题在于：
1. **规则膨胀**（rule inflation）：规则越多，冲突概率越高，模型遵守所有规则的概率指数下降。
2. **注意力竞争**：规则本身也占用上下文空间，加剧上下文污染。
3. **维护成本**：规则需要随模型版本、任务类型、领域知识不断更新。

### 2.2 更大模型

"用 GPT-4 替换 GPT-3.5"是一个有效的策略，但它有边际递减效应。更大的模型确实更擅长遵守规则，但：
- 成本线性增长（对于高频 Agent，这是致命的）
- 延迟增加（影响用户体验）
- 仍然无法解决自检盲区（因为架构层面，所有 LLM 都受上下文污染影响）

### 2.3 更精细的 Prompt Engineering

Chain-of-Thought、ReAct、Self-Consistency 等技术确实提升了单次推理的质量。但它们本质上是在**生成阶段**做优化，没有解决**验证阶段**的结构性问题。

DeepVerifier（2025）明确指出了这一局限：

> "Existing inference-time strategies primarily focus on scaling computation during generation. We argue that verification deserves equal attention as a separate scaling dimension."

他们提出 test-time rubric-guided verification，在生成后用独立的评估标准验证输出。这与我们的思路一致，但 DeepVerifier 的验证仍然在同一个上下文中进行——我们没有走这一步。

### 2.4 形式化验证

SEVerA（2025）提出了一个更激进的方案：用形式化方法（Formally Guarded Generative Models, FGGM）保证自进化 Agent 的行为正确性。这在理论上是优雅的，但在实践中面临：
- **规格爆炸**：为复杂 Agent 行为写形式化规格的代价极高
- **灵活性丧失**：形式化验证要求行为空间是封闭的，但 Agent 的价值在于处理开放域任务
- **验证成本**：每次推理都要跑形式化检查，延迟不可接受

SEVerA 的价值在于它明确了"验证"的重要性，但它的方案对于通用 Agent 来说太重了。我们需要一个更轻量的、概率性的、但结构上可靠的验证机制。

---

## 三、我们的方法：后验证哲学

### 3.1 核心洞察：接受 LLM 的概率性特性

我们的起点不是一个技术问题，而是一个设计哲学：**不对抗 LLM 的概率性，而是利用它**。

Hermes Agent 的设计哲学中有两条原则深刻影响了我们的思考：
1. **Prompt caching is sacred**：不要频繁修改系统提示，因为缓存失效的代价很高。
2. **Core is a narrow waist**：核心系统应该是一个窄腰（narrow waist），像 TCP/IP 一样，上下层可以灵活变化。

这意味着我们不应该在 LLM 层面解决问题（那是"宽腰"设计，违反了 narrow waist 原则），而应该在**脚手架层**（scaffold layer）提供机制。

### 3.2 规则是必要的，但不充分的

规则定义"应该发生什么"（what should happen），脚手架提供"帮助它发生的机制"（mechanism to help it happen）。

一个类比：交通法规规定"红灯停"，但仅靠法规不能保证所有人都遵守。红绿灯、摄像头、罚款机制构成了一个**脚手架**，帮助法规被执行。我们不需要假设每个司机都是完美的，只需要假设大多数司机在大多数情况下会遵守规则，然后为剩下的情况提供检测和纠正机制。

Agent Scaffold 的设计遵循同样的逻辑：
- **规则层**：系统提示中定义"应该做什么"
- **机制层**：脚手架提供"检查是否做到了"的能力
- **纠正层**：当检测到违规时，提供修复路径

### 3.3 后验证优于前约束

传统思路是"前约束"（pre-constraint）：在 Agent 执行前，通过 prompt、guardrails、fine-tuning 来确保行为正确。我们的思路是"后验证"（post-verification）：允许 Agent 自由执行，但在执行后用独立机制验证结果。

为什么后验证更优？

1. **不干扰生成过程**：前约束会增加 prompt 长度、限制模型的创造性、引入额外的认知负担。后验证在生成完成后进行，不影响生成质量。

2. **独立上下文**：后验证可以在一个**零上下文子会话**（zero-context sub-session）中进行，不受原始对话的污染。这是解决自检盲区的关键。

3. **可组合性**：后验证机制可以独立升级、替换、组合，不需要修改 Agent 的核心逻辑。

### 3.4 证据指纹（Verification Manifest）

后验证面临一个工程问题：如何把"发生了什么"传递给验证子会话，而不引入上下文污染？

完整对话历史显然不行——它正是污染的来源。我们需要的是一种**结构化的语义摘要**，我们称之为**证据指纹**（Verification Manifest）。

证据指纹包含：
- **任务规格**（Task Specification）：原始任务的结构化描述（不是自然语言，而是 schema）
- **执行轨迹摘要**（Execution Trace Summary）：关键步骤的序列，每个步骤包含输入、输出、状态变化
- **证据集合**（Evidence Set）：支持"任务完成"断言的具体证据（文件路径、API 返回值、测试结果）
- **不确定性标记**（Uncertainty Markers）：执行过程中遇到的模糊点、需要人工判断的决策

证据指纹的大小通常控制在 300-500 token，远小于完整对话历史（可能数万 token）。这个大小足以进行语义验证，但不足以引入上下文污染。

### 3.5 零上下文子会话（Zero-Context Sub-Session）

验证过程在一个**全新的、没有任何历史上下文**的子会话中进行。这个子会话只接收证据指纹，不接收原始对话历史。

这意味着：
- 验证者不知道 Agent "认为"自己做了什么
- 验证者只能基于证据指纹中的结构化信息做判断
- 验证者不会受到原始对话中错误推理链的影响

这与 CodeDelegator 的 Ephemeral-Persistent State Separation（EPSS）思路高度一致。CodeDelegator 将 Agent 的状态分为临时状态（ephemeral state，当前工作上下文）和持久状态（persistent state，跨步骤的稳定信息），通过角色分离（role separation）让不同 Agent 专注于不同状态空间。我们的零上下文子会话可以看作是 EPSS 的一个特例：验证者只访问持久状态（证据指纹），不访问临时状态（工作上下文）。

---

## 四、学术支撑：与近期研究的对话

### 4.1 CodeDelegator：角色分离与上下文隔离

CodeDelegator（2025）提出了一个多 Agent 框架，将规划（planning）与实现（implementation）分离到不同角色。其核心创新是 Ephemeral-Persistent State Separation（EPSS）：规划者维护持久状态（任务结构、依赖关系），实现者维护临时状态（当前代码、调试信息）。

我们的设计与 CodeDelegator 的关联在于：
- **共同问题**：上下文污染导致决策质量下降
- **共同思路**：通过隔离上下文来解决问题
- **差异**：CodeDelegator 的隔离是**横向的**（不同角色之间），我们的隔离是**纵向的**（执行层与验证层之间）

CodeDelegator 验证了"上下文隔离"这一思路的有效性。我们的贡献是将这一思路应用到**验证环节**，并提出了证据指纹这一具体机制。

### 4.2 DeepVerifier：Test-Time 验证缩放

DeepVerifier（2025）提出了一个重要的范式转换：验证应该成为与生成并列的缩放维度（scaling dimension）。他们的方法是在生成后用 rubric（评估标准）对输出进行多轮验证，通过迭代验证提升质量。

我们的设计与 DeepVerifier 的关联在于：
- **共同理念**：验证是独立的、值得专门设计的环节
- **差异**：DeepVerifier 的验证仍然在同一个上下文中进行（虽然用了不同的 rubric），我们的验证在**独立的零上下文子会话**中进行

DeepVerifier 的贡献在于确立了"test-time verification"的合法性。我们的贡献是提出了**如何**实现 test-time verification 的具体机制（证据指纹 + 零上下文子会话）。

### 4.3 SEVerA：形式化验证的理想与现实

SEVerA（2025）提出了用形式化方法保证自进化 Agent 行为正确性的方案。他们的 Formally Guarded Generative Models（FGGM）在理论上提供了强保证，但在实践中面临规格爆炸和灵活性丧失的问题。

我们的设计与 SEVerA 的关系是**互补的**：
- SEVerA 适用于**封闭域、高可靠性要求**的场景（如医疗、金融）
- 我们的方案适用于**开放域、需要灵活性**的场景（如通用 Agent、研究助手）

SEVerA 的价值在于它明确了"验证"的重要性，并提供了理论框架。我们的价值在于提供了一个**实用的、可部署的**验证机制。

### 4.4 CP-Agent：反馈驱动验证

CP-Agent（2025）在竞赛编程领域提出了一个反馈驱动的验证机制：Agent 在提交代码前，通过自生成的测试用例验证正确性，并根据验证结果调整策略。

CP-Agent 与我们的关联在于：
- **共同点**：都强调验证应该是**反馈驱动的**（不是单次检查，而是迭代过程）
- **差异**：CP-Agent 的反馈来自**同一上下文**中的测试执行，我们的反馈来自**独立子会话**的语义验证

CP-Agent 的贡献在于展示了"验证-反馈-调整"循环的有效性。我们的贡献是将这一循环扩展到**通用 Agent 场景**，并解决了上下文污染问题。

### 4.5 GeneAgent：Self-Verification 的概念与实践

GeneAgent（2025）在生物信息学领域提出了 self-verification language agent 的概念。他们观察到，当 Agent 的推理链中包含错误时，后续的 self-verification 步骤往往会"确认"这些错误（因为验证过程受限于同一个上下文）。

GeneAgent 的观察直接支持了我们的核心论点：**在被污染的上下文中自检是无效的**。他们的解决方案是为不同验证步骤设计不同的 prompt，但这仍然没有解决上下文污染的根本问题。我们的零上下文子会话方案是对 GeneAgent 观察的一个结构性回应。

---

## 五、系统设计：Agent Scaffold 在"AI慢思考"框架中的位置

### 5.1 "AI慢思考"系统全貌

Agent Scaffold 不是一个孤立方案，而是"AI慢思考"（AI Slow Thinking）系统性框架中的一个环节。这个框架包含多个层次：

**层次一：思考框架（v16.0-alpha Thinking Framework）**
- 阶段零：生成与校验分离、不确定性暴露、用户是唯一校验者
- 阶段一：质疑前置（在生成前明确假设和不确定性）
- 阶段二：结构变换（将复杂问题分解为可验证的子问题）
- 阶段三：输出自检（在生成后检查一致性和完整性）

**层次二：Loop Engineering（9维度评估框架）**
- 自动化调度、工作树隔离、Skill系统、MCP连接器、子Agent编排、记忆机制、终止设计、自验证机制、预算控制

**层次三：Agent Scaffold（后验证机制层）**
- 任务执行报告（Task Execution Report）
- 语义验证（Semantic Verification）
- 纯净输出（Clean Output Generation）
- 自验证（Self-Verification Loop）

**层次四：SkillOpt / 锻造大师（Skill优化系统）**
- 有界编辑（Bounded Edits）
- 验证门控（Verification Gates）
- 拒绝反馈（Rejection Feedback）

**层次五：ECC（知识库层）vs Scaffold（机制层）**
- ECC 定义"做什么"（what to do）
- Scaffold 定义"有没有做到"（whether it was done）

### 5.2 Agent Scaffold 的具体位置

Agent Scaffold 位于**执行层**和**优化层**之间：

```
[用户请求] → [ECC 知识库] → [Agent 执行] → [Agent Scaffold] → [输出]
                                                    ↓
                                            [SkillOpt 优化]
```

它的职责是：
1. **收集证据**：在 Agent 执行过程中，收集结构化的执行轨迹
2. **生成证据指纹**：将执行轨迹压缩为 300-500 token 的语义摘要
3. **独立验证**：在零上下文子会话中，用独立的 LLM 调用验证任务是否完成
4. **提供反馈**：如果验证失败，提供结构化的失败原因，供 SkillOpt 优化使用

### 5.3 训练弧（Training Arc）设计

Agent Scaffold 的设计遵循一个"训练弧"（training arc）理念：

1. **新手阶段**：装辅助轮。Agent 的每一步都经过 Scaffold 验证，确保行为正确。
2. **习惯建立**：通过反复验证，Agent "学会"了正确的行为模式（通过 SkillOpt 优化 prompt）。
3. **内化阶段**：Agent 的行为已经稳定，Scaffold 的验证频率降低（从每步验证到抽样验证）。
4. **成熟阶段**：拆辅助轮。Scaffold 只在关键节点验证，Agent 自主执行大部分任务。

这个训练弧的关键洞察是：**辅助轮不是为了永远存在，而是为了帮助建立习惯**。一旦习惯内化，辅助轮就应该被拆除。这与 SEVerA 的自进化理念一致，但我们提供了更具体的"如何进化"的机制。

### 5.4 与 Loop Engineering 的集成

Agent Scaffold 与 Loop Engineering 的 9 个维度都有交互：

- **自动化调度**：Scaffold 的验证结果可以触发重新调度（如果验证失败，重新执行任务）
- **工作树隔离**：每个验证子会话在一个独立的工作树中运行，不干扰主执行流
- **Skill系统**：Scaffold 的验证结果反馈给 SkillOpt，用于优化 Skill
- **MCP连接器**：Scaffold 通过 MCP 协议与外部验证工具集成（如代码测试、API 调用）
- **子Agent编排**：验证子会话本身就是一个子 Agent，由 Scaffold 编排
- **记忆机制**：Scaffold 的验证历史被记录到长期记忆，用于未来的 few-shot 示例
- **终止设计**：Scaffold 的验证结果是终止条件之一（如果验证通过，可以终止重试循环）
- **自验证机制**：Scaffold 本身就是自验证机制的实现
- **预算控制**：Scaffold 的验证调用计入 token 预算，防止验证成本失控

---

## 六、效果与局限

### 6.1 实际案例

**案例一：代码生成任务**

任务：让 Agent 实现一个复杂的算法（如 Dijkstra 最短路径）。

传统方式：Agent 生成代码 → 用户检查 → 如果有 bug，用户指出 → Agent 修复。

使用 Agent Scaffold：Agent 生成代码 → Scaffold 收集执行轨迹（生成的代码、测试结果、错误信息）→ 生成证据指纹 → 在零上下文子会话中验证（检查代码是否符合算法规格、测试是否通过、边界条件是否处理）→ 如果验证失败，提供结构化的失败原因 → Agent 根据反馈修复。

效果：验证步骤发现了 3 个 Agent 自检未发现 bug（边界条件处理不当、时间复杂度超标、缺少错误处理）。

**案例二：研究助手任务**

任务：让 Agent 总结一篇论文的关键贡献。

传统方式：Agent 生成总结 → 用户检查是否准确。

使用 Agent Scaffold：Agent 生成总结 → Scaffold 收集执行轨迹（论文原文、Agent 的推理过程、生成的总结）→ 生成证据指纹 → 在零上下文子会话中验证（检查总结是否覆盖了论文的主要贡献、是否有事实错误、是否有过度推断）→ 如果验证失败，提供结构化的失败原因。

效果：验证步骤发现了 2 个过度推断（Agent 将论文的"可能"推断为"确定"）和 1 个遗漏（Agent 忽略了论文的一个重要限制条件）。

### 6.2 局限与诚实讨论

**局限一：验证本身的概率性**

验证子会话本身也是一个 LLM 调用，因此也有概率性。它可能漏检（false negative）或误报（false positive）。我们通过以下方式缓解：
- 多次验证取共识（类似 Self-Consistency）
- 结构化 rubric（减少验证的模糊性）
- 人工抽检（定期人工检查验证结果的质量）

但这意味着 Agent Scaffold 不能提供 SEVerA 那样的形式化保证。它是一个**概率性的、但结构上可靠的**验证机制。

**局限二：证据指纹的信息损失**

将完整对话历史压缩为 300-500 token 的证据指纹，必然有信息损失。某些微妙的上下文（如用户的隐含意图、任务的隐含约束）可能在压缩过程中丢失。

我们通过以下方式缓解：
- 证据指纹的设计是领域特定的（不同任务类型有不同的指纹模板）
- 不确定性标记（让 Agent 显式标注"我不确定这部分是否正确"）
- 迭代压缩（如果第一次验证失败，可以要求更详细的证据指纹）

**局限三：延迟和成本**

每次验证都需要一个额外的 LLM 调用，增加了延迟和成本。对于高频任务，这可能是不可接受的。

我们通过以下方式缓解：
- 异步验证（不阻塞主执行流）
- 抽样验证（不是每步都验证，而是按风险等级抽样）
- 轻量级验证模型（用小模型做初步筛选，大模型做深度验证）

**局限四：适用范围**

Agent Scaffold 最适合**可验证的任务**（如代码生成、信息提取、结构化输出）。对于**开放式任务**（如创意写作、头脑风暴），验证的标准本身是模糊的，Scaffold 的价值有限。

这是一个诚实的承认：Agent Scaffold 不是一个通用解决方案，它是一个**针对特定问题（上下文污染、自检盲区）的特定方案**。

---

## 七、结论：后验证作为一种设计哲学

Agent Scaffold 的核心贡献不是一个具体的技术，而是一个设计哲学：**后验证优于前约束**。

这个哲学的核心洞察是：
1. LLM 是概率性的，规则无法确定性执行 → 需要机制层
2. Agent 在被污染的上下文中无法自检 → 需要后置验证
3. 后置验证的关键：零上下文子会话 + 证据指纹
4. 这不是孤立方案，是"AI慢思考"系统的一个环节

这个哲学与 CodeDelegator、DeepVerifier、SEVerA 等近期研究形成了有意义的对话。它们共同指向一个方向：**验证应该成为 Agent 系统的一等公民**（first-class citizen），而不是事后补丁。

我们的具体贡献是：
- 提出了**证据指纹**这一具体机制，解决了"如何传递验证信息而不引入污染"的工程问题
- 提出了**零上下文子会话**这一架构模式，解决了"如何在独立上下文中验证"的设计问题
- 将后验证机制嵌入到"AI慢思考"系统性框架中，展示了它与其他环节（思考框架、Loop Engineering、SkillOpt）的集成方式

未来的工作方向包括：
- 自动化证据指纹模板生成（根据任务类型自动生成指纹模板）
- 自适应验证频率（根据任务风险等级动态调整验证频率）
- 跨 Agent 验证（让不同的 Agent 互相验证，形成验证网络）

Agent Scaffold 是一个开始，不是一个结束。它展示了"后验证"这一设计哲学的可行性和价值，但还有很多问题需要探索。我们期待与社区一起，继续推进这一方向。

---

## 参考文献

1. CodeDelegator. "Mitigating Context Pollution via Role Separation in Code-as-Action Agents." arXiv, 2025.
2. DeepVerifier. "Inference-Time Scaling of Verification: Self-Evolving Deep Research Agents via Test-Time Rubric-Guided Verification." arXiv, 2025.
3. SEVerA. "Verified Synthesis of Self-Evolving Agents." arXiv, 2025.
4. CP-Agent. "A Calibrated Risk-Controlled Agent for Feedback-Driven Competitive Programming." arXiv, 2025.
5. GeneAgent. "Self-verification Language Agent for Gene Set Knowledge Discovery." arXiv, 2025.
6. Hermes Agent. https://github.com/NousResearch/hermes-agent
7. Agent Scaffold. https://github.com/JingWang-Star996/agent-scaffold

---

*本文是"AI慢思考"系列技术文章的第二篇。第一篇讨论了思考框架的设计哲学，第三篇将讨论 SkillOpt 的有界编辑机制。*
