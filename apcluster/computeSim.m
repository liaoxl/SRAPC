function dis = computeSim(I, ci, cj)

c1 = (ci(1)-cj(1)).^2;
c2 = (ci(2)-cj(2)).^2;
% ci = (I(ci(2), ci(1))-I(cj(2), cj(1))).^2;

% feature = c1 + c2 + ci;
feature = c1 + c2 ;
dis = -feature;

end