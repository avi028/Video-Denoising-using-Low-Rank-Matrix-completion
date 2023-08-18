function posi = sparse_matrix(input_matrix, retain_factor)
    [m,n] = size(input_matrix);
    posi = zeros(m,n);
    for i=1:m
        x = input_matrix(i,:);
        xmean = mean(x);
        x = abs(x-xmean);
        [~,iposi] = sort(x);
        for j=1:retain_factor
            posi(i, iposi(1,j))=1;
        end
    end
end