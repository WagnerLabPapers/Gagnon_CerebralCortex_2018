function [freerespData] = ap_behavAnalysis_test(subID)
% Outputs trial information for each freeresp run
[S,thePath] = setupScript();

% Load in mat file
currDir = pwd;
cd(fullfile(thePath.data,subID));
freerespMat = [subID '_test_cat.mat']; % use this instead of concat bc it has resp mapping
% freerespMat = [subID '_freeresp_cat_v2.mat']; % use this instead of concat bc it has resp mapping
load(freerespMat);
nRuns = size(testData,2);
freerespData = testData(nRuns); % change!

% Determine accuracy
trialsPerRun = 42;
totalTrials = length(freerespData.onset);

% If NO 5 button box
freerespData.respOpts = {'1!', '2@', '3#', '4$', '6^'};

for t = 1:totalTrials
    
    if freerespData.onset(t) > 0
    
          %% ADD IN FOR MISTAKEN BUTTONS
          %%
        if t < 43
            freerespData.respCodes = {'F'    'TO'    'TO'   'TI'    'TI'};
            freerespData.respCodes_conf = {'F'    'TO_Hi'    'TO_Lo'    'TI_Hi'    'TI_Lo'};
        else 
            freerespData.respCodes = {'F'    'TI'    'TI'    'TO'    'TO'};
            freerespData.respCodes_conf = {'F'    'TI_Hi'    'TI_Lo'   'TO_Hi'    'TO_Lo'};
        end
        
        % convert button box resp during stim presentation to cond code
        % (if made more than one resp, take *LAST* resp)
        freerespData.stimCodedResp{t} = codeBehavResp(freerespData.stimResp{t}, freerespData.respCodes, freerespData.respOpts, 'last');
        freerespData.stimCodedResp_conf{t} = codeBehavResp(freerespData.stimResp{t}, freerespData.respCodes_conf, freerespData.respOpts, 'last');

        % if made more than one resp during stim presentation, take *LAST* RT
        freerespData.stimRT{t} = freerespData.stimRT{t}(end);


        % convert button box resp during ISI to cond code
        % (if made more than one resp, take *FIRST* resp)
        freerespData.isiCodedResp{t} = codeBehavResp(freerespData.isiResp{t}, freerespData.respCodes, freerespData.respOpts, 'first');
        freerespData.isiCodedResp_conf{t} = codeBehavResp(freerespData.isiResp{t}, freerespData.respCodes_conf, freerespData.respOpts, 'first');

        
        % if made more than one resp during ISI, take *FIRST* RT
        freerespData.isiRT{t} = freerespData.isiRT{t}(1);


        % depending on resp, determine accuracy
        if strcmp(freerespData.corrResp{t}, 'F') % foil trials

            % responses during stim
            if strcmp(freerespData.stimCodedResp(t),'F')
                freerespData.acc{t} = 'CR'; % correct rejection
                freerespData.accSpec{t} = 'CR'; % correct rejection
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Hi')
                freerespData.acc{t} = 'FA'; % false alarm
                freerespData.accSpec{t} = 'FAI_Hi';
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Lo')
                freerespData.acc{t} = 'FA'; % false alarm
                freerespData.accSpec{t} = 'FAI_Lo';
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Hi')
                freerespData.acc{t} = 'FA'; % false alarm
                freerespData.accSpec{t} = 'FAO_Hi';
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Lo')
                freerespData.acc{t} = 'FA'; % false alarm
                freerespData.accSpec{t} = 'FAO_Lo';    
            else
                freerespData.acc{t} = 'NR'; % no response
                freerespData.accSpec{t} = 'NR'; % no response
            end

            % responses during ISI
            if strcmp(freerespData.isiCodedResp(t),'F')
                freerespData.ISIacc{t} = 'CR'; % correct rejection
                freerespData.ISIaccSpec{t} = 'CR'; % correct rejection
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Hi')
                freerespData.ISIacc{t} = 'FA'; % false alarm
                freerespData.ISIaccSpec{t} = 'FAI_Hi';
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Lo')
                freerespData.ISIacc{t} = 'FA'; % false alarm
                freerespData.ISIaccSpec{t} = 'FAI_Lo';
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Hi')
                freerespData.ISIacc{t} = 'FA'; % false alarm
                freerespData.ISIaccSpec{t} = 'FAO_Hi';
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Lo')
                freerespData.ISIacc{t} = 'FA'; % false alarm
                freerespData.ISIaccSpec{t} = 'FAO_Lo';    
            else
                freerespData.ISIacc{t} = 'NR'; % no response
                freerespData.ISIaccSpec{t} = 'NR'; % no response
            end

        elseif strcmp(freerespData.corrResp{t}, 'TI') % target indoor trials

            if strcmp(freerespData.stimCodedResp(t),'F')
                freerespData.acc{t} = 'M'; % miss
                freerespData.accSpec{t} = 'MI'; % indoor miss
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Hi')
                freerespData.acc{t} = 'H'; % hit
                freerespData.accSpec{t} = 'HI_Hi'; % hi conf indoor hit
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Lo')
                freerespData.acc{t} = 'H'; % hit
                freerespData.accSpec{t} = 'HI_Lo'; % lo conf indoor hit
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Hi')
                freerespData.acc{t} = 'SM'; % source miss
                freerespData.accSpec{t} = 'SMI_Hi'; % hi conf source miss
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Lo')
                freerespData.acc{t} = 'SM'; % false alarm
                freerespData.accSpec{t} = 'SMI_Lo';    
            else
                freerespData.acc{t} = 'NR'; % no response
                freerespData.accSpec{t} = 'NR'; % no response
            end

            % responses during ISI
            if strcmp(freerespData.isiCodedResp(t),'F')
                freerespData.ISIacc{t} = 'M'; % miss
                freerespData.ISIaccSpec{t} = 'MI'; % indoor miss
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Hi')
                freerespData.ISIacc{t} = 'H'; % hit
                freerespData.ISIaccSpec{t} = 'HI_Hi'; % hi conf indoor hit
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Lo')
                freerespData.ISIacc{t} = 'H'; % hit
                freerespData.ISIaccSpec{t} = 'HI_Lo'; % lo conf indoor hit
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Hi')
                freerespData.ISIacc{t} = 'SM'; % source miss
                freerespData.ISIaccSpec{t} = 'SMI_Hi'; % hi conf source miss
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Lo')
                freerespData.ISIacc{t} = 'SM'; % false alarm
                freerespData.ISIaccSpec{t} = 'SMI_Lo';   
            else
                freerespData.ISIacc{t} = 'NR'; % no response
                freerespData.ISIaccSpec{t} = 'NR'; % no response
            end

        elseif strcmp(freerespData.corrResp{t}, 'TO') % target outdoor trials

            if strcmp(freerespData.stimCodedResp(t),'F')
                freerespData.acc{t} = 'M'; % miss
                freerespData.accSpec{t} = 'MI'; % indoor miss
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Hi')
                freerespData.acc{t} = 'H'; % hit
                freerespData.accSpec{t} = 'HO_Hi'; % hi conf outdoor hit
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TO_Lo')
                freerespData.acc{t} = 'H'; % hit
                freerespData.accSpec{t} = 'HO_Lo'; % lo conf outdoor hit
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Hi')
                freerespData.acc{t} = 'SM'; % source miss
                freerespData.accSpec{t} = 'SMO_Hi'; % hi conf source miss
            elseif strcmp(freerespData.stimCodedResp_conf(t),'TI_Lo')
                freerespData.acc{t} = 'SM'; % false alarm
                freerespData.accSpec{t} = 'SMO_Lo';    
            else
                freerespData.acc{t} = 'NR'; % no response
                freerespData.accSpec{t} = 'NR'; % no response
            end

            % responses during ISI
            if strcmp(freerespData.isiCodedResp(t),'F')
                freerespData.ISIacc{t} = 'M'; % miss
                freerespData.ISIaccSpec{t} = 'MI'; % indoor miss
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Hi')
                freerespData.ISIacc{t} = 'H'; % hit
                freerespData.ISIaccSpec{t} = 'HO_Hi'; % hi conf outdoor hit
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TO_Lo')
                freerespData.ISIacc{t} = 'H'; % hit
                freerespData.ISIaccSpec{t} = 'HO_Lo'; % lo conf outdoor hit
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Hi')
                freerespData.ISIacc{t} = 'SM'; % source miss
                freerespData.ISIaccSpec{t} = 'SMO_Hi'; % hi conf source miss
            elseif strcmp(freerespData.isiCodedResp_conf(t),'TI_Lo')
                freerespData.ISIacc{t} = 'SM'; % false alarm
                freerespData.ISIaccSpec{t} = 'SMO_Lo';   
            else
                freerespData.ISIacc{t} = 'NR'; % no response
                freerespData.ISIaccSpec{t} = 'NR'; % no response
            end
        end
    end    
end

% Save new mat file with accuracy info
save([subID '_test_cat_acc.mat'],'freerespData');

% Create txt file
freerespTxt = [subID '_behav_freeresp.csv'];
fid = fopen(freerespTxt,'wt');
fprintf(fid, ['index,run,trial,onset,duration,cond,shockCond,shockTrial,target,',...
    'associate,resp,acc,accSpec,respRT,ISIresp,ISIacc,',...
    'ISIaccSpec,ISIrespRT\n']);
formatString = ['%d,%d,%d,%.4f,%.4f,%s,%s,%d,%s,',...
    '%s,%s,%s,%s,%.4f,%s,%s,',...
    '%s,%.4f\n'];


for t = 1:totalTrials
    if freerespData.onset(t) > 0
        run = freerespData.block(t);
        trial = t - trialsPerRun*(run - 1);
        onset = freerespData.onset(t);
        dur = freerespData.dur(t);
        cond = freerespData.cond{t};
        shockCond = freerespData.shockCond{t};
        shockTrial = freerespData.shockTrial(t);
        target = freerespData.wordShown{t};
        % determine associate
        if strcmp(cond,'F')
            associate = 'foil';
        else
            aIdx = find(strcmp(target,freerespData.wordShown));
            associate = freerespData.imgName{aIdx};
        end
        resp = freerespData.stimCodedResp{t};
        acc = freerespData.acc{t};
        accSpec = freerespData.accSpec{t};
        respRT = freerespData.stimRT{t};
        isiResp = freerespData.isiCodedResp{t};
        isiAcc = freerespData.ISIacc{t};
        isiAccSpec = freerespData.ISIaccSpec{t};
        isiRespRT = freerespData.isiRT{t};
        
        fprintf(fid, formatString, t, run, trial, onset, dur, cond, shockCond, shockTrial, target,...
            associate, resp, acc, accSpec, respRT, isiResp, isiAcc,...
            isiAccSpec, isiRespRT);
    end    
end

cd(currDir);

end
