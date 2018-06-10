function [keys] = testButtonBox(time)

% time = time to wait (s)
% e.g., [keys] = testButtonBox(5) to get key presses over 5 s, from each
% device (scanner button box + non-specific button box or keyboard)

deviceNum = getBoxNumber;

goTime = 0;
startTime = GetSecs;
goTime = goTime + time;  

[keys, ~] = recordKeys(startTime,goTime,deviceNum);


goTime = 0;
startTime = GetSecs;
goTime = goTime + time;  

[keys_q, ~] = recordKeys(startTime,goTime,-1);
keys_q
