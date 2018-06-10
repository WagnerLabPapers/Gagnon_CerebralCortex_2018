function [allQuestsummaryNames,allQuestsummaryScores,allQuestsummaryRTs,...
    allQuestnames_ALL,allQuestsubscales_ALL,allQuestscores_ALL,allQuestrts_ALL] = AS_SRMscoreCompile_SG()

clear all;
numSubj = 24;
S.questionnaire_params = {'BISBASparams','STAI_Sparams','NEO_FFI_Neurotparams'}; % for end of block assessment

allWraps = dir('~/Experiments/AssocMem/data/Quest/AssocMem_*_post1*.mat');
allWraps={allWraps(:).name};


% % exSubs = {'2004b','2019b','2021b'}
% exSubs = {};

% allSubIDs = cellfun(@(x) x(10:11),allWraps, 'UniformOutput',false);
% 
% allExInds = [];
% for exi=1:length(exSubs)
%     allExInds = [allExInds find(strcmp(allSubIDs,exSubs{exi}))];
% end
% 
% allWraps(allExInds) = [];
% allSubIDs(allExInds) = [];
allSubIDs = 1:numSubj;

allQuestsummaryNames = {};
allQuestsummaryScores = [];
allQuestsummaryRTs = [];

allQuestnames_ALL = {'P-subID'};
allQuestsubscales_ALL = {'P-subID'};
allQuestscores_ALL = [];
allQuestrts_ALL = [];

for wi=1:length(allWraps)
    
    AssocMem = load(fullfile(allWraps{wi})); % load in AssocMem
    load(allWraps{wi}, 'AssocMem');
    
%     % hack around the messed up old files.
%     allWraps = dir('~/Experiments/AssocMem/data/Quest/AssocMem_*_post1*.mat');
%     allWraps={allWraps(:).name};
        
    if ~isfield(AssocMem(1),'QuestsummaryScores')
        
        AssocMem(1).QuestsummaryScores = [];
        AssocMem(1).QuestsummaryNames = [];
        AssocMem(1).QuestsummaryRTs = [];
        
        
        for sessNum = 1:length(AssocMem(1).Questsession)

            tmpMissedTrials = find(AssocMem(1).Questsession(sessNum).myQuestresults.Rating==-1);

            AssocMem(1).Questsession(sessNum).myQuestresults.isReversed = AssocMem(1).Questpars(sessNum).myQuestparams.Qreverse'>0;    % is this question supposed to be reverse-coded? (0/1)
            AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating = abs(AssocMem(1).Questpars(sessNum).myQuestparams.Qreverse'-AssocMem(1).Questsession(sessNum).myQuestresults.Rating);    % rating adjusted for reverse-coding
            
                % Imputing mean for missed trials:
            AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating(tmpMissedTrials) = nan;
            AssocMem(1).Questsession(sessNum).myQuestresults.RT(tmpMissedTrials,1) = nan;
            AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating(tmpMissedTrials) = nanmean(AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating);
            
            AssocMem(1).Questsession(sessNum).Questsummary = [];
            AssocMem(1).Questsession(sessNum).QuestsummaryRT = [];

            allUniqueSubScales = unique(AssocMem(1).Questpars(sessNum).myQuestparams.QsubscaleNums');
            AssocMem(1).Questsession(sessNum).Questsummary = [];
            curSubScaleNames = {};
            for ssi = 1:(length(allUniqueSubScales)+1)  % each subscale plus scale total
                if length(allUniqueSubScales)==1
                    if ssi==2
                        AssocMem(1).Questsession(sessNum).Questsummary(ssi-1) = sum(AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating);
                        AssocMem(1).Questsession(sessNum).QuestsummaryRT(ssi-1) = nanmean(AssocMem(1).Questsession(sessNum).myQuestresults.RT(:,1));
                        AssocMem(1).QuestsummaryScores = ...
                            [AssocMem(1).QuestsummaryScores AssocMem(1).Questsession(sessNum).Questsummary];
                        curSubScaleNames{ssi-1} = [S.questionnaire_params{sessNum}(1:end-6),'-Total'];
                        AssocMem(1).QuestsummaryRTs = ...
                            [AssocMem(1).QuestsummaryRTs AssocMem(1).Questsession(sessNum).QuestsummaryRT];
                        AssocMem(1).QuestsummaryNames = [AssocMem(1).QuestsummaryNames curSubScaleNames];
                    end
                elseif ssi<=length(allUniqueSubScales)
                    curSSinds = find(AssocMem(1).Questpars(sessNum).myQuestparams.QsubscaleNums'==allUniqueSubScales(ssi));
                    AssocMem(1).Questsession(sessNum).Questsummary(ssi) = ...
                        sum(AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating(curSSinds));
                    AssocMem(1).Questsession(sessNum).QuestsummaryRT(ssi) = ...
                        mean(AssocMem(1).Questsession(sessNum).myQuestresults.RT(curSSinds,1));         
                    curSubScaleNames{ssi} = [S.questionnaire_params{sessNum}(1:end-6),'-',AssocMem(1).Questpars(sessNum).myQuestparams.QsubscaleNames{curSSinds(1)}];
                else
                    AssocMem(1).Questsession(sessNum).Questsummary(ssi) = ...
                        sum(AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating);
                    AssocMem(1).Questsession(sessNum).QuestsummaryRT(ssi) = ...
                        mean(AssocMem(1).Questsession(sessNum).myQuestresults.RT(:,1));         

                    AssocMem(1).QuestsummaryScores = ...
                        [AssocMem(1).QuestsummaryScores AssocMem(1).Questsession(sessNum).Questsummary];
                    AssocMem(1).QuestsummaryRTs = ...
                        [AssocMem(1).QuestsummaryRTs AssocMem(1).Questsession(sessNum).QuestsummaryRT];

                    curSubScaleNames{ssi} = [S.questionnaire_params{sessNum}(1:end-6),'-Total'];
                    AssocMem(1).QuestsummaryNames = [AssocMem(1).QuestsummaryNames curSubScaleNames];
                end
            end

        end
        save(fullfile(allWraps{wi}),'AssocMem');

    end
    
    if wi==1
        allQuestsummaryNames = ['P-subID',AssocMem(1).QuestsummaryNames];

        for sessNum = 1:length(AssocMem(1).Questsession)
            allQuestnames_ALL = [allQuestnames_ALL,AssocMem(1).Questpars(sessNum).myQuestparams.Qlabels'];
            allQuestsubscales_ALL = [allQuestsubscales_ALL,AssocMem(1).Questpars(sessNum).myQuestparams.QsubscaleNames'];
        end
    end

    tmpAllRates = [];
    tmpAllRTs = [];

    for sessNum = 1:length(AssocMem(1).Questsession)
        tmpAllRates = [tmpAllRates, AssocMem(1).Questsession(sessNum).myQuestresults.adjustedRating];
        tmpAllRTs = [tmpAllRTs, AssocMem(1).Questsession(sessNum).myQuestresults.RT(:,1)'];
    end

    if length(AssocMem.p.subID) < 2
        AssocMem.p.subID = ['0',AssocMem.p.subID];
    end
    
    allQuestscores_ALL = [allQuestscores_ALL; [str2num(AssocMem.p.subID(1:2)) tmpAllRates]];
    allQuestrts_ALL = [allQuestrts_ALL; [str2num(AssocMem.p.subID(1:2)) tmpAllRTs]];

    allQuestsummaryScores = [allQuestsummaryScores; [str2num(AssocMem.p.subID(1:2)) AssocMem(1).QuestsummaryScores]];
    allQuestsummaryRTs = [allQuestsummaryRTs; [str2num(AssocMem.p.subID(1:2)) AssocMem(1).QuestsummaryRTs]];

  
    clear AssocMem; clear curSSinds; clear curSubScaleNames;
    
end