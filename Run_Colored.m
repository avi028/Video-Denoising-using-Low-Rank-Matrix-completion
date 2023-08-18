clc;close all; clear ;tic;
addpath('bm3d');

%% reading video
vi = VideoReader('cars.avi');

H = vi.Height;
W = vi.Width;

% number of frames
T = 20;% vi.NumFrames;

crop_h = H;
crop_w = W;

H=crop_h;
W=crop_w;

initial_frames = zeros(H,W,3,T);

for f=1:T
    a = read(vi,f);
    f_t = im2double(a);
    initial_frames(:,:,:,f) = f_t;
end


% image set
imset = zeros(H,W,3,T);

%% noise addition to the frames
noise_writer = VideoWriter("noisy_color_video.avi","Uncompressed AVI");
open(noise_writer);

for f=1:T
    im = initial_frames(:,:,:,f);

    % impulse
    im=imnoise(im,'salt & pepper',.1);
    
    % gaussian
    im =imnoise(im,'gaussian',0,.05);
    
     % poission
    im = imnoise(im,'poisson');

     imset(:,:,:,f)=im;
     writeVideo(noise_writer,im);
end

close(noise_writer);

noise_set = imset;

fprintf('Noise added to video \n');

%%  adaptive filter
adaptive_writer = VideoWriter("adaptive_color_video.avi","Uncompressed AVI");
open(adaptive_writer);
Smax = 8;
for f=1:T
    for i=1:3
       imset(:,:,i,f)= adaptive_median_filter_mod(imset(:,:,i,f),Smax);
    end
    writeVideo(adaptive_writer,imset(:,:,:,f));
end
close (adaptive_writer);
fprintf('adpative filter applied\n');

%% variable initialization
patch=5;
search_window_factor = 7;
k=15;
m=12;


filtered_video_writer = VideoWriter("adaptive_ISVT_color_video.avi","Uncompressed AVI");
open(filtered_video_writer);

result_set = zeros(H,W,3,T);
for f=1:T
%% patch set generation
    fprintf("Frame %d/%d in process\n",f,T);
    test_frame=f;
    for i=1:3
        [sol(:,:,:,:,i),posi(:,:,:,:,i)] = NSS(imset(:,:,i,test_frame), patch, search_window_factor, k);
    end
    floor_patch = floor(patch/2);
    
    %% main algorithm
    for i = 1+floor_patch:patch:H-floor_patch
        for j=1+floor_patch:patch:W-floor_patch
            %patch
            for a=1:3
                patch_matrix((a-1)*(patch*patch)+1 :(a)*(patch*patch) ,: ) = reshape(sol(i,j,:,:,a),[patch*patch,k]);
            end
            
            % sparce matrix Creation
            p = sparse_matrix(patch_matrix,m);
            M_idx = find(p==1);
            M_val = patch_matrix(M_idx);
            
            % ISVT
            M = testSVT((patch*patch)*3,k,M_idx,M_val,12, 1e-4);        
            for a=1:3
                sol(i,j,:,:,a)=M((a-1)*(patch*patch)+1 :(a)*(patch*patch) ,:);
            end
        end
    end
    
    %% reconstruction of frame
    for a=1:3
        im(:,:,a) = reconstruct(sol(:,:,:,:,a), posi(:,:,:,:,a), patch, search_window_factor,k);
    end

    writeVideo(filtered_video_writer,im);
    result_set(:,:,:,f)=im;
end

disp("ISVT applied");

close(filtered_video_writer);

disp('final filtered video generated');

%% Evaluation
disp("--------------------Evaluation ----------------------");

test_frame = 1;
figure();
imshow(noise_set(:,:,:,test_frame));
title("noisy image")
fprintf("PSNR of Noise of test frame %d : %f\n",test_frame,psnr_color(initial_frames(:,:,:,test_frame),noise_set(:,:,:,test_frame),1));

fprintf("PSNR after Adaptive filtering of test frame %d : %f\n",test_frame, psnr_color(initial_frames(:,:,:,test_frame),imset(:,:,:,test_frame),1));
figure();
imshow(imset(:,:,:,test_frame));
title("Adaptive Median Filtering")

fprintf("PSNR after Adaptive filtering and ISVT of test frame %d : %f\n",test_frame,psnr_color(initial_frames(:,:,:,test_frame),result_set(:,:,:,test_frame),1));
figure();
imshow(result_set(:,:,:,test_frame));
title("Adaptive Median Filtering  + ISVT")

%% comparision with other filters
fprintf("-------------------Comparision with other filters----------------\n");

fim = imnlmfilt(noise_set(:,:,:,test_frame));
fprintf("PSNR after imnlm filtering of test frame %d : %f\n",test_frame,psnr_color(initial_frames(:,:,:,test_frame),fim(:,:,:),1));
figure();
imshow(fim);
title("imnlm filter")

fim = imbilatfilt(noise_set(:,:,:,test_frame));
fprintf("PSNR after bilateral filtering of test frame %d : %f\n",test_frame,psnr_color(initial_frames(:,:,:,test_frame),fim(:,:,:),1));
figure();
imshow(fim);
title("bilateral filter")

fim = CBM3D(noise_set(:,:,:,test_frame),0.15);
fprintf("PSNR after bm3d filtering of test frame %d : %f\n",test_frame,psnr_color(initial_frames(:,:,:,test_frame),fim(:,:,:),1));
figure();
imshow(fim);
title("cbm3d filter")