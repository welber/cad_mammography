clear;
clc;

%% define quais intancias serão utilizadas 

    %--todas as instancias (151 e 152 são outliers)
    %instancias = [1:150, 153:322]; name=['todas'];
    % balanceado para 104 instancias de cada classe 
    %instancias = [1:56,59:102,105:110,113:150,153:162,165:322];name=['balanceado'];
    %--simulação da extração de caracteristicas
    instancias = 1:2; name=['teste'];
    %--43 instancias para comparaçao com o artigo a1
    %instancias = [6 9 11 26 27 60 77 78 131 133 139 140 143 153 7 84 14 16 20 74 24 31 41 42 56 55 45 51 3 4 37 38 53 54 61 67 68 106 108 109 112 129 138]; name=['art44'];


%% define qual base será utilizada

    % base com remoção do musculo peitoral e etiquetas
    %base = ['./MIAS_PRE_PROC/']; name=[name,'-preproc'];

    % base com ROIS de 300x300
    base = ['./MIAS_300_300/']; name=[name,'-rois'];


%% define a quantidade de folds na validação cruzada
    folds = 10;

    
%% define quais os extratores de caracteristicas utilizados (0 inativo e 1 ativo)    
% em alguns é necessário também definir os parametros    

    % 9 caracteristicas estatisticas conforme o artigo A1 2010
    estatisticoA1 = 1;
    % 9 caracteristicas estatisticas conforme o artigo A1 2010 sem o fundo
    estatisticoA1sem0 = 0;
    % 7 caracteristicas estatisticas conforme o artigo B1 2007
    estatisticoB1 = 0;
    % textura a partir da matriz de ocorrencias, a quantidade de caracteristicas 
    vizinhanca = [0 1]; % [0 1; 0 2; 0 3; 0 4]
    texcoocorrencia = 0;
    % momentos invariantes
    momentosinv = 0;
    % textura expectro
    expectro = 0;
    % PCA
    componentes = 1:20;  %numero de componentes analizados
    pca = 0;
    %2DPCA sobre a matrix de co-ocorrencia
    componentes = 1:20;  %numero de componentes analizados
    doisdpcaocorr = 0;
    %2DPCA sobre a imagem
    componentes = 1:20;  %numero de componentes analizados
    doisdpca = 0;
    
%% carrega os rotulos das instancias
 %
 %  F  Fatty            70  1
 %  G  Fatty-glandular  71  2     
 %  D  Dense-glandular  68  3

    load('rotulos_mias.mat')


%% extração de caracteristicas das instancias selecinadas

qtinstancias = 0;   %indice atual do vetor de caracteristicas
pca = 0;            % altere para 1 ao utilizar PCA 
doisdpca = 0;       % açtere para 1 ao utilizar 2DPCA
caracteristicas = [];


for i = [instancias]
    
    qtinstancias = qtinstancias+1;
    
    % seleciona o rotulo
    rotulos2(qtinstancias,1) = rotulos(i,1);
    
    % nome da imagem a ser carregada
    if i < 10
        imagem = [base, 'mdb00',int2str(i)];
    elseif i < 100
        imagem = [base, 'mdb0',int2str(i)];
    else
        imagem = [base, 'mdb',int2str(i)];
    end      
    
    % carrega a imagem
    f = imread(imagem,'PGM');   
     
    disp(strcat('Extraindo caracteristicas de: ',imagem))
    
   
    temp=[];
    
    %% descomente as linhas referente aos extratores desejados
    
        %% 9 caracteristicas extatisticas conforme o artigo A1 2010
        if (estatisticoA1 == 1)  
            ext = extratorEstatisticaA1(f);
            temp = [temp, ext];
            if (qtinstancias ==1) name = [name,'-estA1'];end 
        end
        
        %% 9 caracteristicas extatisticas conforme o artigo A1 2010 sem fundo 0
        if (estatisticoA1sem0 == 1)  
            ext = extratorEstatisticaA1sem0(f);
            temp = [temp, ext]; 
            if (qtinstancias ==1) name = [name,'-estA1sem0'];end 
        end
        
        %% 7 caracteristicas extatisticas conforme o artigo B1 2007
        if (estatisticoB1 == 1)  
            ext = extratorEstatisticaB1(f);
            temp = [temp, ext]; 
            if (qtinstancias ==1)name = [name,'-estB1'];end
        end
        
        %% textura a partir da matriz de ocorrencias, a quantidade de caracteristicas 
        if (texcoocorrencia == 1)  
            vizinhanca = [0 1]; % [0 1; 0 2; 0 3; 0 4]
            ext = extratorMatCoOcorrencia(f,vizinhanca);
            temp = [temp, ext];
            if (qtinstancias ==1) name = [name,'-coOcor','vis='];end
        end
        
        %% momentos invariantes
        if (momentosinv == 1)  
            ext = extratorMomInvariantes(f);
            temp = [temp, ext];
            if (qtinstancias ==1) name = [name,'-momInv'];end
        end

        %% textura expectro
        if (expectro == 1)  
            ext = extratorExpectro(f);
            temp = [temp, ext];
            if (qtinstancias==1) name = [name,'-expectro='];end
        end

        %% PCA
        if (pca == 1)      
            matriximagens(:,qtinstancias) = f(:);
        end            
            
        %% 2DPCA sobre matriX de co-ocorrencia
        if (doisdpcaocorr == 1)     
            GLCM = graycomatrix  (f,'Offset',[0 1], 'NumLevels',255);
            [x,y]=size(GLCM);
            for x1=1:x
                for y1=1:y
                    matriximagens(x1,qtinstancias,y1)=GLCM(x1,y1);
                end
            end
            if (qtinstancias ==1)name = [name,'-coocorrencia'];end
        end
            
        %% 2DPCA sobre a matrix da imagem
        if (doisdpca == 1)     
            [x,y]=size(f);
            for x1=1:x
                for y1=1:y
                    matriximagens(x1,qtinstancias,y1)=f(x1,y1);
                end
            end    
        end
            
        %%    
        if (size(temp) > 0)
            caracteristicas(qtinstancias,:) = temp;
        end    

end
disp('FIM DA EXTRAÇÃO DE CARACTERISTICAS')


%% treinar e classificar

    tempname = name;
    caracteristicastemp = caracteristicas;
    
if (pca == 1)
    pc = extratorPCA(matriximagens);
    for ncomprinc=componentes
        caracteristicas = [caracteristicastemp, pc(:,1:ncomprinc)];
        name = [tempname,'-pca=',num2str(ncomprinc)];
        treinarClassificar(caracteristicas, rotulos2, folds, name);
    end
elseif (doisdpca == 1 | doisdpcaocorr == 1)       
    pc = extrator2DPCA(matriximagens);
    for ncomprinc=componentes
        caracteristicas = [caracteristicastemp, pc.W(:,1:ncomprinc)];
        name = [tempname,'2DPCA=',num2str(ncomprinc)];
        treinarClassificar(caracteristicas, rotulos2, folds, name);
    end    
else    
    treinarClassificar(caracteristicas, rotulos2, folds,name);
end    
    



