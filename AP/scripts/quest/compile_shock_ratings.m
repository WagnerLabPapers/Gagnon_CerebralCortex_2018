function [allQuestsummaryNames,allQuestsummaryScores,allQuestsummaryRTs,...
    allQuestnames_ALL,allQuestsubscales_ALL,allQuestscores_ALL,allQuestrts_ALL] = compile_shock_ratings()

EXP = 'AssocPlace';
BLOCKS = 6;
filename = [EXP, '_ShockRatings.csv'];


for block_num = 1:BLOCKS

    clearvars -except block_num filename BLOCKS EXP
    S.questionnaire_params = {'ShockBlockparams'; 'CanliArousalparams'}; % for end of block assessment

    allWraps = dir(['~/Experiments/',EXP,'/data/Quest/',EXP,'_*_block', num2str(block_num),'*.mat']);
    allWraps={allWraps(:).name};


    % Exclude some subids
    %%%%%%%%%%%%%%%%%%%%%%%
    exSubs = {'ap99'};

    allSubIDs = cellfun(@(x) x(12:15),allWraps, 'UniformOutput',false);
    
    allExInds = [];
    for exi=1:length(exSubs)
        allExInds = [allExInds find(strcmp(allSubIDs,exSubs{exi}))];
    end
    
    allWraps(allExInds) = [];
    allSubIDs(allExInds) = [];
    %%%%%%%%%%%%%%%%%%%%%%%
    

    % Start analysis for this block
    allQuestsummaryNames = {};
    allQuestsummaryScores = [];
    allQuestsummaryRTs = [];

    allQuestnames_ALL = {'P-subID'};
    allQuestsubscales_ALL = {'P-subID'};
    allQuestscores_ALL = [];
    allQuestrts_ALL = [];

    
    % Go through each subject
    for wi=1:length(allWraps)

        qData = load(fullfile(allWraps{wi})); % load in data
        load(allWraps{wi});

    %     % hack around the messed up old files.
    %     allWraps = dir('~/Experiments/AssocMem/data/Quest/AssocMem_*_post1*.mat');
    %     allWraps={allWraps(:).name};

        if ~isfield(qData(1),'QuestsummaryScores')

            qData(1).QuestsummaryScores = [];
            qData(1).QuestsummaryNames = [];
            qData(1).QuestsummaryRTs = [];


            for sessNum = 1:length(qData(1).Questsession)

                tmpMissedTrials = find(qData(1).Questsession(sessNum).myQuestresults.Rating==-1);

                qData(1).Questsession(sessNum).myQuestresults.isReversed = qData(1).Questpars(sessNum).myQuestparams.Qreverse'>0;    % is this question supposed to be reverse-coded? (0/1)
                qData(1).Questsession(sessNum).myQuestresults.adjustedRating = abs(qData(1).Questpars(sessNum).myQuestparams.Qreverse'-qData(1).Questsession(sessNum).myQuestresults.Rating);    % rating adjusted for reverse-coding

                % Imputing mean for missed trials:
                qData(1).Questsession(sessNum).myQuestresults.adjustedRating(tmpMissedTrials) = nan;
                qData(1).Questsession(sessNum).myQuestresults.RT(tmpMissedTrials,1) = nan;
                qData(1).Questsession(sessNum).myQuestresults.adjustedRating(tmpMissedTrials) = nanmean(qData(1).Questsession(sessNum).myQuestresults.adjustedRating);

                qData(1).Questsession(sessNum).Questsummary = [];
                qData(1).Questsession(sessNum).QuestsummaryRT = [];

                allUniqueSubScales = unique(qData(1).Questpars(sessNum).myQuestparams.QsubscaleNums');
                qData(1).Questsession(sessNum).Questsummary = [];
                curSubScaleNames = {};
                for ssi = 1:(length(allUniqueSubScales)+1)  % each subscale plus scale total
                    if length(allUniqueSubScales)==1
                        if ssi==2
                            qData(1).Questsession(sessNum).Questsummary(ssi-1) = sum(qData(1).Questsession(sessNum).myQuestresults.adjustedRating);
                            qData(1).Questsession(sessNum).QuestsummaryRT(ssi-1) = nanmean(qData(1).Questsession(sessNum).myQuestresults.RT(:,1));
                            qData(1).QuestsummaryScores = ...
                                [qData(1).QuestsummaryScores qData(1).Questsession(sessNum).Questsummary];
                            curSubScaleNames{ssi-1} = [S.questionnaire_params{sessNum}(1:end-6),'-Total'];
                            qData(1).QuestsummaryRTs = ...
                                [qData(1).QuestsummaryRTs qData(1).Questsession(sessNum).QuestsummaryRT];
                            qData(1).QuestsummaryNames = [qData(1).QuestsummaryNames curSubScaleNames];
                        end
                    elseif ssi<=length(allUniqueSubScales)
                        curSSinds = find(qData(1).Questpars(sessNum).myQuestparams.QsubscaleNums'==allUniqueSubScales(ssi));
                        qData(1).Questsession(sessNum).Questsummary(ssi) = ...
                            sum(qData(1).Questsession(sessNum).myQuestresults.adjustedRating(curSSinds));
                        qData(1).Questsession(sessNum).QuestsummaryRT(ssi) = ...
                            mean(qData(1).Questsession(sessNum).myQuestresults.RT(curSSinds,1));         
                        curSubScaleNames{ssi} = [S.questionnaire_params{sessNum}(1:end-6),'-',qData(1).Questpars(sessNum).myQuestparams.QsubscaleNames{curSSinds(1)}];
                    else
                        qData(1).Questsession(sessNum).Questsummary(ssi) = ...
                            sum(qData(1).Questsession(sessNum).myQuestresults.adjustedRating);
                        qData(1).Questsession(sessNum).QuestsummaryRT(ssi) = ...
                            mean(qData(1).Questsession(sessNum).myQuestresults.RT(:,1));         

                        qData(1).QuestsummaryScores = ...
                            [qData(1).QuestsummaryScores qData(1).Questsession(sessNum).Questsummary];
                        qData(1).QuestsummaryRTs = ...
                            [qData(1).QuestsummaryRTs qData(1).Questsession(sessNum).QuestsummaryRT];

                        curSubScaleNames{ssi} = [S.questionnaire_params{sessNum}(1:end-6),'-Total'];
                        qData(1).QuestsummaryNames = [qData(1).QuestsummaryNames curSubScaleNames];
                    end
                end

            end
            save(fullfile(allWraps{wi}));

        end

        if wi==1
            allQuestsummaryNames = ['P-subID',qData(1).QuestsummaryNames];

            for sessNum = 1:length(qData(1).Questsession)
                allQuestnames_ALL = [allQuestnames_ALL,qData(1).Questpars(sessNum).myQuestparams.Qlabels'];
                allQuestsubscales_ALL = [allQuestsubscales_ALL,qData(1).Questpars(sessNum).myQuestparams.QsubscaleNames'];
            end
        end

        tmpAllRates = [];
        tmpAllRTs = [];

        for sessNum = 1:length(qData(1).Questsession)
            tmpAllRates = [tmpAllRates, qData(1).Questsession(sessNum).myQuestresults.adjustedRating];
            tmpAllRTs = [tmpAllRTs, qData(1).Questsession(sessNum).myQuestresults.RT(:,1)'];
        end

        if length(qData.p.subID) < 2
            qData.p.subID = ['0',qData.p.subID];
        end

        allQuestscores_ALL = [allQuestscores_ALL; [str2num(qData.p.subID(1:2)) tmpAllRates]];
        allQuestrts_ALL = [allQuestrts_ALL; [str2num(qData.p.subID(1:2)) tmpAllRTs]];

        allQuestsummaryScores = [allQuestsummaryScores; [str2num(qData.p.subID(1:2)) qData(1).QuestsummaryScores]];
        allQuestsummaryRTs = [allQuestsummaryRTs; [str2num(qData.p.subID(1:2)) qData(1).QuestsummaryRTs]];


        clear qData; clear curSSinds; clear curSubScaleNames;

    end
    
    % Write out to some file
    dlmwrite(filename, allQuestscores_ALL, '-append', 'delimiter', ',');

end