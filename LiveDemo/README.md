# Task 1–6 Live Script

[简体中文](README_zh-CN.md)

Open `ME5411_Task1to6_Demo.mlx` to view the saved comparisons. It contains the existing CoreCode methods, their unchanged default parameters, visible calculation code, 16 comparison figures, and blank observation/explanation fields for the project group.

## Run

Keep this folder beside `dataset_2026`. From the repository root in MATLAB:

```matlab
cd LiveDemo
open('ME5411_Task1to6_Demo.mlx')
```

Click **Run** to execute the whole document. The readable `ME5411_Task1to6_Demo_source.m` runs the same calculations. `me5411_experiment.m` must remain in this folder. No extra MATLAB toolbox is required; the record helper uses Java for SHA-256 and directory handling. MATLAB R2026b requires a compatible Java runtime to be configured separately; see [MathWorks OpenJDK compatibility](https://www.mathworks.com/support/requirements/openjdk.html).

Task 1, Task 2 and Task 3 independently use the original image. Task 4 reads this run's Task 3 crop; Task 5 and Task 6 use Task 4's binary image. Task 6 does not use the Task 5 outlines. The notebook includes all existing CoreCode alternatives, without selecting an optimal method or parameter. CoreCode's edge-linking window is 5; the GUI default is 3, and this difference is marked in the document.

## Optional experiment archive

1. Leave `saveExperiment = false` and run from the beginning to inspect the results.
2. To archive the completed run, change it to `true` in the final **保存本次实验** section, optionally enter `experimentName` and `experimentNotes`, and run **only that section**.
3. Keep it `false` to decline. Reset it to `false` before another preview run.

Calculations still write intermediate files to a unique system temporary directory. Saving creates a unique `experiments/` subdirectory with the executed parameter snapshot, input copy and checksum, run times, actual comparison figures, arrays, and necessary outputs. Repeated saves create new directories. Incomplete, missing or modified snapshots are rejected. Changing parameters without rerunning does not change the completed snapshot; rerun from the beginning to archive new settings. Temporary files may be removed by the operating system.

Saving the MATLAB document itself is separate from archiving an experiment. A newly opened document can display embedded results without an active run; execute the full document before archiving in a new session. Experiment directories are ignored by Git and must be backed up separately if needed.

## Rebuild and validation

Edit the readable source, then rebuild the `.mlx` so both remain synchronized:

```matlab
addpath tools
build_live_script
```

This helper uses MATLAB R2026b's installed internal conversion interfaces, which may change in another release. If unavailable, open the readable source in the Editor, choose **Open as Live Script**, and save a copy as `ME5411_Task1to6_Demo.mlx`; run and save it to embed current outputs. Do not rename a `.m` file to `.mlx`.

The existing GUI and CoreCode files are unchanged. Default calculations and archive controls were checked on macOS Apple Silicon with MATLAB R2026b and OpenJDK 21, including a clean copy at a different path. Source and Live Script calculations were compared against the existing CoreCode outputs. These checks establish reproducibility of the existing behavior, not algorithm quality or experiment conclusions. Observations, analysis and reasoning are for the project group to complete.
