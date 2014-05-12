function [ok seg] = gscSegHandles(inImg, labelImg, otsuLabel)

ok=false;

%% Set handles

handles.data=[];

handles.data.debugLevel=1;
handles.data.drag=[];

handles.data.gamma=150;
handles.data.geoGamma=0.3;

handles.data.segMethod='GSC';

[h w nCh]=size(inImg);
handles.data.inImg=im2double(inImg);

handles.data.labelImg=labelImg;

handles.data.segmenterH=segOptions(handles.data);
handles.data.segmenterH.preProcess(handles.data.inImg)

ok=handles.data.segmenterH.start(handles.data.labelImg, otsuLabel);

seg=handles.data.segmenterH.seg;

end