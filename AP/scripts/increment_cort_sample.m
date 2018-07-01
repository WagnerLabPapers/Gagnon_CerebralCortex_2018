function [next_sample] = increment_cort_sample(cort_times, samples_taken)
% take the cort times, number of samples taken, and determine when to take
% the next sample

total_samples = length(cort_times);
never_sample = 600*60; % unreachable time, for when collection done

% increment if haven't taken all samples
if samples_taken < total_samples
    next_sample = cort_times(samples_taken + 1);
else % if samples taken => total_samples
    next_sample = never_sample;
end


end

