function [codedResp] =  codeBehavResp(keys, respCodes, respOpts, first_last)

numeric_inputs = 1;

if numeric_inputs
    % strip just numbers out of keys pressed
    keys = str2double(regexprep(keys,'\D','')); 
    keys = num2str(keys); % convert back to string

    for iOpt = 1:length(respOpts)
        respOpts{iOpt} = num2str(str2double(regexprep(respOpts{iOpt},'\D','')));
    end
end
    
switch first_last
    case 'first' % take first response
        if length(keys) > 1
            for i = 1:length(respOpts)
                if strcmp(keys(1), respOpts{i})
                    codedResp = respCodes{i};
                    return
                end
            end
            codedResp = 'NR';
        elseif length(keys) == 1
            for i = 1:length(respOpts)
                if strcmp(keys, respOpts{i})
                    codedResp = respCodes{i};
                    return
                end
            end
            codedResp = 'NR';
        else
            codedResp = 'NR';
        end
        
    case 'last' % take last response
        if length(keys) > 1
            for i = 1:length(respOpts)
                if strcmp(keys(end-1), respOpts{i})
                    codedResp = respCodes{i};
                    return
                end
            end
            codedResp = 'NR';
        elseif length(keys) == 1
            for i = 1:length(respOpts)
                if strcmp(keys, respOpts{i})
                    codedResp = respCodes{i};
                    return
                end
            end
            codedResp = 'NR';
        else
            codedResp = 'NR';
        end
end