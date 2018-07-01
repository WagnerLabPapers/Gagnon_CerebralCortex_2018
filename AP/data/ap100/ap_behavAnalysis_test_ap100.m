function [testData] = ap_behavAnalysis_test_ap100(thePath,subID,studyData)
% Outputs trial information for each test run

% Load in mat file
currDir = pwd;
cd(fullfile(thePath.data,subID));
testMat = [subID '_test_cat.mat']; % use this instead of concat bc it has resp mapping
load(testMat); %testData
nRuns = size(testData,2);

first_runs = [subID '_block3_test.mat'];
load(first_runs); %theData

%% Combine data from various sources
cumData = theData;

% Determine accuracy
trialsPerRun = 42;

for run_num = 4:6
    increment_trial = (run_num-1) * trialsPerRun;
    for trial_num = 1:42
        trial_ind = trial_num + increment_trial;
        
        cumData.onset(trial_ind) = testData(run_num).onset(trial_ind);
        cumData.dur(trial_ind) = testData(run_num).dur(trial_ind);
        cumData.stimResp{trial_ind} = testData(run_num).stimResp{trial_ind};
        cumData.stimRT{trial_ind} = testData(run_num).stimRT{trial_ind};
        cumData.stimCodedResp{trial_ind} = testData(run_num).stimCodedResp{trial_ind};
        cumData.isiResp{trial_ind} = testData(run_num).isiResp{trial_ind};
        cumData.isiRT{trial_ind} = testData(run_num).isiRT{trial_ind};
        cumData.isiCodedResp{trial_ind} = testData(run_num).isiCodedResp{trial_ind};
        cumData.wordShown{trial_ind} = testData(run_num).wordShown{trial_ind};
        cumData.corrResp{trial_ind} = testData(run_num).corrResp{trial_ind};
        cumData.shock(trial_ind) = testData(run_num).shock(trial_ind);
        cumData.shockEventTime(trial_ind) = testData(run_num).shockEventTime(trial_ind);
        cumData.time_raw(trial_ind) = testData(run_num).time_raw(trial_ind);
        cumData.cortSample{trial_ind} = testData(run_num).cortSample{trial_ind};
        cumData.stimCodedResp_conf{trial_ind} = testData(run_num).stimCodedResp_conf{trial_ind};
        cumData.acc{trial_ind} = testData(run_num).acc{trial_ind};
        cumData.isiCodedResp_conf{trial_ind} = testData(run_num).isiCodedResp_conf{trial_ind};
    end
end

testData = cumData;

%% Determine accuracy
trialsPerRun = 42;
totalTrials = length(testData.onset);

for t = 1:totalTrials
    
    % convert button box resp during stim presentation to cond code
    % (if made more than one resp, take *LAST* resp)
    testData.stimCodedResp{t} = codeBehavResp(testData.stimResp{t}, testData.respCodes, testData.respOpts, 'last');
    testData.stimCodedResp_conf{t} = codeBehavResp(testData.stimResp{t}, testData.respCodes_conf, testData.respOpts, 'last');
    
    % if made more than one resp during stim presentation, take *LAST* RT
    testData.stimRT{t} = testData.stimRT{t}(end);
    
    
    % convert button box resp during ISI to cond code
    % (if made more than one resp, take *FIRST* resp)
    testData.isiCodedResp{t} = codeBehavResp(testData.isiResp{t}, testData.respCodes, testData.respOpts, 'first');
    testData.isiCodedResp_conf{t} = codeBehavResp(testData.isiResp{t}, testData.respCodes_conf, testData.respOpts, 'first');
    
    % if made more than one resp during ISI, take *FIRST* RT
    testData.isiRT{t} = testData.isiRT{t}(1);
    
    
    % depending on resp, determine accuracy
    if strcmp(testData.corrResp{t}, 'F') % foil trials
        
        % responses during stim
        if strcmp(testData.stimCodedResp(t),'F')
            testData.acc{t} = 'CR'; % correct rejection
            testData.accSpec{t} = 'CR'; % correct rejection
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Hi')
            testData.acc{t} = 'FA'; % false alarm
            testData.accSpec{t} = 'FAI_Hi';
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Lo')
            testData.acc{t} = 'FA'; % false alarm
            testData.accSpec{t} = 'FAI_Lo';
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Hi')
            testData.acc{t} = 'FA'; % false alarm
            testData.accSpec{t} = 'FAO_Hi';
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Lo')
            testData.acc{t} = 'FA'; % false alarm
            testData.accSpec{t} = 'FAO_Lo';    
        else
            testData.acc{t} = 'NR'; % no response
            testData.accSpec{t} = 'NR'; % no response
        end
        
        % responses during ISI
        if strcmp(testData.isiCodedResp(t),'F')
            testData.ISIacc{t} = 'CR'; % correct rejection
            testData.ISIaccSpec{t} = 'CR'; % correct rejection
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Hi')
            testData.ISIacc{t} = 'FA'; % false alarm
            testData.ISIaccSpec{t} = 'FAI_Hi';
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Lo')
            testData.ISIacc{t} = 'FA'; % false alarm
            testData.ISIaccSpec{t} = 'FAI_Lo';
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Hi')
            testData.ISIacc{t} = 'FA'; % false alarm
            testData.ISIaccSpec{t} = 'FAO_Hi';
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Lo')
            testData.ISIacc{t} = 'FA'; % false alarm
            testData.ISIaccSpec{t} = 'FAO_Lo';    
        else
            testData.ISIacc{t} = 'NR'; % no response
            testData.ISIaccSpec{t} = 'NR'; % no response
        end
        
    elseif strcmp(testData.corrResp{t}, 'TI') % target indoor trials
        
        if strcmp(testData.stimCodedResp(t),'F')
            testData.acc{t} = 'M'; % miss
            testData.accSpec{t} = 'MI'; % indoor miss
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Hi')
            testData.acc{t} = 'H'; % hit
            testData.accSpec{t} = 'HI_Hi'; % hi conf indoor hit
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Lo')
            testData.acc{t} = 'H'; % hit
            testData.accSpec{t} = 'HI_Lo'; % lo conf indoor hit
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Hi')
            testData.acc{t} = 'SM'; % source miss
            testData.accSpec{t} = 'SMI_Hi'; % hi conf source miss
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Lo')
            testData.acc{t} = 'SM'; % false alarm
            testData.accSpec{t} = 'SMI_Lo';    
        else
            testData.acc{t} = 'NR'; % no response
            testData.accSpec{t} = 'NR'; % no response
        end
        
        % responses during ISI
        if strcmp(testData.isiCodedResp(t),'F')
            testData.ISIacc{t} = 'M'; % miss
            testData.ISIaccSpec{t} = 'MI'; % indoor miss
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Hi')
            testData.ISIacc{t} = 'H'; % hit
            testData.ISIaccSpec{t} = 'HI_Hi'; % hi conf indoor hit
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Lo')
            testData.ISIacc{t} = 'H'; % hit
            testData.ISIaccSpec{t} = 'HI_Lo'; % lo conf indoor hit
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Hi')
            testData.ISIacc{t} = 'SM'; % source miss
            testData.ISIaccSpec{t} = 'SMI_Hi'; % hi conf source miss
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Lo')
            testData.ISIacc{t} = 'SM'; % false alarm
            testData.ISIaccSpec{t} = 'SMI_Lo';   
        else
            testData.ISIacc{t} = 'NR'; % no response
            testData.ISIaccSpec{t} = 'NR'; % no response
        end
        
    elseif strcmp(testData.corrResp{t}, 'TO') % target outdoor trials
        
        if strcmp(testData.stimCodedResp(t),'F')
            testData.acc{t} = 'M'; % miss
            testData.accSpec{t} = 'MI'; % indoor miss
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Hi')
            testData.acc{t} = 'H'; % hit
            testData.accSpec{t} = 'HO_Hi'; % hi conf outdoor hit
        elseif strcmp(testData.stimCodedResp_conf(t),'TO_Lo')
            testData.acc{t} = 'H'; % hit
            testData.accSpec{t} = 'HO_Lo'; % lo conf outdoor hit
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Hi')
            testData.acc{t} = 'SM'; % source miss
            testData.accSpec{t} = 'SMO_Hi'; % hi conf source miss
        elseif strcmp(testData.stimCodedResp_conf(t),'TI_Lo')
            testData.acc{t} = 'SM'; % false alarm
            testData.accSpec{t} = 'SMO_Lo';    
        else
            testData.acc{t} = 'NR'; % no response
            testData.accSpec{t} = 'NR'; % no response
        end
        
        % responses during ISI
        if strcmp(testData.isiCodedResp(t),'F')
            testData.ISIacc{t} = 'M'; % miss
            testData.ISIaccSpec{t} = 'MI'; % indoor miss
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Hi')
            testData.ISIacc{t} = 'H'; % hit
            testData.ISIaccSpec{t} = 'HO_Hi'; % hi conf outdoor hit
        elseif strcmp(testData.isiCodedResp_conf(t),'TO_Lo')
            testData.ISIacc{t} = 'H'; % hit
            testData.ISIaccSpec{t} = 'HO_Lo'; % lo conf outdoor hit
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Hi')
            testData.ISIacc{t} = 'SM'; % source miss
            testData.ISIaccSpec{t} = 'SMO_Hi'; % hi conf source miss
        elseif strcmp(testData.isiCodedResp_conf(t),'TI_Lo')
            testData.ISIacc{t} = 'SM'; % false alarm
            testData.ISIaccSpec{t} = 'SMO_Lo';   
        else
            testData.ISIacc{t} = 'NR'; % no response
            testData.ISIaccSpec{t} = 'NR'; % no response
        end
    end
    
end

% Save new mat file with accuracy info
save([subID '_test_cat_acc.mat'],'testData');

% Create txt file
testTxt = [subID '_behav_test.csv'];
fid = fopen(testTxt,'wt');
fprintf(fid, ['index,run,trial,onset,duration,cond,target,',...
    'associate,resp,acc,accSpec,respRT,ISIresp,ISIacc,',...
    'ISIaccSpec,ISIrespRT\n']);
formatString = ['%d,%d,%d,%.4f,%.4f,%s,%s,',...
    '%s,%s,%s,%s,%.4f,%s,%s,',...
    '%s,%.4f\n'];


for t = 1:totalTrials
    run = testData.block(t);
    trial = t - trialsPerRun*(run - 1);
    onset = testData.onset(t);
    dur = testData.dur(t);
    cond = testData.cond{t};
    target = testData.wordShown{t};
    % determine associate
    if strcmp(cond,'F')
        associate = 'foil';
    else
        associate = testData.imgName{t};
    end
    resp = testData.stimCodedResp{t};
    acc = testData.acc{t};
    accSpec = testData.accSpec{t};
    respRT = testData.stimRT{t};
    isiResp = testData.isiCodedResp{t};
    isiAcc = testData.ISIacc{t};
    isiAccSpec = testData.ISIaccSpec{t};
    isiRespRT = testData.isiRT{t};
    
    fprintf(fid, formatString, t, run, trial, onset, dur, cond, target,...
        associate, resp, acc, accSpec, respRT, isiResp, isiAcc,...
        isiAccSpec, isiRespRT);
    
end

cd(currDir);

end
