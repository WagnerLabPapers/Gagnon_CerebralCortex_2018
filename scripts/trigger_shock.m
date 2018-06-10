% [time0,sp] = trigger_shock(sp)
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
% NOTES: this script requires waiting 1 s before it runs; call it
% accordingly!! 
%
% author: Kelly, kelhennigan@gmail.com, 16-May-2014
% edited by Steph, sgagnon@stanford.edu, 18-May-2014
% based on Bob's code for triggering the scanner using a serial port & from
% ArduinoDoScan.m (vista lab code)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [time0,sp,err] = trigger_shock()

try
    
    % Get a serial port    
    try
        % don't run this line twice otherwise you might have some problems...
%         sp = serial('/dev/tty.usbmodem1411','BaudRate',57600);
        sp = serial('/dev/tty.usbmodem1421','BaudRate',57600);
    catch err
        disp(err)
        return
    end
    
    set(sp, 'Terminator', 'CR'); % change the terminator property of the serial port to make it faster
    
    % open the serial port
    fclose(sp); % to avoid error
    fopen(sp);
    WaitSecs(2); % requires waiting 1 s after opening for communication
    
%     fprintf(sp, 't'); % send pulse to trigger shock device
    fprintf(sp, 't\r'); % send pulse to trigger shock device
    time0 = GetSecs;  % get current time
    
    
    % close serial port
    % if you disconnect arduino before closing the port, matlab will be shut
    % down suddenly.
    fclose(sp);
    delete(sp);
%     clear sp

    
catch err
    
    disp('Error occurs.')
    disp(err.message);
    time0 = nan;
end

err = []

end % function
