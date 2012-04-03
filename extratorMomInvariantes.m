function caracteristicas = extratorMomInvariantes(f)
    caracteristicas(1:7) = abs(log(invmoments(f)));
return