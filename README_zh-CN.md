# ME5411 — 目前已完成 图像处理 Task1–6 的代码

[English](README.md) · 简体中文

本项目使用 MATLAB R2025b Update 7 开发并测试。`ME5411_Task1to6.m` 和 `CoreCode` 中的脚本均只依赖 MATLAB，无需额外工具箱。

请确保项目根目录下存在 `dataset_2026/Test_Image_2026.bmp`。打开 MATLAB，打开 `ME5411_Task1to6.m`，点击 **Run（运行）**，即可启动 Tasks 1–6 的 GUI。

`CoreCode` 中的脚本是为了方便在报告中讲解算法而创建的，包含 `ME5411_Task1to6.m` 各个部分的核心代码，但主程序并没有引用或调用这些脚本。只要所需输入文件存在，每个脚本都可以单独运行；后续任务会使用前序任务生成的输出文件。这些脚本需要手动在代码中修改参数，操作不如 GUI 方便，因此日常使用建议直接运行 `ME5411_Task1to6.m`。

## Live Script 分步展示

[`LiveDemo/`](LiveDemo/README_zh-CN.md) 提供已执行的 Live Script，展示 Task 1–6 现有代码、CoreCode 原默认参数和对比图，并可选择归档实验（默认关闭）。原 GUI、CoreCode 与数据保持不变。

默认展示另在 Apple Silicon 的 MATLAB R2026b 上验证。R2026b 不再附带 Java；GUI 的 Task 6 导出及展示文件的记录辅助函数需要兼容 OpenJDK，见 [MathWorks 支持表](https://www.mathworks.com/support/requirements/openjdk.html)。生成输出及本地实验归档不进入 Git。
