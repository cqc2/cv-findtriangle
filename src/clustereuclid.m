function index = clustereuclid(data,dist,maxp)
%
% ŷʽ����
% index = clustereuclid(data,dist,maxp)
%
% INPUT:
% data - �������ݣ������Ƕ�ά
% dist - �������
% maxp - ���������ԭ������������������maxp�������з����γ���������
%
% OUTPUT:
% index - ÿ��Ԫ�ص�����
% ע�⣺���Է��֣�����������һ������ʱ���Ӵ���1�������Դ�������ݽ϶�ʱ��Ӧ�ֿ鴦��
%       �����һ�㲻Ҫ����1000
% REFERENCES:
% PCL 1.8.0\include\pcl-1.8\pcl\segmentation\extract_clusters.h

if ~exist('maxp','var')||isempty(maxp), maxp = 9999;end

Mdl = KDTreeSearcher(data);
n = size(data,1);
processed = zeros([n 1]);%�Ƿ��Ѿ�������
nCluster  = 0;
index = zeros([n 1]);
for i = 1:n
    if processed(i)
        continue;
    end
    sq_idx = 1;
    seed_queue = i;%��������
    processed(i) = true;
    while size(seed_queue,2)>=sq_idx
        idx = rangesearch(Mdl,data(seed_queue(sq_idx),:),dist);
        idx = idx{1};
        if isempty(idx)
            sq_idx = sq_idx+1;
            continue;
        end
        for j = 1:size(idx,2)
            if processed(idx(j))
                continue;
            end
            seed_queue = [seed_queue idx(j)];
            processed(idx(j)) = true;
        end
        sq_idx = sq_idx+1;      
        if exist('maxp','var')&&size(seed_queue,2)>maxp
            break;%�������maxp���㣬����з���
        end
    end
    nCluster = nCluster+1;
    index(seed_queue) = nCluster;
end
end