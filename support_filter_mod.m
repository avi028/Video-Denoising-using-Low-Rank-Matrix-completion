function x = support_filter_mod(I,sx,Smax,i,j,m,n)
    patch = I(max(1,i-sx/2):min(m,i+sx/2),max(1,j-sx/2):min(n,j+sx/2));
    Zmin = min(patch(:));
    Zmax = max(patch(:));
    Zmed = median(patch(:));
    Zxy = I(i, j);
    if (Zmed>Zmin) && (Zmed<Zmax)
    B1 = Zxy-Zmin;
    B2 = Zxy-Zmax;
    if (B1>0) && (B2<0)
    x=Zxy;
    else
    x=Zmed;
    end
    else
    sx = sx+2;
    if sx>Smax
    x = Zxy;
    else
    x=support_filter_mod(I,sx,Smax,i,j,m,n);
    end
    end
end