function caracteristicas = extratorMatCoOcorrencia(f,vizinhanca)
      
   GLCM = graycomatrix  (f,'Offset',vizinhanca, 'NumLevels',255);
   stats = graycoprops(GLCM,'all');
%figure, plot([stats.Correlation]);
%title('Correlação x Vizinhança');
%ylabel('Correlação');
%xlabel('Vizinhança');
    [lin,col]=size(vizinhanca);
    salt = lin;
    i = 1;
    caracteristicas(1,i:salt) = stats.Contrast(1,:);
    i = i+salt;
    caracteristicas(1,i:salt+i-1) = stats.Correlation(1,:);
    i = i+salt;
    caracteristicas(1,i:salt+i-1) = stats.Energy(1,:);
    i = i+salt;
    caracteristicas(1,i:salt+i-1) = stats.Homogeneity(1,:);
    i = i+salt;
    [linha,coluna] = size(f);
    n = linha*(coluna-1);
    P = GLCM/n;
    for z = 1:salt
        P1 = P(:,:,z);
        caracteristicas(1,i) = max(P1(:));
        i=i+1;
        caracteristicas(1,i) =-sum(P1(:).*(log2(P1(:)+eps)));
        i=i+1;
    end   
    %caracteristicas(1,i) =mean(caracteristicas(1,1:salt));
    %i=i+1;
    %caracteristicas(1,i) =mean(caracteristicas(1,salt+1:salt*2));
    %i=i+1;
    %caracteristicas(1,i) =mean(caracteristicas(1,salt*2+1:salt*3));
    %i=i+1;
    %caracteristicas(1,i) =mean(caracteristicas(1,salt*3+1:salt*4));
    %i=i+1;
    %caracteristicas(1,i) =mean(caracteristicas(1,salt*4+1:salt*5));
    %i=i+1;
    %caracteristicas(1,i) =mean(caracteristicas(1,salt*5+1:salt*6));
    %i=i+1;
 return
