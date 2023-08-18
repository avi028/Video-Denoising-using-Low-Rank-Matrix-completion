function PSNR = psnr_color(img_org, img_denoised, pixel_threshold)
    error = 0;
    total_error=0;
    [H,W,~] = size(img_org);
    for a=1:3
        for i = 1:H
            for j = 1:W
                % A Check For NaN
                if(img_denoised(i,j,a) == img_denoised(i,j,a))
                    error = error + ( img_org(i,j,a) - img_denoised(i,j,a)) * ( img_org(i,j,a) - img_denoised(i,j,a));
                end
            end
        end
        total_error = total_error + error;
    end
    PSNR = 10*log10(pixel_threshold*pixel_threshold/(total_error / (H*W*3)));
end
