% Authors: Suraj Khetarpal, Hongda Mi, Winta
% This script will show us whether the saddle point is in the upper right quadrant
%   based on the two grievance parameters m and n. The color white
%   indicates yes.

clf; clear all;

%Setup reasonable parameters that would result in a saddle point
a=-0.1; b=0.2; c=0.2; d=-0.1;

%Setup the grid and determine whether the fixed point falls into the upper
%right quadrant of our graph.
gridsize = 20;
grid_inc = 1;
grid_bottom = -20;
[m, n] = meshgrid(grid_bottom:grid_inc:gridsize,grid_bottom:grid_inc:gridsize);
%n = flipud(n);
fp = (b.*n-d.*m)/(a*d-b*c)>0 & (c.*m-a.*n)/(a*d-c*b)>0;

imagesc(grid_bottom,grid_bottom,fp);            %# Plot the image
colormap(gray);                                 %# Use a gray colormap
axis([grid_bottom,gridsize,grid_bottom,gridsize])
xlabel('Grievance Parameter m');
ylabel('Grievance Parameter n'); 
title('Is Saddle Point in Upper Right Quadrant (white = yes)');