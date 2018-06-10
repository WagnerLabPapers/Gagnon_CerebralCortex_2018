function [HEAD, POSTERIOR, BODY, TAIL] = hip_AcquMNIInsausti(d, M, sp)
%hip_AcquMNIInsausti Method based on MNI/Talairach Transformation, Landmark,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, sp);
%   
%   07/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com



   % Para cada hippo-subfield, para cada hemisferio, lo leo, y escribo cada ROI en su sitio
   % Lo importante en este caso es que tenemos 8 limites distintos para las
   % divisiones, 4 divisiones x 2 hemisferios (deMaster y Ghetti reportan
   % coordenadas Y diferentes por el tilt que hay en la cabeza MNI305)

   % Los datos que se han usado han sido los siguientes:
   % HEMI |    head    |   ext_head   |    ext_tail    |     tail   |
   % -----+------------+--------------+----------------+------------|
   % Left |+inf    -20 |-21        -27|-28          -35|-36     -inf|
   % Right|+inf    -18 |-19        -25|-26          -33|-34     -inf|
   % 


   % Crear la tabla con la informaci?n para poder ser le?da y tratada
   % autom?ticamente.
   % hemi head_limit tail_limit
   boundaries_head{1} = -20; % left hemi
   boundaries_tail{1} = -36;
   boundaries_head{2} = -18; % right hemi
   boundaries_tail{2} = -34;

   % Primero leo las matrices de transformacion para el sujeto en curso
   % Estas formulas est?n en el manual de FS. 

    HEAD = M; POSTERIOR = M; BODY = M; TAIL = M;

   % Nos interesa es el espacio RAS para luego poder meterlo en la f?rmula
   % de arriba. Doug dice que lo haga asi:
   % mni305 = TalXFM*A.vox2ras1 * [i;j;k;1]

   TalXFM = xfm_read([sp filesep 'transforms' filesep 'talairach.xfm']);

   [I, J, K] = size(M.vol); % Leemos el tama??o de cada hippo-subfield, que es siempre el mismo, pero lo inicializo siempre por si acaso.
   % El for va a pasar por absolutamente todos los voxeles del cubo en
   % donde est? el hippo-subfield, y escribir? todos los voxeles que
   % cumplan con la condici?n y el resto los dejar? igual.
       for i=1:I
            for j=1:J
                for k=1:K
                   MNI305 = TalXFM * M.vox2ras1 * [i;j;k;1]; % En cada voxel calculo la coordenada y hago el if para decidir si lo dejo como estaba o lo sobreescribo con un cero.
                   if MNI305(2) <  boundaries_head{h} HEAD.vol(i,j,k) = 0;end
                   if MNI305(2) >= boundaries_head{h} POSTERIOR.vol(i,j,k) = 0;end
                   if MNI305(2) >= boundaries_head{h} BODY.vol(i,j,k) = 0; end
                   if MNI305(2) <= boundaries_tail{h} BODY.vol(i,j,k) = 0; end
                   if MNI305(2) >  boundaries_tail{h} TAIL.vol(i,j,k) = 0; end
                end 
            end 
       end 

   
        N = M;
        N.vol=zeros(size(N.vol));
        N.vol=HEAD.vol + BODY.vol + TAIL.vol;
        if ~isequal(N.vol, M.vol)
            error('Sum of the parts not equal to original')
        end
   


    % Obtengo las estadisticas y las escribo en un archivo (valido que en
    % al trocearlos no se haya perdido ni un voxel
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Sum of the parts not equal to original')
    end
    

end

