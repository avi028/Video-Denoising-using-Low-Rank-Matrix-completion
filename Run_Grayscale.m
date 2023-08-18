clc;close all; clear ;tic;
addpath('bm3d');

%% reading video
vi = VideoReader('cars.avi');

H = vi.Height;
W = vi.Width;

% number of frames
T = 20;

crop_h = 160;
crop_w = 240;
initial_frames = zeros(crop_h,crop_w,T);

for f=1:T
    a = read(vi,f);
    b = rgb2gray(a);
    f_t = b(H-crop_h+1:end,W-crop_w+1:end);
    f_t = im2double(f_t);
    initial_frames(:,:,f) = f_t;
end

H=crop_h;
W=crop_w;

% image set
imset = zeros(H,W,T);
patchCount = zeros(H,W,T);

%% noise addition to the frames
noise_writer = VideoWriter("noisy_video.avi","Uncompressed AVI");
open(noise_writer);
for f=1:T
    im = initial_frames(:,:,f);

    % impulse
    im=imnoise(im,'salt & pepper',.1);
    
    % gaussian
    im =imnoise(im,'gaussian',0,.05);
    
     % poission
    im = imnoise(im,'poisson');

    imset(:,:,f)=im;
    writeVideo(noise_writer,im);
end

close(noise_writer);

noise_set = imset;
fprintf('Noise added to video \n');

%%  adaptive filter
adaptive_writer = VideoWriter("adaptive_video.avi","Uncompressed AVI");
open(adaptive_writer);

Smax = 8;
for f=1:T
   imset(:,:,f)= adaptive_median_filter_mod(imset(:,:,f),Smax);
   writeVideo(adaptive_writer,imset(:,:,f));
end
close (adaptive_writer);
fprintf('Adaptive filter applied to video \n');

%% variable initialization 
patch=5;
search_window_factor = 7;
k=15;
m=12;

filtered_video_writer = VideoWriter("adaptive_ISVT_video.avi","Uncompressed AVI");
open(filtered_video_writer);

result_set = zeros(H,W,T);

for f=1:T
%% patch set generation
    test_frame=f;
    [sol,posi] = NSS(imset(:,:,test_frame), patch, search_window_factor, k);
    
    fprintf("Frame %d / %d in process\n",f,T);
    
    floor_patch = floor(patch/2);
    
    %% main algorithm
    for i = 1+floor_patch:patch:H-floor_patch
        for j=1+floor_patch:patch:W-floor_patch
            %patch
            patch_matrix = reshape(sol(i,j,:,:),[patch*patch,k]);
            
            % sparce matrix Creation
            p = sparse_matrix(patch_matrix,m);
            M_idx = find(p==1);
            M_val = patch_matrix(M_idx);
            
            % ISVT
            M = testSVT(patch*patch,k,M_idx,M_val,12, 1e-4);        
            sol(i,j,:,:)=M;
        end
    end
    
   %% reconstruction of frame
    im = reconstruct(sol, posi, patch, search_window_factor,k);
    writeVideo(filtered_video_writer,im(:,:));
    result_set(:,:,f)=im;
end
disp("ISVT applied ");

close(filtered_video_writer);

disp("Final Result video generated");

%% Evaluation
disp("--------------------Evaluation ----------------------");
test_frame = 1;
figure();
imshow(noise_set(:,:,test_frame));
title("noisy image")
fprintf("PSNR after Noise addition of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),noise_set(:,:,test_frame),1));

figure();
imshow(imset(:,:,test_frame));
title("Adaptive Median Filtering")
fprintf("PSNR after Adaptive filtering of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),imset(:,:,test_frame),1));

figure();
imshow(result_set(:,:,test_frame));
title("Adaptive Median Filtering  + ISVT")
fprintf("PSNR after Adaptive + ISVT filtering of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),result_set(:,:,test_frame),1));

%% comparision with other filters
fprintf("-------------------Comparision with other filters----------------\n");
fim = imnlmfilt(noise_set(:,:,test_frame));
figure();
imshow(fim);
title("imnlm filter")
fprintf("PSNR after imnlm filtering of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),fim(:,:),1));

fim = imbilatfilt(noise_set(:,:,test_frame));
figure();
imshow(fim);
title("bilateral filter")
fprintf("PSNR after bilateral filtering of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),fim(:,:),1));

fim = BM3D(noise_set(:,:,test_frame),0.15);
figure();
imshow(fim);
title("bm3d filter")
fprintf("PSNR after bm3d filtering of test frame %d : %f\n",test_frame,psnr(initial_frames(:,:,test_frame),fim(:,:),1));
