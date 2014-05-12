function seg = srapc(inFilename, inSalname, showflag)

seg=[];

% Detecting the Harris corner strength
inImg = imread(inFilename);
salImg = imread(inSalname);

[h w d]=size(inImg);

% If RGB then turn to gray
if d == 3
    grayImg = rgb2gray(inImg);
elseif d == 1
    grayImg = inImg;
end

% Use otsu to get binary cut with the saliency map
otsuImg = otsu(salImg);
otsuImg(find(otsuImg==1))=0;
otsuImg(find(otsuImg==2))=255;

otsuImg=uint8(otsuImg);

otsuLabel=uint8(zeros(size(otsuImg)));
otsuLabel(find(otsuImg==0))=2;
otsuLabel(find(otsuImg==255))=1;

% Find harris corner points
[cim, rows, cols] = harris2(grayImg, 3, 20, 3, showflag);

salPts=[rows cols];
if showflag==1
    hold on;
    plot(salPts(:,2),salPts(:,1),'g.','MarkerSize', 15);
end

%% Get the foreground corner points
otsuFgd=find(otsuImg==255);
[otsuFgdX otsuFgdY]=ind2sub(size(otsuImg), otsuFgd);
fgdPts=intersect(salPts, [otsuFgdX otsuFgdY], 'rows');


otsuBgd=find(otsuImg==0);
[otsuBgdX otsuBgdY]=ind2sub(size(otsuImg), otsuBgd);
bgdPts=intersect(salPts, [otsuBgdX otsuBgdY], 'rows');

fgdCnts = length(fgdPts);
if fgdCnts<=1
    seg=otsuImg;
    return;
end

if showflag==1
    figure, imshow(inImg);
    hold on;
    plot(fgdPts(:,2), fgdPts(:,1), 'g.','MarkerSize', 15);
end

%% Get the key points by apcluster
if fgdCnts > 3
    Sim = zeros(fgdCnts, fgdCnts);    
    for i=1: fgdCnts
        for j=1: fgdCnts
            Sim(i,j) = computeSim(inImg, fgdPts(i,:), fgdPts(j,:));
        end
    end    
    pref = median(median(Sim))*10;
    [idx,netsim,dpsim,expref]=apcluster(Sim,pref);
    ptsIdx=unique(idx);
    fgdPts=fgdPts(ptsIdx,:);
end

if showflag==1
    figure, imshow(inImg);
    hold on;
    plot(fgdPts(:,2), fgdPts(:,1), 'r.', 'MarkerSize', 20);
end


%% make label-image && make Brush
labelImage=uint8(zeros(size(grayImg)));
labelImage(sub2ind([h w], fgdPts(:,1), fgdPts(:,2)))=1;
sz=1;
brush=makeBrush(sz);
for i=1:length(fgdPts(:,1))
    labelImage=brushIt(labelImage, fgdPts(i,1), fgdPts(i,2), sz, brush);
end

% imwrite(labelImage, 'label.png');

iteration=1;

for i=1:iteration
    [ok seg]=gscSegHandles(inImg,labelImage,otsuLabel);
    otsuLabel(find(seg==0))=2;
    otsuLabel(find(seg==255))=1;
    if showflag==1
        figure, imshow(seg);
    end
end


end

function brush=makeBrush(sz)
  [x,y] = meshgrid(-sz:sz,-sz:sz);
  r = x.^2 + y.^2;
  brush = r<=(sz*sz);
  brush=uint8(brush);
end

function brushed=brushIt(labelImage, Idx, Idy, sz, brush)
  [h w d]=size(labelImage);
  for i=-sz:sz
      for j=-sz:sz
          if Idx+i>0 && Idx+i<=h && Idy+j>0 && Idy+j<=w && brush(sz+1+i,sz+1+j)==1
              labelImage(Idx+i,Idy+j)=labelImage(Idx,Idy);
          end
      end
  end
  brushed=labelImage;
end