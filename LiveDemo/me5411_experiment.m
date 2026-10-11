function out = me5411_experiment(action,varargin)
% Experiment-record storage only; no image-processing algorithms.
switch action
    case 'start'
        notebookRoot=varargin{1}; inputPath=varargin{2};
        base=fullfile(tempdir,'ME5411_LiveDemo');
        if ~isfolder(base), mkdir(base); end
        workDir=tempname(base); mkdir(workDir); mkdir(fullfile(workDir,'input'));
        frozenInput=fullfile(workDir,'input','Test_Image_2026.bmp');
        copyfile(inputPath,frozenInput);
        [~,runId]=fileparts(workDir);
        out=struct('Completed',false,'NextStep',1,'WorkDir',workDir, ...
            'RunId',runId,'NotebookDir',notebookRoot,'StartedAtUTC',utcNow(), ...
            'Timer',tic,'InputOriginalPath',inputPath,'InputSHA256',fileHash(frozenInput), ...
            'ManifestSHA256','');
    case 'step'
        out=varargin{1}; step=varargin{2};
        assert(isstruct(out) && isfield(out,'NextStep') && out.NextStep==step && ~out.Completed, ...
            'ME5411:RunOrder','请从头运行完整展示；跳节或重跑中间节后不能归档旧结果。');
        out.Completed=false; out.NextStep=step+1;
    case 'complete'
        out=varargin{1};
        assert(isstruct(out) && ~out.Completed && out.NextStep==17,'ME5411:Incomplete','请先从头完成全部 16 个阶段。');
        d=load(fullfile(out.WorkDir,'results.mat'),'demoResults','demoParameters','demoLog');
        expected={'ContrastStretching','GrayLevelSlicing','DynamicRangeCompression','HistogramEqualization', ...
            'MeanFiltering','RotatingMask','MedianFiltering','Crop','Binarization','TwoPass','Sobel','Laplacian', ...
            'EdgeLinking','InitialLabeling','Relabeling','CharacterCrops'};
        assert(numel(d.demoLog)==16 && isequal({d.demoLog.Method},expected) && all(strcmp({d.demoLog.Status},'completed')), ...
            'ME5411:Incomplete','本轮阶段记录不完整，请从头运行。');
        for k=1:16
            assert(isfile(fullfile(out.WorkDir,[expected{k} '_comparison.png'])),'缺少本轮对比图。');
        end
        for k=1:numel(d.demoResults.Characters)
            assert(isfile(fullfile(out.WorkDir,sprintf('Task6_Character_%d.png',k))),'缺少本轮字符图。');
        end
        assert(strcmp(out.InputSHA256,fileHash(fullfile(out.WorkDir,'input','Test_Image_2026.bmp'))),'输入快照已更改。');
        manifest=struct('SchemaVersion',1,'RunId',out.RunId,'StartedAtUTC',out.StartedAtUTC, ...
            'CompletedAtUTC',utcNow(),'ElapsedSeconds',toc(out.Timer),'MATLABVersion',version, ...
            'InputOriginalPath',out.InputOriginalPath,'InputSHA256',out.InputSHA256, ...
            'Parameters',d.demoParameters,'Status',d.demoLog,'Files',listFiles(out.WorkDir));
        writeJSON(fullfile(out.WorkDir,'manifest.json'),manifest);
        out.ManifestSHA256=fileHash(fullfile(out.WorkDir,'manifest.json'));
        out.Completed=true;
    case 'archive'
        state=varargin{1}; requested=varargin{2}; name=varargin{3}; notes=varargin{4};
        out=struct('Status','skipped','Path','','Message','未归档；图像仍可查看，中间文件暂存在本轮临时目录。');
        if ~isequal(requested,true), fprintf('%s\n',out.Message); return; end
        if ~isstruct(state) || ~isfield(state,'Completed') || ~state.Completed
            out.Status='not_ready';out.Message='没有已完整运行的本轮结果；请先从头运行展示，再运行保存节。';
            fprintf('%s\n',out.Message); return;
        end
        try
            manifestPath=fullfile(state.WorkDir,'manifest.json');
            assert(strcmp(fileHash(manifestPath),state.ManifestSHA256),'本轮清单已更改。');
            manifest=jsondecode(fileread(manifestPath));
            assert(strcmp(manifest.RunId,state.RunId),'本轮标识不一致。');
            verifyFiles(state.WorkDir,manifest.Files);
        catch e
            out.Status='invalid';out.Message=['未归档：本轮结果缺失或已更改，请从头运行。' e.message];
            fprintf('%s\n',out.Message);return;
        end
        if numel(varargin)>=5, archiveRoot=varargin{5}; else, archiveRoot=fullfile(state.NotebookDir,'experiments'); end
        if ~isfolder(archiveRoot), mkdir(archiveRoot); end
        stage=tempname(archiveRoot); assert(java.io.File(stage).mkdir(),'无法建立独立暂存目录。');
        cleanup=onCleanup(@()removeOwnStage(stage));
        safeName=regexprep(char(string(name)),'[\\/:*?"<>|\x00-\x1F]','_');
        safeName=strtrim(safeName); if isempty(safeName),safeName='experiment';end
        safeName=safeName(1:min(40,numel(safeName)));
        [~,uniqueId]=fileparts(stage);
        stamp=char(datetime('now','TimeZone','Asia/Singapore','Format','yyyyMMdd_HHmmss'));
        destination=fullfile(archiveRoot,[stamp '_' safeName '_' uniqueId]);
        for k=1:numel(manifest.Files)
            rel=manifest.Files(k).Path; dst=fullfile(stage,rel);
            parent=fileparts(dst); if ~isfolder(parent),mkdir(parent);end
            copyfile(fullfile(state.WorkDir,rel),dst);
        end
        copyfile(manifestPath,fullfile(stage,'manifest.json'));
        verifyFiles(stage,manifest.Files);
        assert(strcmp(fileHash(fullfile(stage,'manifest.json')),state.ManifestSHA256),'复制中的清单已更改。');
        receipt=struct('ExperimentName',char(string(name)),'Notes',char(string(notes)), ...
            'ArchivedAtUTC',utcNow(),'RunId',state.RunId,'RunManifestSHA256',state.ManifestSHA256, ...
            'ParametersSource','Frozen completed-run parameters.json/results.mat; not current workspace variables');
        writeJSON(fullfile(stage,'archive-info.json'),receipt);
        assert(~isfile(destination) && ~isfolder(destination),'归档目录已存在，拒绝覆盖。');
        [ok,msg]=movefile(stage,destination);assert(ok,msg);
        out.Status='saved';out.Path=destination;out.Message=['已归档本轮执行快照：' destination];
        fprintf('%s\n',out.Message);
    otherwise
        error('ME5411:StorageAction','Unknown storage action.');
end
end

function files=listFiles(folder)
items=dir(fullfile(folder,'**','*'));items=items(~[items.isdir]);
files=struct('Path',{},'Bytes',{},'SHA256',{});
for k=1:numel(items)
    full=fullfile(items(k).folder,items(k).name);
    relative=full(numel(folder)+2:end);
    files(end+1)=struct('Path',relative,'Bytes',items(k).bytes,'SHA256',fileHash(full)); %#ok<AGROW>
end
end

function verifyFiles(folder,files)
for k=1:numel(files)
    rel=files(k).Path;
    assert(~startsWith(rel,filesep) && ~any(strcmp(strsplit(rel,filesep),'..')),'无效的快照相对路径。');
    assert(strcmp(fileHash(fullfile(folder,rel)),files(k).SHA256),'快照文件校验失败：%s',rel);
end
end

function value=fileHash(file)
fid=fopen(file,'rb');assert(fid>=0,'无法读取文件：%s',file);cleanup=onCleanup(@()fclose(fid));
bytes=fread(fid,Inf,'*uint8');md=java.security.MessageDigest.getInstance('SHA-256');
md.update(typecast(bytes,'int8'));digest=typecast(md.digest(),'uint8');
value=lower(reshape(dec2hex(digest,2).',1,[]));
end

function writeJSON(file,value)
fid=fopen(file,'w');assert(fid>=0,'无法写入记录。');cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s',jsonencode(value,PrettyPrint=true));
end

function stamp=utcNow
stamp=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));
end

function removeOwnStage(stage)
if isfolder(stage),rmdir(stage,'s');end
end
