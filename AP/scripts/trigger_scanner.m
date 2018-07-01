% [time0,sp] = trigger_scanner(sp)
% --------------------------------
% usage: this script opens a serial port, sends out a pulse signal, then
% closes the serial port
%
% INPUT:
%   sp - serial port object

% OUTPUT:
%   time0 - time of pulse
%   sp - serial port object
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [time0,sp,status,err] = trigger_scanner()

status = 1;
try
    
    % Get a serial port    
    try
        sp = serial('/dev/tty.usbmodem12341','BaudRate',57600);
    catch err
        disp(err)
        return
    end
    
    
    % open the serial port
    fclose(sp); % to avoid error
    fopen(sp);
%    WaitSecs(1); % requires waiting 1 s after opening for communication
    
    fprintf(sp, '[t]'); % send pulse to trigger scanner
    time0 = GetSecs;  % get current time
    status=0;
    
    
    % close serial port
    fclose(sp);
%     delete(sp);
%     clear sp
    
catch err
    
    disp('Error occurs.')
    disp(err.message);
    time0 = nan;
    %
end
err = []

end % function
