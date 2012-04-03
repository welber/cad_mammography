function [values] =  treinarClassificar(caracteristicas, rotulos2, folds,name)

[qtinstancias, cols] = size(caracteristicas);


%% preparar caracteristivas para libsvm

% normalizar as caracteristicas max-min
%y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
[linhas,colunas]=size(caracteristicas);
ymax = 1;
ymin = -1;
carac_normalizadas = zeros(linhas,colunas);
for coluna = 1:colunas
    xmin = min(caracteristicas(:,coluna));
    xmax = max(caracteristicas(:,coluna));
    if (xmin == xmax)
        carac_normalizadas(:,coluna) = 1;
    else
        carac_normalizadas(:,coluna) = ((ymax-ymin).*(caracteristicas(:,coluna)-xmin))./(xmax-xmin)+ymin;
    end    
end

% libsvm necessita que as caracteristicas sejam uma matrix exparsa
carac_sparce = sparse(carac_normalizadas);


%% treinar e classificar

% calibrar parametros do svm

[bestc,bestg,bestcv,hC] = modsel(rotulos2, carac_sparce, folds);
cmd = [' -c ',num2str(bestc),' -g ',num2str(bestg)];
disp('FIM DA CALIBRAÇÃO DE PARAMETROS')


%% cross validation
      CVO = cvpartition(qtinstancias,'k',folds);
      err = zeros(1,CVO.NumTestSets);
      for i = 1:CVO.NumTestSets
          trIdx = CVO.training(i);
          teIdx = CVO.test(i);
          model = libsvmtrain([rotulos2(trIdx)], [carac_sparce(trIdx,:)], cmd);
          [predict_label, accuracy, dec_values] = svmpredict([rotulos2(teIdx)], [carac_sparce(teIdx,:)], model);
          err(i) = accuracy(1);
      end
      cvErr = sum(err)/CVO.NumTestSets

%%

% treinar
model = libsvmtrain(rotulos2, carac_sparce, cmd);

% classificar
[predict_label, accuracy, dec_values] = svmpredict(rotulos2, carac_sparce, model);

% matriz de confuzão
C = confusionmat(rotulos2,predict_label);


%% impressão de resultados 

 disp('==================================================================');
 disp('');
 disp('RESULTADOS');
 
 disp(['Parametros calibrados: c=',num2str(bestc),' g=',num2str(bestg)])
 
 disp(['Acuracia média da validação cruzada do libsvm: ', num2str(bestcv),'%'])
 
 disp(['Acuracia das iterações da valicação cruzada própria'])
 err

 disp(['Acuracia média da validação cruzada própria: ',num2str(cvErr),'%'])
 
 disp(['Acuracia utilizando todas as intâncias para treinamento e teste: ',num2str(accuracy(1)),'%'])
 
 disp('Matrix de confusão utilizando todas as intâncias para treinamento e teste: ')
 C 

 %% salvar workspace e resultados
 
 save(['./workspaces/',name,'.mat']);

 fid = fopen(['./results/',name,'.txt'],'wt');
 fprintf(fid,'%s\n',['Parametros calibrados: c=',num2str(bestc),' g=',num2str(bestg)]);
 fprintf(fid,'%s\n',['Acuracia média da validação cruzada do libsvm: ', num2str(bestcv),'%']);
 fprintf(fid,'%s\n',['Acuracia das iterações da valicação cruzada própria']);
 fprintf(fid,'%f\n',err);
 fprintf(fid,'%s\n',['Acuracia média da validação cruzada própria: ',num2str(cvErr),'%']);
 fprintf(fid,'%s\n',['Acuracia utilizando todas as intâncias para treinamento e teste: ',num2str(accuracy(1)),'%']);
 fprintf(fid,'%s\n',['Matrix de confusão utilizando todas as intâncias para treinamento e teste: ']);
 fprintf(fid,'%f\n', C );
 fclose(fid);

 
 
%% exportar caracteristicas para utilização em outras ferramentas

%% libsvm

% salvar arquivo antes da normalização das caracteristicas
%libsvmwrite('caracteristicas.txt', rotulos2, sparse(caracteristicas));

% salver arquivo com as caracteristicas nornalizadas
%libsvmwrite('normalizado.txt', rotulos2, carac_sparce);

%% gerar arquivo arff para weka

% adiciona os rótulos ao vetor de caracteristicas
%caracteristicas(:,colunas+1) = rotulos2;   

% adiciona o path do weka
%javaaddpath(['/home/welber/Área de Trabalho/MESTRADO/DATA MINING/weka-3-6-6/weka.jar']);

% nome dos atributos
%attributeNames = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};

% converte e salva
%wekaOBJ = matlab2weka('mamografias', attributeNames, caracteristicas);
%saveARFF('mamografias2012.arff',wekaOBJ);

%%
end