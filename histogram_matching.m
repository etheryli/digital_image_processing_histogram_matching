% Problem 1 : Histogram Specification 

clear all;
close all;
clc;

% define L
L = 2^8;

% define specfied histogram pdf here
specified_histogram_pdf = zeros(1, L);
% for 0 to 63 and 192 to 255 = a = 1/(128*3)
% for 64 to 191 = 2a = 1/(68*3)

a = 1/(128*3);

for i = 1 : L
    if (i >= 65 && i <= 192)
        specified_histogram_pdf(i) = a*2;
    else
        specified_histogram_pdf(i) = a;
    end
end

% read in original image
image = imread('lena_gray.bmp');

% widht height
[width, height] = size(image);


% used for histogram and pdf calculations
image_histogram = zeros(1, L);
image_histogram_pdf = zeros(1, L);

 
% histogram bins counting
for i = 1 : width
    for j = 1 : height
        pixel_value = image(i, j);
        image_histogram(pixel_value + 1) = image_histogram(pixel_value + 1) + 1;
    end
end


% pdf by dividing each bin count by total pixels in image
total_pixels = width * height;
for i = 1 : L
    image_histogram_pdf(i) = image_histogram(i) / total_pixels;
end

% s = T(r) = cdf from image pdf
s = zeros(1, L);
% v = G(z) = cdf from specified histogram pdf
G_z = zeros(1, L);

% Cdf by using internal loop to sum up from beginning to i
for i = 1 : L
    for j = 1 : i
        s(i) = image_histogram_pdf(j) + s(i);
        G_z(i) = specified_histogram_pdf(j) + G_z(i);
    end
    s(i) = (L-1) * s(i);
    G_z(i) = (L-1) * G_z(i);
end

% Lookup Table Mapping
% Map r to s to z ( r is value from image we want to map to z)
% z = G^-1(T(r))
lookup = zeros(1, L, 'uint8');

for l = 1 : L
    % Find best match mapping by
    % Returning the index (s) to minimum of absolute
    % difference between s(l) and every value of G(z)
    [~, j] = min(abs(s(l) - G_z));
    
    % lookup(z_matched) = s_matched
    lookup(l) = j;
end

% Map to output image
output_image = lookup(image);

% Graphing 2 figures, 1 for image and histograms and 2 for lookup function
f1 = figure('Name', 'Histogram Specification', 'color', [1 1 1]);

% Input Image
subplot(2,2,1);
imshow(image);
title( "Input Image");

% Input Image Histogram
h1 = subplot(2,2,2);
bar(0:255,image_histogram,'b');
title("Input Image Histogram");
xlim([0 255]);
xticks(0:25:255);
xlabel("Intensity");
ylabel("Number of Pixels");
% Output Image
subplot(2,2,3);
imshow(output_image);
title("Output Image");

% Output Image Histogram
h2 = subplot(2,2,4);
bar(0:255,imhist(output_image),'r');
xlim([0 255]);
xticks(0:25:255);
ylim(get(h1,'ylim'));
title("Output Image Histogram");
xlabel("Intensity");
ylabel("Number of Pixels");

% Figure 2 - Lookup Function Plot
f2 = figure('color', [1 1 1]);
h = plot(lookup, 'LineWidth', 2);
title("Histogram Specification - Intensity Transformation Function");
xlabel("Input Intensity");
ylabel("Output Intensity");
xlim([0 255]);
ylim([0 255]);
xticks(0:25:255);
yticks(0:25:255);

