triggerport_7t = '/dev/tty.USA19H142P1.1';

trigger_7t = serial(triggerport_7t);
fopen(trigger_7t);

fprintf(trigger_7t, 'i');
idn = fscanf(trigger_7t);

fclose(s1);