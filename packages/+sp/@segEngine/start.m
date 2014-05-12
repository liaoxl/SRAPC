function ok=start(obj,labelImg)

ok=false;
[h,w]=size(labelImg);

geoImg=getGeoImg(obj,labelImg);

stPointsFG=find(labelImg==1);
pts=zeros(2,length(stPointsFG));
if(~isempty(stPointsFG))
  [pts(1,:),pts(2,:)]=ind2sub([h w],stPointsFG);
end

dFG=computeDistances(geoImg,pts);

stPointsBG=find(labelImg==2);
pts=zeros(2,length(stPointsBG));

if(~isempty(stPointsBG))
[pts(1,:),pts(2,:)]=ind2sub([h w],stPointsBG);
end

dBG=computeDistances(geoImg,pts);

seg=dFG<dBG;
obj.seg=255*uint8(seg);
ok=true;

function geoImg=getGeoImg(obj,labelImg)

opts=obj.opts;
switch(opts.spImg)
  case 'imgSmoothed'
    geoImg=obj.smoothedImg;
  case 'likelihoodImg'
    geoImg=sp.getPosteriorImage(obj.features,labelImg,opts); 
    obj.posteriorImage=geoImg;
end


function D=computeDistances(W,pts)
nb_iter_max =  1.2*max(size(W))^3;
[D,S,Q,stPoints] = sp.cpp.perform_front_propagation_2d_color(W,pts-1,[],nb_iter_max, [], []);
Q = Q+1;
stPoints=stPoints+1;

