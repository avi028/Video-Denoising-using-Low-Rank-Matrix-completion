function im = reconstruct(solution, posi, patch, search_window_factor,k)

    [m,n,~,~]=size(solution);
    im = zeros(m,n);
    imzero = zeros(m,n);
    search_window = patch*search_window_factor;
    avgm = zeros(m,n);
    floor_sw = floor(search_window/2);
    floor_patch = floor(patch/2);
    for i = 1+floor_patch:patch:m-floor_patch
        for j=1+floor_patch:patch:n-floor_patch
            search_patch = imzero(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw));
            [found_patch, avg_patch] = reconstruct_patch(search_patch, solution, posi, patch, k, i, j);
            im(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw)) = im(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw))+found_patch;
            avgm(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw)) = avgm(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw))+avg_patch;
        end
    end
     im = im./avgm;
     idx = im>1.0;
     im(idx)=1.0;
     idx = im<0.0;
     im(idx)=0.0;
end