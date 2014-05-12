setup;

srcPath='D:\Codes\Matlab\2013-12-27/CMM Image 10000/Saliency/';

filename=[srcPath, '0_287.jpg'];
[path name ext]=fileparts(filename);
sal_filename=[srcPath name '_RC.png'];

tic;
seg=srapc(filename,sal_filename,1);
toc;