function posi = support_NSS(search_patch, hehe_boi, patch, search_window_factor,k)

    posi = zeros(2,k);
    floor_patch = floor(patch/2);

    [m,n] = size(search_patch);
    
%     order = zeros(1,m*n/(patch*patch));
    
    count = 1;
%     set1 = zeros(2,m*n/(patch*patch));

    for i = 1+floor_patch:patch:m-floor_patch
    
        for j=1+floor_patch:patch:n-floor_patch
             
            hehe_boi2 = search_patch(i-floor_patch:i+floor_patch, j-floor_patch:j+floor_patch);
            x = hehe_boi2 - hehe_boi;
            
            order(1,count) = sum(abs(x),'all');
            set1(1,count) = i;
            set1(2,count) = j;
     
            count = count+1;
        
        end
    
    end
    
    [~,position]=sort(order);
    
    for i=1:k
      posi(:,i) = set1(:,position(i));
    end
end