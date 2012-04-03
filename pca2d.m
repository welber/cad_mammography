function model = pca2d(X,arg1)
% PCA2D  2D Principal Component Analysis.
%
% Synopsis:
%  model = pca2d(X)
%  model = pca2d(X,new_dim)
%  model = pca2d(X,var)
%
% Description:
%  It computes 2D Principal Component Analysis
%
%  model = pca(X,new_dim) use to specify explicitely output
%   dimension where new_dim >= 1.
%
%  model = pca(X,var) use to specify a portion of discarded
%   variance in data where 0 <= var < 1. The new_dim is 
%   selected be as small as possbile and to satisfy 
%     var >= MsErr(new_dim)/MaxMsErr 
%   
%   where MaxMsErr = sum(sum(X.^2)). 
%
% Input:
%  X [M x N x num_data] training data 
%
%  new_dim [1x1] Output dimension; new_dim > 1 (default new_dim = dim);
%  var [1x1] Portion of discarded variance in data.
%
% Ouputs:
%  model [struct] Linear projection:
%   .W [dim x new_dim] Projection matrix.
%   .b [new_dim x 1] Bias.
%  
%   .eigval [dim x 1] eigenvalues.
%   .mse [real] Mean square representation error.
%   .MsErr [dim x 1] Mean-square errors with respect to number 
%     of basis vectors; mse=MsErr(new_dim).
%   .mean_X [dim x 1] mean of training data.
%
% Example:
%  in_data = load('iris');
%  model = pca(in_data.X, 2)
%  out_data = linproj(in_data,model);
%  figure; ppatterns(out_data);
%
% See also 
%  PCA2DPROJ, PCA2DREC.


% get dimensions
[M,N,num_data]=size(X);

% process input arguments
if nargin < 2, arg1 = 0; end

% centering data
mean_X = mean(X,3);
X=X-repmat(mean_X,[1 1 num_data]);

% covariance
Gt = zeros(N,N);
for j=1:num_data
    Gt = Gt + X(:, :, j)'*X(:, :, j)/num_data;
end

% eigenvalue decomposition
[U,D,V]=svd(Gt);

model.eigval=diag(D)/num_data;
sum_eig = triu(ones(N,N),1)*model.eigval;
model.MsErr = sum_eig;

% decide about the new_dimension
if arg1 >= 1,
  new_dim = arg1;   % new_dim enterd explicitely
else
  inx = find( sum_eig/sum(model.eigval) <= arg1);
  if isempty(inx), new_dim = N; else new_dim = inx(1); end
  model.var = arg1;
end

% take new_dim most important eigenvectors
model.W=V(:,1:new_dim);

% compute data translation
model.b = -mean_X*model.W;
model.new_dim = new_dim;
model.mean_X = mean_X;
model.mse = model.MsErr(new_dim);
model.fun = 'pca2dproj';

return;