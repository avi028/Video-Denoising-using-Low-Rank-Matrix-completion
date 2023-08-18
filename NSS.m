function [solution, posi] = NSS(im, patch, search_window_factor, k)
    [m,n] = size(im);
    search_window = search_window_factor * patch;
    solution = zeros(m,n,patch*patch, k);
    %posi if we do movement at any point
    posi = zeros(m,n,2,k);
    floor_patch = floor(patch/2);
    floor_sw = floor(search_window/2);
    for i = 1+floor_patch:patch:m-floor_patch
        for j=1+floor_patch:patch:n-floor_patch
            hehe_boi = im(i-floor_patch:i+floor_patch, j-floor_patch:j+floor_patch);
            search_patch = im(max(1,i-floor_sw):min(i+floor_sw,m), max(1,j-floor_sw):min(n,j+floor_sw));
%             search_patch = im(i-floor_sw:i+floor_sw, j-floor_sw:j+floor_sw);
            posi(i,j,:,:) = support_NSS(search_patch, hehe_boi, patch, search_window_factor, k);
            p = reshape(posi(i,j,:,:),[2,k]);
            solution(i,j,:,:) = some_work(p, search_patch, patch,k);
        end
    end
end