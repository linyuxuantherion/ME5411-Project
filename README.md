# ME5411 — Currently Completed Code for Image Processing Task1–6

English · [简体中文](README_zh-CN.md)

This project was developed and tested using MATLAB R2025b Update 7. Both `ME5411_Task1to6.m` and the scripts in `CoreCode` use only MATLAB; no additional toolboxes are required.

Ensure that `dataset_2026/Test_Image_2026.bmp` exists relative to the project root. Open MATLAB, open `ME5411_Task1to6.m`, and click **Run** to launch the GUI for Tasks 1–6.

The scripts in `CoreCode` were created to make the algorithms easier to explain in a report. They contain the core code for individual parts of `ME5411_Task1to6.m`, but the main program does not reference or call them. Each script can be run independently when its required input files are available; later tasks use outputs from earlier tasks. Parameters must be edited manually in the code, which is less convenient than using the GUI. For normal use, running `ME5411_Task1to6.m` directly is recommended.

## Live Script walkthrough

[`LiveDemo/`](LiveDemo/README.md) provides an executed Live Script with visible Task 1–6 code, unchanged CoreCode defaults, comparison figures, and an optional experiment archive (off by default). The original GUI, CoreCode, and datasets remain the project sources.

The default walkthrough was also checked on MATLAB R2026b on Apple Silicon. R2026b no longer bundles Java; the GUI Task 6 export and the walkthrough record helper need a compatible OpenJDK runtime. See [MathWorks compatibility](https://www.mathworks.com/support/requirements/openjdk.html). Generated outputs and local experiment archives are excluded from Git.
