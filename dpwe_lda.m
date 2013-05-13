function [W,Y] = dpwe_lda(X,L,N)
% [W,Y] = dpwe_lda(X,L,N)
%    Find linear discriminant projections for data in rows of X
%    with labels in L (a column).  N bases are found
%    B are the bases; P is the projection.
% 2004-10-11 dpwe@ee.columbia.edu
% from
% http://espresso.ee.sun.ac.za/~schwardt/pr813/lectures/lecture01/node7.html

[nr,ndim] = size(X);

% Unique set of labels
ls = [];
L2 = L;
while length(L2) > 0
  ls = [ls, L2(1)];
  L2 = L2(L2 ~= L2(1));
end

nl = length(ls);

% Calculate per-class means and variances
mu = zeros(nl,ndim);
sg = zeros(nl,ndim*ndim);
pr = zeros(1,nl);

for i = 1:nl
  Xi = X(L==ls(i),:);
  mu(i,:) = mean(Xi);
  cv = cov(Xi);
  % Ravel cov to store
  sg(i,:) = cv(1:(ndim*ndim));
  pr(1,i) = sum(L==ls(i))/nr;
end

Sw = pr*sg;
Sw = reshape(Sw, ndim, ndim);
mm = pr*mu;
dmu = mu - repmat(mm,nl,1);
Sb = dmu'*diag(pr)*dmu;

[V,D] = eig(Sw);
D = diag(D);
Dnz = (D > max(D)/100); % was 100
B = V(:,Dnz)*(diag(D(Dnz))^-.5);

Sbd = B'*Sb*B;

[U,lam] = eig(Sbd);
lam = abs(diag(lam));
[vv,xx] = sort(-lam);

lnz = (lam > max(lam)/100); % was 100

if N > sum(lnz)
  N = sum(lnz);
end

W = B*U(:,xx(1:N));

Y = W'*X';
