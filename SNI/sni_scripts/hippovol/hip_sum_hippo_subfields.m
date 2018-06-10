function [ M ] = sum_hippo_subfields(mripath, hemi, discreto, eliminar_list)
%devuelve un volumen de freesurfer sumando todos los subfields de Koen borrando los de la lista 
%   SALIDAS:
%       M: estructura FS
%   ENTRADAS:
%       Path: donde est??n los posterior_ de las estructuras de Koen?
%       hemi: hemisferio
%       discreto = 1 si 
%       Eliminar_list: cuando lea todos los posterior_, cuales tiene que
%                       eliminar?
%   OPCIONES:    
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    
    %BORRAR, TEST
    % point = [151   138   122];
    % hemi = 'lh';
    % h = 1;
    % mripath = '/bcbl/home/home_g-m/glerma/freesurfer/subjects/TNT/TNT_DTI/S_00/mri';
    % M = MRIread2([hemi{h} '.asegHippo.mgz']);
    % M = MRIread2('/bcbl/home/home_g-m/glerma/freesurfer/subjects/TNT/TNT_DTI/S_00/mri/lh.asegHippo.mgz');
    if nargin < 3
        discreto = 0; % devuelve el mapa probabilistico
    end
    if nargin<4
        %When reading Koen delete the following
        eliminar_list = {'posterior_Left-Cerebral-Cortex.mgz'
                         'posterior_Left-Cerebral-White-Matter.mgz'
                         'posterior_left_hippocampal_fissure.mgz'
                         'posterior_Right-Cerebral-Cortex.mgz'
                         'posterior_Right-Cerebral-White-Matter.mgz'
                         'posterior_right_hippocampal_fissure.mgz'};
    end
    
    
    % Luego leemos los hippo_subfields (pero ya nos ha dicho Eugenio que el
    % right no va bien asi que es dificil que encontremos cosas
    if hemi == 'lh'
        temp1 = dir([ mripath filesep 'posterior_l*']); 
        temp2 = dir([ mripath filesep 'posterior_Left-Hip*']); 
        list_hipsubfields = cat(1, temp1, temp2); 
    elseif hemi == 'rh'
        temp3 = dir([ mripath filesep 'posterior_r*']);
        temp4 = dir([ mripath filesep 'posterior_Right-Hip*']);
        list_hipsubfields = cat(1, temp3, temp4);  
    end
    
    d = size(eliminar_list);
    for j = 1:d(1)
        a = size(list_hipsubfields);
        for i = 1:a(1) 
            if isequal(cellstr(list_hipsubfields(i).name),  cellstr(eliminar_list(j)))
                list_hipsubfields(i) = [];
                break
            end
        end    
    end
    size(list_hipsubfields);


    % leemos uno cualquiera para tener un volumen
    M = MRIread2([mripath filesep list_hipsubfields(1).name]);

    %creamos una matriz temporal para ir sumando todos los .vol de cada
    %subfield
    Mtempvol = zeros(size(M.vol));

    % Sumamos los subfields con los que nos hemos quedado
    % LEFT
    i = 1;
    for nhipsubfield = 1:length(list_hipsubfields)
            %lh_hipsubfields(nhipsubfield).name
            hipposubfield(i) = MRIread2([mripath filesep list_hipsubfields(nhipsubfield).name]);
            Mtempvol = Mtempvol + hipposubfield(i).vol;
            i = i+1;
    end

     % Thresholdeamos los valores de los voxeles
    M.vol = Mtempvol;
   
    % Si lo queremos devolver discretizado 
    if discreto == 1
        M.vol(M.vol<128)=0;
        M.vol(M.vol>=128)=1;
    end
    
end

