v = zeros(4, 3);
ii = [1;2;3;1;3;4];
res = [-1 -1 1 ; -1 -1 1 ; -1 -1 1 ; 1 1 -1 ; 1 1 -1 ; -1 1 -1];
for i = 1:3
     v(:,i) = accumarray(ii , res(:,i));
end