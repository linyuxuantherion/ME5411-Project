# Task 1–6 Live Script

[English](README.md)

打开 `ME5411_Task1to6_Demo.mlx` 可查看已保存的展示：CoreCode 现有方法、原默认参数、可见计算代码、16 幅对比图，以及留空的小组观察和解释区。

## 打开与运行

保留本文件夹与 `dataset_2026` 的相邻目录关系。在 MATLAB 中进入仓库根目录后执行：

```matlab
cd LiveDemo
open('ME5411_Task1to6_Demo.mlx')
```

点击 **Run** 从头执行。可读源码 `ME5411_Task1to6_Demo_source.m` 执行同样的计算；辅助文件 `me5411_experiment.m` 必须保留在本目录。不需要额外 MATLAB 工具箱；记录辅助函数使用 Java 进行 SHA-256 校验和目录操作。R2026b 需另行配置兼容 Java，参见 [MathWorks OpenJDK 支持表](https://www.mathworks.com/support/requirements/openjdk.html)。

Task 1、2、3 分别使用原图；Task 4 读取本轮 Task 3 裁剪；Task 5、6 使用 Task 4 二值图。Task 6 不使用 Task 5 轮廓图。展示涵盖 CoreCode 的现有方法，不代选最优方法或参数。CoreCode 边缘连接窗口默认为 5，GUI 默认为 3，文档中已标注此差异。

## 选择是否保存实验

1. 保持 `saveExperiment = false`，从头运行并查看图像。
2. 要归档，在末尾“保存本次实验”节将其改成 `true`，可填写 `experimentName` 和 `experimentNotes`，**仅运行该节**。
3. 不保存就保持 `false`。下一轮先预览时，运行前将开关改回 `false`。

计算仍会写入独立的系统临时目录。选择保存后，在 `experiments/` 下创建不重名的归档，包含已执行参数快照、输入副本及校验值、运行时间、实际对比图、数值数组和必要输出。重复保存生成新目录。未完成、缺失或被改动的快照会被拒绝。仅修改参数而未重跑，不会改变已完成快照；要记录新参数，请从头运行。临时文件可能被系统清理。

保存 MATLAB 文档与归档实验数据是两件事。新会话打开文档可以查看嵌入图像，但归档前须在该会话运行完整流程。实验目录已被 Git 忽略，需要长期保留时请另行备份。

## 同步源码与验证

修改可读源码后，重新生成 `.mlx`，避免两份文件不同步：

```matlab
addpath tools
build_live_script
```

生成工具使用本机 R2026b 的内部文件转换接口，其他版本可能变化。若接口不可用，在编辑器中打开可读源码，选择 **Open as Live Script**，另存为 `ME5411_Task1to6_Demo.mlx`，再运行并保存以嵌入结果；不能直接改后缀。

原 GUI、CoreCode 未修改。已在 macOS Apple Silicon、MATLAB R2026b、OpenJDK 21 环境核查默认计算及保存模块，并在不同路径的干净副本中验证；整理后的数值输出与既有 CoreCode 输出一致。这说明现有行为可复现，不构成算法质量或实验结论。观察、分析与推理由小组填写。
