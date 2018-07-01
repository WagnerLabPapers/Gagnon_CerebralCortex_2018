function [whichKey, rt] = SG_collectResponse(responseWait,deviceNum,keyArray)

%% Currently set to return after button press

% GetSecs returns the current time in seconds to high precision. So
% setting responseExit equal to GetSecs + corrOrIncorrWait means that the
% subject will have responseTime number of seconds to answer. Note that
% corrOrIncorrWait is an input argument to this function, specified wherever it
% is called (viz., esp.m).
% keyArray

FlushEvents;


if nargin > 1
    dGiven = 1;
else
    dGiven = 0;
end


responseExit = GetSecs + responseWait;

% Store the time of stimulus onset in t1, to be used below to record rt.

t1 = GetSecs;
t2 = 0;

% Set keyIsDown, whichKey, and rt all to default values. If the subject
% doesn't respond within responseTime number of seconds for any given
% trial, whichKey and rt are recorded as the default values, to indicate
% that no response was given.

keyIsDown = 0;
whichKey = NaN;
rt = NaN;

% Limit the amount of time the subject has for a response by using a
% while loop. The idea is to wait for a response (i.e., loop through the
% code within the while loop) while the current time (GetSecs) is less
% than responseExit, which was set above.

while ((GetSecs < responseExit) && isnan(whichKey(1)))

    % If the user is not pressing a key (i.e., if keyIsDown equals
    % 0), then run the code witin the conditional (i.e., "poll" for
    % a response). This is necessary so that the while loop will run
    % until responseExit, while not writing over the subject's
    % response and rt after they have already responded.

    if ~keyIsDown

        % Check the state of the keyboard using the function KbCheck.
        % KbCheck returns three arguments, which are stored as
        % variables. The first argument (keyIsDown) registers as 1 if
        % the subject is pressing a key, and 0 if the subject is not
        % pressing a key. The second argument (t2) registers the time of
        % the response in seconds, which will be used to record the rt
        % below. The third argument (keyCode) registers which key the
        % user pressed in a non-user-friendly but maximally accurate way
        % by using a large array. See 'help KbCheck' for details.
        if dGiven
            [keyIsDown, t2, keyCode] = KbCheck(deviceNum);
        else
            [keyIsDown, t2, keyCode] = KbCheck;
        end
        % If the user is pressing a key (i.e., if keyIsDown equals 1),
        % then run the code witin the conditional (i.e., convert
        % the keyCode to a key name)..

        if keyIsDown

            % This is a useful little hack. If the user holds down a
            % key or presses it several time, KbCheck will report
            % multiple events. To condense these multiple events
            % into a single event, we wait until all keys have been
            % released before recording the response. This is done
            % using the following while loop. As long as the user is
            % still pressing a key after having first pressed it
            % (either because they're holding it in or because they
            % pressed it again after they first pressed it), this
            % loop will keep the conditional from continuing. So, as
            % soon as the key is released (either after its second
            % press or after it was pressed again after the initial
            % press), the while loop ends and allows the rest of the
            % conditional to proceed.
            if dGiven
                while KbCheck(deviceNum); end
            else
                while KbCheck; end
            end

            % Translate the non-user-friendly keyCode into the name
            % of that key.
            whichKey = KbName(keyCode);
            % The 'break' command breaks out of the while loop
            % prematurely so that the user doesn't have to wait the
            % full responseExit number of seconds, if they respond
            % sooner than that.

            % break

            % End of the conditional that gets the subject's response, if
            % they are pressing a key.

        end

        % End of conditional that polls for response.

    end

    % This 'WaitSecs' function ensures that the CPU doesn't get
    % overloaded while waiting for a response. .001s is a reasonable
    % amount of time to wait because you're unlikely to miss the
    % user's response in that short amount of time. But it's still
    % long enough to take some load off the CPU so that the program
    % doesn't crash while repeatedly going through the loop.

    WaitSecs(0.001);

    % End of while loop that waits for the subject's response.

    if iscell(whichKey)
        whichKey = whichKey{1};
    end
    %%%% FORCES keys to be numeric if keyArray passed!!!!
    if ~isnan(whichKey)
        if (exist('keyArray','var') && isempty(str2num(whichKey(1)))) || ...
                (exist('keyArray','var') && ischar(whichKey(1)) &&(isempty(find(keyArray==str2num(whichKey(1))))))
            keyIsDown = 0;
            whichKey = nan;
        end
    end

    FlushEvents;

end

if isnan(whichKey(1))   % if timed out!
    whichKey = -1;
elseif exist('keyArray','var')
    whichKey = find(keyArray == str2num(whichKey(1)));
    if isempty(whichKey)
        whichKey = -1;
    end
elseif ischar(whichKey(1))
    %whichKey = str2num(whichKey(1)); %if only collecting numbers
    whichKey = whichKey(1);
else
    whichKey = whichKey(1);
end
rt = (t2 - t1);

return