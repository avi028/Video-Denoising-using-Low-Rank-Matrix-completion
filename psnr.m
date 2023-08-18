function PSNR = psnr(img_org, img_denoised, pixel_threshold)
    error = 0;
    [H,W] = size(img_org);
    for i = 1:H
        for j = 1:W
            % A Check For NaN
            if(img_denoised(i,j) == img_denoised(i,j))
                error = error + ( img_org(i,j) - img_denoised(i,j)) * ( img_org(i,j) - img_denoised(i,j));
            end
        end
    end
    PSNR = 10*log10(pixel_threshold*pixel_threshold/(error / (H*W)));
end
