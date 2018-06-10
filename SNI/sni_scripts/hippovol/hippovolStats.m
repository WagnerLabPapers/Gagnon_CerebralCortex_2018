function [ABOVE BELOW Bezier Corte] = hippovolStats(structName, methodName, sufixName, SubjID, )
%fitBezierTgPlane corta las estructuras con un plano perpendicular a la curva de Bezier 
%   SALIDAS:
%       ABOVE: la matriz por encima del plano de corte (es una estructura FS lista para escribir)
%       BELOW: la matriz por debajo del plano de corte (es una estructura FS lista para escribir)
%       Bezier: es la curva de Bezier
%       Corte: devuelve el punto de corte m??s cercano, perpendicular a
%               point
%   ENTRADAS:
%       M: es el volumen que obtenemos desde MRIread(). Se puede meter MRIread directamente.
%       Point: es el landmark que hemos obtenido viendo los hipocampos, que
%               usaremos para la segmentaci??n
%       DEBUG: 0 para no visualizar, 1 para visualizar figuras
%       ShortBezier: le podemos pasar la curva si ya la tenemos (por ejemplo
%               para cortar el posterior con la misma curva que ten??amos 
%   OPCIONES: 
%       decimate: por cuanto se quiere decimar la estrucutra al calcular la
%               curva de Bezier. Por defecto= 5
%       orden: orden de la ecuaci??n utilizada para hacer el fit de la
%               curva, por defecto es 2 (cuadr??tica)
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    
    % Opciones
    %DEBUG = 1;
    decimate = 5;
    orden = 2;

    
    %BORRAR, TEST
    % point = [151   138   122];
    % hemi = {'lh', 'rh'};
    % h = 1;
    % M = MRIread([hemi{h} '.asegHippo.mgz']);
    % M = MRIread('/bcbl/home/home_g-m/glerma/freesurfer/subjects/TNT/TNT_DTI/S_00/mri/lh.asegHippo.mgz');
    
    if nargin<3
        DEBUG=1;
    end
    

    % Primero obtengo la linea para cada hipocampo con fitBezier de Eug
    
    %Obtengo el volumen de la lectura con 0s y 1s
    Mv = (M.vol > 127);
    % Lo paso a indices para poder tener el cloud
    % OJO!! cambio la X y la Y pq ind2sub devuelve al rev??s
    [Y,X,Z]=ind2sub(size(M.vol),find(M.vol>0));
    if nargin<4 %si no te paso la curva de Bezier, calculala 
        P = fitBezierToCloud_vGari(Mv, orden, decimate);  % me devuelve una linea discreta
    else
        P = ShortBezier; % en otro caso usa la que ya tengo

