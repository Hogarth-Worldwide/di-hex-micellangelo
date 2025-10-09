roundedTxy = round(TxyModded);
[ minA , maxA ] = bounds(roundedTxy)

[X, Y] = meshgrid(95:147);


find(ismember(roundedTxy, [141,114],'rows'))

%%

figure;
x = 1:10;
y = x.^2;
col = x;
scatter(x,y,[],col)
colormap jet


%%
C = 10.^repmat(linspace(-5,5,1000),[1000,1]);

figure(1);clf
tiledlayout(2,2)

nexttile(1)
contourf(log10(C),50,'LineStyle','none')
title('contourf')
caxis([-5 5])
cb1 = colorbar;
cb1.Label.String = 'log10(C)';
set(gca,'XTick',[],'YTick',[])

nexttile(3)
contourf(C,50,'LineStyle','none')
set(gca,'ColorScale','log')
caxis([10^-5 10^5])
cb2 = colorbar;
cb2.Label.String = 'C';
set(gca,'XTick',[],'YTick',[])

nexttile(2)
p1 = pcolor(log10(C));
p1.EdgeColor = 'none';
title('pcolor')
caxis([-5 5])
cb3 = colorbar;
cb3.Label.String = 'log10(C)';
set(gca,'XTick',[],'YTick',[])

nexttile(4)
p2 = pcolor(C);
set(gca,'ColorScale','log')
p2.EdgeColor = 'none';
caxis([10^-5 10^5])
cb4 = colorbar;
cb4.Label.String = 'C';
set(gca,'XTick',[],'YTick',[])
%%
I = (1:200)'/200*(1:200)/200;
tiledlayout('flow')
nexttile
imshow(I)
hold on
med=median(1:200);
plot(med,med,'*')
% Icropped = I(1:med,:);

nexttile
imshow(Icropped)
%%

load patients
T = table(LastName,Gender,Age,Height,Weight,Smoker,Systolic,Diastolic);
size(T)

T2 = readtable('morePatients.csv');
Tnew = [T;T2];
size(Tnew)

T2.test = [1:4]'
%%
close all;



testdata = Txy(1:4,:);



theta=-angle;
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
x_center = (round(length(fixed)/2));
y_center = (round(length(fixed)/2));
center = repmat([x_center; y_center], 1, length(testdata));
v=testdata';

s = v - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;

x_rotated = vo(1,:);
y_rotated = vo(2,:);


figure
tiledlayout('flow')
nexttile
imshow(fixednorm)
hold on
scatter(testdata(:,1),testdata(:,2))

nexttile
imshow(imrotate(fixednorm,-theta,'bilinear','crop'));
hold on
scatter(x_rotated,y_rotated)
plot(x_center, y_center,'bo')

nexttile
plot(testdata(:,1), testdata(:,2), 'k*', x_rotated, y_rotated, 'r*', x_center, y_center, 'bo');
axis equal
%%
x = -2:0.25:2;
y = x;
[X,Y] = meshgrid(x);

F = X.*exp(-X.^2-Y.^2);
surf(X,Y,F)

%%

x = 0:3;
y = x;
[X,Y] = meshgrid(x);

Z = TxyModdedRotated(1)+50*X