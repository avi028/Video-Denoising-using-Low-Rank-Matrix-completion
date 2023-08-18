function im = adaptive_median_filter_mod(I, Smax)
[m,n]=size(I);
im = I;

for i=1:m
    for j=1:n
        sx = 2;
%         disp((i-1)*n+j);
        im(i, j) = support_filter_mod(I, sx, Smax, i, j,m,n);
    end
end
% im =imnlmfilt(im);
end
