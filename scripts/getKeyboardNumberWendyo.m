
function k = getKeyboardNumberWendyo

d=PsychHID('Devices');
k = 0;

% 119 wendyo
% 537 ari
for n = 1:length(d)
        if (strcmp(d(n).usageName,'Keyboard'))&&(d(n).version==537); % laptop keyboard
        k = n;
        break
    end
end