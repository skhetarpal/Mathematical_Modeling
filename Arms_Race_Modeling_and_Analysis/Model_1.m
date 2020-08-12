% Authors: Suraj Khetarpal, Hongda Mi, Winta
% Reference: "love_affairs.m" by Eli Tziperman and Zhiming Kuang

%This code will generate phase portraits for each system, as well as
%provide information required for the eigen analysis

clf; clear all;

%Setup parameters for the model
%a=-0.1; b=0.2; m=5; c=0.2; d=-0.1; n=5; description = 'Similar Parameters, F, D, G';
%a=-0.1; b=0.5; m=7; c=0.3; d=-0.2; n=-4; description = 'Disimilar Parameters, F, D, +/-G';
%a=-0.1; b=0.2; m=-5; c=0.2; d=-0.1; n=-5; description = 'Similar Parameters, F, D, -G';
%a=-0.2; b=0.1; m=-5; c=0.1; d=-0.2; n=-5; description = 'Similar Parameters, high F, low D, G';
%a=-0.2; b=0.1; m=5; c=-0.1; d=-0.2; n=5; description = 'One Country Submissive, high F, low +/-D, G';
a=-0.2; b=0.3; m=5; c=-0.2; d=0.3; n=5; description = 'Opposite Parameters, +/-F, +/-D, G';

%Provide descriptors to help evaluate the eigen properties
tau = a+d
Delta = a*d-b*c
discriminant = tau^2-4*Delta

%Find fixed points
A = [a b;c d];
B = [-m;-n];
fp = linsolve(A,B); fp
fp2 = [(b*n-d*m)/(a*d-b*c) (c*m-a*n)/(a*d-c*b)];

%Setup a grid and calculate dx/dt and dy/dt
gridsize = 100;
grid_inc = 10;
grid_bottom = -100;
[X, Y] = meshgrid(grid_bottom:grid_inc:gridsize,grid_bottom:grid_inc:gridsize);
u = a.*X + b.*Y + m;
v = c.*X + d.*Y + n;

%Print out the eigenvalues and eigenvectors
A=[a b; c d];
[V,D] = eig(A)

% plot arrows in phase plane:
quiver(X,Y,u,v)
h(1)=title(sprintf('%s', description));
h(2)=xlabel('US');
h(3)=ylabel('RU');
h(4)=gca;
set(h,'FontSize',18)
hold on
V=V*gridsize/10;
% plot axes:
h=plot([0 0],[grid_bottom gridsize]); set(h,'Color',[0.8 0.8 0.8],'LineWidth',5)
h=plot([grid_bottom gridsize],[0 0]); set(h,'Color',[0.8 0.8 0.8],'LineWidth',5)
% plot eigenvectors in the location of the fixed point if applicable:
hold on
if ~isnan(fp(1)) && ~isnan(fp(2))
    plot([fp(1)-V(1,1) fp(1)+V(1,1)],[fp(2)-V(2,1) fp(2)+V(2,1)],'g','LineWidth',2)
    hold on
    plot([fp(1)-V(1,2) fp(1)+V(1,2)],[fp(2)-V(2,2) fp(2)+V(2,2)],'r','LineWidth',2)
end
%If countries have the opposite but equal parameters, plot non-isolated fixed points 
if a==c && b==d && m==n
    x = grid_bottom:grid_inc:gridsize;
    fp_line = -a/b*x-m/b;
    hold on
    plot(x,fp_line,'b','LineWidth',2)
end
axis([grid_bottom gridsize grid_bottom gridsize])