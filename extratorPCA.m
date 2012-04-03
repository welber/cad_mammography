function final = extratorPCA(f)
    f = double(f);
    [linhas,col]=size(f);
    strd=std(f);
    sr = f./repmat(strd,linhas,1);

    [coefs] = princomp(f,'econ');
    final = coefs;
    
return