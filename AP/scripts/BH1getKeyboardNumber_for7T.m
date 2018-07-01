
function k = BH1getKeyboardNumber_for7T

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if (strcmp(d(n).usageName,'Keyboard')&&(d(n).vendorID==1523)); % prdocut ID laptop: 560
        k=n;
        break
    end
end