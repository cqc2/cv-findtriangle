function vertex = demo
% find vertex of triangle
% The program is suitable for single background. 
 
% The program is written by Chen Qichao. You can redistribute or modify 
% the program for non-commercial use. Any commercial use of this program 
% is forbidden except being authorized.
%
% mail : mailboxchen@foxmail.com
% Copyright (C) 2015 - 2018  Chen Qichao

 originI = imread('../example/1.jpg');
 I2 = originI;
 if size(originI,3)==3
     originI = im2double(rgb2gray(originI));
 else
     originI = im2double(originI);
 end

[H W] = size(originI);
if(H+W)<2000
    skip =  ceil((H+W)/1000);
else
   skip =  ceil((H+W)/500);
end
I = originI(1:skip:end,1:skip:end);
BW = imbinarize(I, 'adaptive','Sensitivity' ,0.8);
% imshow(BW);
BW = edge(BW,'roberts');
% imshow(BW);
[py,px] = find(BW>0);
index = clustereuclid([px py],3);
nc = unique(index);
for i=1:size(nc,1)
    tmpx = px(index==i);
    tmpy = py(index==i);
    cluster(i).data = [tmpx,tmpy];
end
cluster = getclusterinfo(cluster);
vertex = [];
for i=1:size(nc,1)
   if cluster(i).lenWidthRate<3&&cluster(i).n>50
       data = cluster(i).data;
       mp = mean(data);
       
       d = data - mp;
       dd = sqrt(d(:,1).*d(:,1)+d(:,2).*d(:,2));
       [~ ,idx1] = max(dd);
       vertex1 = data(idx1,:);
       
       d = data - vertex1;
       dd = sqrt(d(:,1).*d(:,1)+d(:,2).*d(:,2));
       [~ ,idx1] = max(dd);
       vertex2 = data(idx1,:);
       
       mv = (vertex1+vertex2)./2;       
       d = data - (mp+(mp-mv).*3);
       dd = sqrt(d(:,1).*d(:,1)+d(:,2).*d(:,2));
       [~ ,idx1] = min(dd);
       vertex3 = data(idx1,:);
       
       vertex = [vertex;floor(vertex1) floor(vertex2) floor(vertex3)];
   end
end
vertex = vertex.*skip-skip./2;
for i=1:size(vertex,1)
    I2 = insertShape(I2,'Circle',[vertex(i,1:2) skip;vertex(i,3:4) skip;...
        vertex(i,5:6) skip],'Color',{'blue','blue','green'},'LineWidth',5);
end
axis equal;
imshow(I2);
imwrite(I2,'out.png');
end
