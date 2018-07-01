function expParams = ShockBlockparams(w,rect,p,PrePost)
% function expParams = genericSRM(w,rect,p,PrePost)

[c] = getColors();
white = c.white;
black = c.black;
gray = c.grey;

%% Experimenter-defined parameters:

    %%% What is the Excel 5.0/95 format file name?
        xlsFile = 'ShockBlock_questions.xls';

    %%% What is the maximum number of seconds to wait for a response?
        maxRT = 20;     % seconds

    %%% What is the minimum time before response (to prevent accidental responding):
        preRTwait = 0.25;   % seconds

    %%% Do you want responses provided on a discrete scale with a keyboard (0) or an analog scale with the mouse (1)?
        analog = 1;  % 0 = digital scale (keyboard), 1 = analog scale (mouse)

    %%% Do you want a line to appear over the response options (regardless of scale type)?
        drawLine = 1;  % 0 = no line, 1 = line

    %%% How much do you want the response scale shifted back by? 
    % (for instance, if you have a 1-5 scale but want it to be 0-4 or -2-2 you can enter 1 or 3) 
        rNumShift = 0;  % shift numeric scale leftward by this # (e.g., 1 shifts 1-7 scale to 0-6)
    
    %%% What color do you want the background to be (black/white/gray)?
        bkgd = gray;
    %%% What color do you want the text to be (black/white/gray)?
        txtColor = black;

    %%% Do you want to change the size of the text for instructions, prompt, or questions?
        instructionsFontSize = 30;
        promptFontSize = 36;
        questionFontSize = 36;


%% Set up parameter variable for experiment:

    %%%% LOAD excel file and locate headings (MUST be in Excel 5.0/95 format):
[numData,txtData,rawData]=xlsread(xlsFile);

questInd = find(strcmpi(rawData,'Questions'));
optInd = find(strcmpi(rawData,'Options'));
instrInd = find(strcmpi(rawData,'Instructions'));
promptInd = find(strcmpi(rawData,'Prompt'));


% Variables needed to define task parameters:
expParams.instructions = rawData{instrInd+1,1};
expParams.Qs = rawData((questInd+1):(optInd-1),1);
expParams.scaleOptions = rawData((optInd+1):(instrInd-1),1);
if size(rawData,1)>promptInd
    expParams.prompt = rawData{promptInd+1,1};
else
    expParams.prompt = ' ';
end

% Variables for output/scoring:
expParams.Qlabels = rawData((questInd+1):(optInd-1),2);
if analog   % using 1 for reverse-scoring w/ analog
    expParams.Qreverse = cell2mat(rawData((questInd+1):(optInd-1),3));
else        % using max(scaleOptions) + 1 for reverse-scoring w/ discrete
    expParams.Qreverse = cell2mat(rawData((questInd+1):(optInd-1),3))*(length(expParams.scaleOptions)+1);
end
expParams.QsubscaleNums = cell2mat(rawData((questInd+1):(optInd-1),4));
expParams.QsubscaleNames = (rawData((questInd+1):(optInd-1),5));

    % Remaining variables:
expParams.screenRect = rect;
expParams.res = rect(3:4);
expParams.bkgd = bkgd;
expParams.txtColor = txtColor;

expParams.instrTxSize = instructionsFontSize;
expParams.promptTxSize = promptFontSize;
expParams.qTxSize = questionFontSize;

expParams.maxRT = maxRT;
expParams.preRTwait = preRTwait;

expParams.drawLine = drawLine;
expParams.analog = analog;  % 0 = digital scale (keyboard), 1 = analog scale (mouse); 
expParams.analogCursor = 4;  % 0 = arrow, 4 = I-beam; 

if (mod(length(expParams.scaleOptions),2)==1 && ~analog)    % odd-numbered scale, using digital scale
    expParams.omitMidLine = 0;  % 1 = don't show midpoint, 0 = show;
else    % even-numbered digital scale OR analog
   expParams.omitMidLine = 1;  % 1 = don't show midpoint, 0 = show; 
end
expParams.rNumShift = rNumShift;  % shift numeric scale leftward by this # (e.g., 1 shifts 1-7 scale to 0-6)



