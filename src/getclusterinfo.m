function cluster = getclusterinfo(cluster,tracedata)
%
% ������ƾ������������Ϣ��ʹ����Щ��Ϣ�Կ��ԶԾ�����и��߲�εĳ����Ա�����
% һ���Ĵ���
%
% INPUT��
% cluster - ���ƾ���ṹ��
% 
% OUTPUT��
% cluster - ӵ����������������ֶεĵ��ƾ���ṹ��
%
% STRUCT��
% data - ��������
% isLabel - �Ƿ��Ѿ���ǹ���false or true
% label - �������Ĭ��0
% rectx - ��Ӿ��εĺ����꣬������β��ͬһ���㣬������5������
% recty - �����ε�������
% center - ��Ӿ�������
% rectArea - ��Ӿ������
% perimeter - ��Ӿ����ܳ�
% length - ��Ӿ��νϳ���
% width - ��Ӿ��ν϶̱�
% pointArea - �Ը����������Ƽ���ĵ������ 
% perctA - �������ռ����Ӿ����������
% density - ���ܶ�
% direction - ���η�����������ʾ�˾��ε���̬�����ַ��򣩣�ģ�Ĵ�С��ʾ�˳ʾ��εĳ̶�
% squareValue - �Զ�����ζȣ����ǳ���ȣ�Ҳ���ǳ���ľ��ζ�
% angle - ��x��нǣ�0~180��
% lenWidthRate - �����
% n - �����
% angle2trace - ���䳯����켣�н�
% len2trace - �������ĵ��켣����

isCaltraceinfo = false;
if exist('tracedata','var')&&~isempty(tracedata)
    Mdl = KDTreeSearcher(tracedata(:,1:2));
   isCaltraceinfo = true;
end
    nc  = size(cluster,2);%�������
for i=1:nc
    data = cluster(i).data;
    cluster(i).isLabel = false;
    cluster(i).label = 0;%-1��ʾ���δ֪
    x = data(:,1);
    y = data(:,2);
    n = size(x,1);
    try
    [rectx,recty,rectArea,perimeter] = minboundrect(data(:,1),data(:,2));
    catch ME
        rectx =[0 0 0 0 0]';
        recty =[0 0 0 0 0]';
        rectArea = 0;
        perimeter =0;
    end
    if n<3
        % �����������3��ʱminboundrect�����һЩbug
        perimeter=perimeter(1,1);
    end
    cluster(i).rectx = rectx;
    cluster(i).recty = recty;
    cx = mean(rectx);
    cy = mean(recty);
    cluster(i).center = [cx cy];%��Ӿ�������
    cluster(i).rectArea = rectArea;%��С��Ӿ������
    cluster(i).perimeter = perimeter;
    d = sqrt((rectx(1:2) - rectx(2:3)).^2+(recty(1:2) - recty(2:3)).^2);%��Ӿ��α߳�
    cluster(i).length = max(d);
    cluster(i).width = min(d);
    areaSeed = unique([roundn(x,-1) roundn(y,-1)],'rows');%�����Ӧ��0.1�׵ĸ�����
    pointArea = 0.1*0.1*size(areaSeed,1)-0.5*perimeter*0.1;%�Ը����������Ƽ��������� 
    cluster(i).area = pointArea;
    cluster(i).n = n;%�����
    cluster(i).perctA = pointArea/rectArea;%���ζ�
    cluster(i).density = n/rectArea;%���ܶ�
    
    %���η�����������ʾ�˾��ε���̬�����ַ��򣩣�ģ�Ĵ�С��ʾ�˳ʾ��εĳ̶�
    if d(1)==d(2)
        cluster(i).direction = [0,0];%����������ģΪ0
    elseif d(1)>d(2)
         cluster(i).direction = [(rectx(1) - rectx(2))/d(1),(recty(1) - recty(2))/d(1)].*(abs(d(1)/d(2)-1));   
    elseif d(1)<d(2)
        cluster(i).direction = [(rectx(3) - rectx(2))/d(2),(recty(3) - recty(2))/d(2)].*(abs(d(2)/d(1)-1));   
    end
    if cluster(i).direction(2)<0
        cluster(i).direction = -cluster(i).direction;
    end 
    cluster(i).squareValue = cluster(i).direction*(cluster(i).direction)';%���ζ�
    cluster(i).angle = atand(cluster(i).direction(2)/cluster(i).direction(1));
    if cluster(i).angle<0
        cluster(i).angle = cluster(i).angle+180;%�ǶȻ��㵽0~180
    end
    cluster(i).lenWidthRate = cluster(i).length/cluster(i).width;
    
    if isCaltraceinfo
        c =  cluster(i).center;
        [Idx,D] = rangesearch(Mdl,c,30);
        Idx = Idx{1};
        D =  D{1};
        angle1 = cluster(i).angle;
        if size(Idx,2)>=2%����켣����������Ҫ2����
            dx =  tracedata(Idx(1),1)-tracedata(Idx(2),1);
            dy = tracedata(Idx(1),2)-tracedata(Idx(2),2);
            angle2 = atand(dy/dx);%�켣�Ƕ�
            if angle2<0
                angle2 = angle2+180;%�ǶȻ��㵽0~180
            end
            angle12 = abs(angle1-angle2);
            if angle12>90
                angle12 = 180-angle12;%�нǻ����0~90
            end
           cluster(i).angle2trace = angle12;
           cluster(i).len2trace = (D(1)+D(2))/2;
        end
        
    else
        cluster(i).angle2trace = [];
        cluster(i).len2trace = [];
    end
%     plot(rectx,recty,'-');hold on;
%     plot(x,y,'.');hold on;
%     axis equal;
end
end