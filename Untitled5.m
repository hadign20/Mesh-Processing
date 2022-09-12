u = [3 0 0]
v = [1 1 0]
cross(u,v)
dot(u,v)
norm(cross(u,v))
normr(cross(u,v))
atan2(norm(cross(u,v)),dot(u,v))
atan2(normr(cross(u,v)),dot(u,v))

u = [1 0 0; 2 0 0]
v = [1 1 0; 2 2 0]

cross(u,v)
normr(cross(u,v))
dp = u(:,1) .* v(:,1) + u(:,2) .* v(:,2) + u(:,3) .* v(:,3);
atan2d(norm(cross(u,v)),dp)
atan2d(normr(cross(u,v)),dp)
atan2d(cross(u,v,2),dot(u,v,2))