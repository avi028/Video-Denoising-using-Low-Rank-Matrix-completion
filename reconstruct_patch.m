function [found_patch, avg_patch] = reconstruct_patch(search_patch, solution, posi, patch,k,i,j)
found_patch = search_patch;
avg_patch = search_patch;
floor_patch = floor(patch/2);

avgp = ones(patch, patch);
    for z = 1:k
        x=posi(i,j,1,z);
        y=posi(i,j,2,z);
        hehe_boi=reshape(solution(i,j,:,z),[patch,patch]);
        found_patch(x-floor_patch:x+floor_patch, y-floor_patch:y+floor_patch)=found_patch(x-floor_patch:x+floor_patch, y-floor_patch:y+floor_patch) + hehe_boi;
        avg_patch(x-floor_patch:x+floor_patch, y-floor_patch:y+floor_patch)=avg_patch(x-floor_patch:x+floor_patch, y-floor_patch:y+floor_patch)+avgp;
    end
end