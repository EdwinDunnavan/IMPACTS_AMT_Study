
function [nAR_H,nAng_H,nAR_V,nAng_V] = get_ellip_dists_IMPACTS(mH,mV,varargin)

ang_edges = 0:5:90;
xedges = 0.1:0.05:1.0;

if nargin == 2

nAR_H = histcounts(mH.AR,xedges,'normalization','count');
nAR_H = nAR_H./sum(nAR_H);
nAng_H = histcounts(mH.EllipAng,ang_edges,'normalization','count');
nAng_H = nAng_H./sum(nAng_H);

nAR_V = histcounts(mV.AR,xedges,'normalization','count');
nAR_V = nAR_V./sum(nAR_V);
nAng_V = histcounts(mV.EllipAng,ang_edges,'normalization','count');
nAng_V = nAng_V./sum(nAng_V);

else 
nAR_H = histcounts(mH.AR(mH.habit==varargin{1}),xedges,'normalization','count');
nAR_H = nAR_H./sum(nAR_H);
nAng_H = histcounts(mH.EllipAng(mH.habit==varargin{1}),ang_edges,'normalization','count');
nAng_H = nAng_H./sum(nAng_H);

nAR_V = histcounts(mV.AR(mV.habit==varargin{1}),xedges,'normalization','count');
nAR_V = nAR_V./sum(nAR_V);
nAng_V = histcounts(mV.EllipAng(mV.habit==varargin{1}),ang_edges,'normalization','count');
nAng_V = nAng_V./sum(nAng_V);



end





end