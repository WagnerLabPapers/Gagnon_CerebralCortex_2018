function [studyData] = ap_behavAnalysis_study(subID)
% Outputs trial information for each study run
[~,thePath] = setupScript();

% Load in mat file
cd(fullfile(thePath.data,subID));
studyMat = [subID '_study_cat.mat'];
load(studyMat);
nRuns = size(studyData,2);
studyData = studyData(nRuns); % create var inclusive of all info

% Create txt file
studyTxt = [subID '_behav_study.csv'];
fid = fopen(studyTxt,'wt');
fprintf(fid, 'index,run,trial,onset,duration,cond,repType,repCount,word,pic,resp,respRT,ISIresp,ISIrespRT\n');
formatString = '%d,%d,%d,%.4f,%.4f,%s,%d,%d,%s,%s,%s,%.4f,%s,%.4f\n';

trialsPerRun = 24;
totalTrials = length(studyData.onset);
for t = 1:totalTrials
    run = studyData.block(t);
    trial = t - trialsPerRun*(run - 1);
    onset = studyData.onset(t);
    dur = studyData.dur(t);
    cond = studyData.cond{t};
    word = studyData.wordShown{t};
    pic = studyData.picShown{t};
    respRT = studyData.stimRT{t}(end); % take last!
    isiRespRT = studyData.isiRT{t}(1); % take first!
    repType = studyData.repType(t);
    repCount = studyData.repCount(t);
    
    % behavioral
%     resp = studyData.stimCodedResp{t};
%     isiResp = studyData.isiCodedResp{t};
    
    % Scanner
    resp = codeBehavResp(studyData.stimResp{t}, studyData.respCodes, studyData.respOpts, 'last');
    isiResp = codeBehavResp(studyData.isiResp{t}, studyData.respCodes, studyData.respOpts, 'first');

    
    fprintf(fid, formatString, t, run, trial, onset, dur, cond, repType, repCount, word, pic, resp, respRT,isiResp, isiRespRT);
end

cd(thePath.scripts);

end