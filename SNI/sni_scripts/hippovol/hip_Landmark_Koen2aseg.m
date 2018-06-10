%%%%%%%%%%% 1 %%%%%%%%%%%%%%%    
% Landmarks: From KOEN to ASEG %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    orig_datos = 'aseg';
    fileID = fopen([glm_datos_dir filesep structName '_' methodName '_' orig_datos '_' sufixName '.txt'],'w');
    fprintf(fileID, '%s \n', cabecera);
    % Leemos las coordenadas que tocan seg??n origen de datos
    if orig_datos == 'aseg'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    elseif orig_datos =='koen'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    elseif orig_datos =='eug1'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    end
    delimiterIn = ' '; headerlinesIn = 1;
    puntos = importdata(filename,delimiterIn,headerlinesIn);
    % OJO! de lo que apuntamos en fs hay que sumar 1 para Matlab
    for nsub = 1:length(sub)
        sub(nsub).name 
        methodName
        orig_datos
        workpath = [SUBJECTS_DIR filesep sub(nsub).name filesep 'mri'];
        cd(workpath);
        valores = zeros(1,8); % Inicializo los valores de volumen por cada sujeto a zero.

        for h=1:length(hemi)
            hemi{h}
            % Leo el volumen que toca del sujeto/hemisferio
            A = MRIread2([hemi{h} '.asegHippo.mgz']);
            K = sum_hippo_subfields(workpath, hemi{h}, 1, eliminar_list);
            
           

            % Leo el punto de corte de la matriz que he hemos leido al principio  
            punto = zeros(1,3);
            i = 0;
            for k = hemivalor3{h}
                i = i+1;
                punto(i) = puntos.data(nsub, k);
            end
            
            puntonew = round(inv(K.vox2ras) * A.vox2ras * [punto(1);punto(2);punto(3);1]);
            puntonew(3)
        end
        
    end

