function build_live_script
% Rebuild the Live Script using MATLAB R2026b's installed file converters.
% These internal conversion APIs are version-dependent. If unavailable,
% open the source in the Editor and use Open as Live Script, then Save As.
folder=fileparts(fileparts(mfilename('fullpath')));
old=cd(folder);cleanup=onCleanup(@()cd(old));
source=fullfile(folder,'ME5411_Task1to6_Demo_source.m');
destination=fullfile(folder,'ME5411_Task1to6_Demo.mlx');
matlab.internal.liveeditor.openAndSave(source,destination);
matlab.internal.liveeditor.executeAndSave(destination);
% Verify embedded execution outputs: executeAndSave can return after errors.
stage=tempname;mkdir(stage);cleanStage=onCleanup(@()rmdir(stage,'s'));
unzip(destination,stage);
outputs=fileread(fullfile(stage,'matlab','output.xml'));
assert(~contains(outputs,'<type>error</type>'),'Live Script execution failed; inspect the saved output.');
assert(contains(outputs,'ME5411_DEMO_COMPLETE:'),'No completion marker in Live Script.');
assert(numel(strfind(outputs,'<type>figure</type>'))==16,'Expected 16 embedded comparison figures.');
fprintf('LIVE_SCRIPT_BUILT_WITH_16_FIGURES\n');
end
