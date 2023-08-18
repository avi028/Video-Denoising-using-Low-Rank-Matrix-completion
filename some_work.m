function solution = some_work(position, search_patch, patch,k)
    solution = zeros(patch*patch,k);
    floor_patch = floor(patch/2);

    for i=1:k
        x=position(1,i);
        y=position(2,i);
        hehe_boi = search_patch(x-floor_patch:x+floor_patch, y-floor_patch:y+floor_patch);
        solution(:,i)=reshape(hehe_boi, [patch*patch, 1]);
    end
end