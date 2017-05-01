function [pFits,error,selectionLab] = oneDim_Fitting

global subject numSeeds pFixed pcomBound pcom0 sigX1Bound sigX1_0
global sigX2Bound sigX2_0 sigPBound sigP0 meanPBound meanP0 deltaX1Bound
global deltaX1_0 deltaX2Bound deltaX2_0 deltaSigX1Bound deltaSigX1_0
global deltaSigX2Bound deltaSigX2_0 strategy tolerance
global first_time
first_time = true;
temp = load(subject);
data = temp.data;
free_params = isnan(pFixed);
allBound = cat(1,pcomBound,sigX1Bound,sigX2Bound,sigPBound,meanPBound,deltaX1Bound,deltaX2Bound,deltaSigX1Bound,deltaSigX2Bound)';
vars0 = cat(2,pcom0',sigX1_0',sigX2_0',sigP0',meanP0',deltaX1_0',deltaX2_0',deltaSigX1_0',deltaSigX2_0');
allBound = allBound(:,free_params);
vars0 = vars0(:,free_params);
varsLB = allBound(1,:);
varsUB = allBound(2,:);
paramNum = sum(free_params);
opts = optimset('fminsearch');
opts.Display = 'none';
if ~isnan(tolerance),opts.TolFun = tolerance;end
opts.TolX = 1e20;
opts.OutputFcn = @myoutput;
chosen_strats = logical(strategy);
selectionLabels = {'Pmatching','Averaging','Selection'};
selectionLabels = selectionLabels(chosen_strats);
selections = [];
strategy_numbers = [-1 0 1];
for i = 1:3
    if strategy(i)
        selections = [selections repmat(strategy_numbers(i),1,numSeeds)]; %#ok<AGROW>
    end
end
numStrats = numel(find(chosen_strats));
vars0Sliced = repmat(vars0,numStrats,1);
pFitsAll = zeros(numSeeds*numStrats,paramNum);
errorAll = zeros(1,numSeeds*numStrats);

caught = false;
hw = waitbar(0,'Initializing model parameters...','CreateCancelBtn',...
    {@(H,~) delete( findobj( get(H,'Parent'), '-Depth', 1, 'Tag', 'TMWWaitbar'))});
set(findobj(hw,'type','patch'),'edgecolor','g','facecolor','g')
for seed = 1:(numSeeds*numStrats)
    try
        waitbar(seed/(numSeeds*numStrats),hw,sprintf('Fitting Model - %d%% done...',...
            round(seed*100/(numSeeds*numStrats))));
    catch
        caught = true;
        break
    end
    [pFitsAll(seed,:), errorAll(seed)] = fminsearchbnd(@(p) ...
        bciModel(p, pFixed, data, selections(seed), 0), vars0Sliced(seed,:), varsLB, varsUB, opts);
    fprintf('%d out of %d optimizations completed at %s\n',seed,numSeeds*numStrats,datestr(now,'HH:MM:SS'))
end
delete(hw);

if ~caught
    indBest = find(errorAll==min(errorAll));
    pFits = pFitsAll(indBest,:)
    error = errorAll(indBest)
    selectionLab = selectionLabels(ceil(indBest/numSeeds));
    selection = selections(indBest);
    save_fit_str = [num2str(data.subject) '_fitting_results.mat'];
    save(save_fit_str)
    bciModel(pFits, pFixed, data, selection, data.subject);
end
% close all
% bcimGUI
end


function [error, sim] = bciModel(paras, pFixed, data, selection, plot)

pFreeInds = find(isnan(pFixed));
pFree(pFreeInds) = find(pFreeInds);
if isnan(pFixed(1)); p_common = paras(pFree(1)); else p_common = pFixed(1); end
if isnan(pFixed(2)); sigX1 = paras(pFree(2)); else sigX1 = pFixed(2); end; varX1 = sigX1^2;
if isnan(pFixed(3)); sigX2 = paras(pFree(3)); else sigX2 = pFixed(3); end; varX2 = sigX2^2;
if isnan(pFixed(4)); sigP = paras(pFree(4)); else sigP = pFixed(4); end; varP = sigP^2;
if isnan(pFixed(5)); xP = paras(pFree(5)); else xP = pFixed(5); end
if isnan(pFixed(6)); delX1 = paras(pFree(6)); else delX1 = pFixed(6); end
if isnan(pFixed(7)); delX2 = paras(pFree(7)); else delX2 = pFixed(7); end
if isnan(pFixed(8)); delSigX1 = paras(pFree(8)); else delSigX1 = pFixed(8); end
if isnan(pFixed(9)); delSigX2 = paras(pFree(9)); else delSigX2 = pFixed(9); end
p_cutoff = 0.5;

% Variances of estimates given common or independent causes
var12_hat = 1/(1/varX1 + 1/varX2 + 1/varP);
var1_hat = 1/(1/varX1 + 1/varP);
var2_hat = 1/(1/varX2 + 1/varP);

% Variances used in computing probability of common or independent causes
var_common = varX1 * varX2 + varX1 * varP + varX2 * varP;
var1_indep = varX1 + varP;
var2_indep = varX2 + varP;

% Generation of fake data
x1 = bsxfun(@plus, data.conds(1,:)*delX1, sigX1 * delSigX1 * randn(data.N, 35));
x2 = bsxfun(@plus, data.conds(2,:)*delX2, sigX2 * delSigX2 * randn(data.N, 35));

% Bimodal estimates given common or independent causes
biInds = logical(~isnan(data.conds(1,:)).*~isnan(data.conds(2,:)));
s_hat_common = ((x1(:,biInds)/varX1) + (x2(:,biInds)/varX2) +...
    repmat(xP,data.N,sum(biInds))/varP) * var12_hat;
sV_hat_indep = ((x1(:,biInds)/varX1) + repmat(xP,data.N,sum(biInds))/varP) * var1_hat;
sT_hat_indep = ((x2(:,biInds)/varX2) + repmat(xP,data.N,sum(biInds))/varP) * var2_hat;

% Unimodal Estimates
uniInds1 = isnan(data.conds(2,:));
s1_hat_uni = ((x1(:,uniInds1)/varX1) + repmat(xP/varP,data.N,sum(uniInds1))) * var1_hat;
uniInds2 = isnan(data.conds(1,:));
s2_hat_uni = ((x2(:,uniInds2)/varX2) + repmat(xP/varP,data.N,sum(uniInds2))) * var2_hat;

% Probability of common or independent causes
quad_common = (x1(:,biInds)-x2(:,biInds)).^2 * varP +...
    (x1(:,biInds)-xP).^2 * varX2 +...
    (x2(:,biInds)-xP).^2 * varX1;
quad1_indep = (x1(:,biInds)-xP).^2;
quad2_indep = (x2(:,biInds)-xP).^2;

% Likelihood of observations (xV,xA) given C, for C=1 and C=2
likelihood_common = exp(-quad_common/(2*var_common))/(2*pi*sqrt(var_common));
likelihood1_indep = exp(-quad1_indep/(2*var1_indep))/sqrt(2*pi*var1_indep);
likelihood2_indep = exp(-quad2_indep/(2*var2_indep))/sqrt(2*pi*var2_indep);
likelihood_indep =  likelihood1_indep .* likelihood2_indep;

% Posterior probability of C given observations (xV,xA)
post_common = likelihood_common * p_common;
post_indep = likelihood_indep * (1-p_common);
pC = post_common./(post_common + post_indep);
match = 1 - rand(data.N, sum(biInds));

% Decision Strategies
if selection>0 %model selection
    selectionLabel = 'Selection';
    s1_hat_bi = (pC>p_cutoff).*s_hat_common + (pC<=p_cutoff).*sV_hat_indep;
    s2_hat_bi = (pC>p_cutoff).*s_hat_common + (pC<=p_cutoff).*sT_hat_indep;
elseif selection<0 %matching
    selectionLabel = 'Matching';
    s1_hat_bi = (pC>match).*s_hat_common + (pC<=match).*sV_hat_indep;
    s2_hat_bi = (pC>match).*s_hat_common + (pC<=match).*sT_hat_indep;
else  % Overall estimates: weighted averages
    selectionLabel = 'Averaging';
    s1_hat_bi = pC .* s_hat_common + (1-pC) .* sV_hat_indep;
    s2_hat_bi = pC .* s_hat_common + (1-pC) .* sT_hat_indep;
end

uniInds1_sim = repmat((find(uniInds1)*data.N)-data.N,data.N,1) + repmat((1:data.N)',1,sum(uniInds1));
uniInds2_sim = repmat((find(uniInds2)*data.N)-data.N,data.N,1) + repmat((1:data.N)',1,sum(uniInds2));
biInds_sim = repmat((find(biInds)*data.N)-data.N,data.N,1) + repmat((1:data.N)',1,sum(biInds));
uniInds1_sim = uniInds1_sim(:);
uniInds2_sim = uniInds2_sim(:);
biInds_sim = biInds_sim(:);

sim = nan(size(data.conds,2)*data.N,4);
sim(uniInds1_sim,1) = cat(1,ones(data.N,1),2*ones(data.N,1),3*ones(data.N,1),4*ones(data.N,1),5*ones(data.N,1));
sim(uniInds1_sim,3) = s1_hat_uni(:);
sim(uniInds2_sim,2) = cat(1,ones(data.N,1),2*ones(data.N,1),3*ones(data.N,1),4*ones(data.N,1),5*ones(data.N,1));
sim(uniInds2_sim,4) = s2_hat_uni(:);
sim(biInds_sim,1) = cat(1,ones(data.N*5,1),2*ones(data.N*5,1),3*ones(data.N*5,1),4*ones(data.N*5,1),5*ones(data.N*5,1));
sim(biInds_sim,3) = s1_hat_bi(:);
sim(biInds_sim,2) = repmat(cat(1,ones(data.N,1),2*ones(data.N,1),3*ones(data.N,1),4*ones(data.N,1),5*ones(data.N,1)),5,1);
sim(biInds_sim,4) = s2_hat_bi(:);

h = hist(s1_hat_bi, data.space);
freq_pred1_bi = bsxfun(@rdivide,h,sum(h));
h = hist(s1_hat_uni, data.space);
freq_pred1_uni = bsxfun(@rdivide,h,sum(h));
h = hist(s2_hat_bi, data.space);
freq_pred2_bi = bsxfun(@rdivide,h,sum(h));
h = hist(s2_hat_uni, data.space);
freq_pred2_uni = bsxfun(@rdivide,h,sum(h));

s = spline(data.space,freq_pred1_uni',data.cond_resps(:,uniInds1,1)');
[m,n,p] = size(s);
idx = logical(speye(m,n));
ss = reshape(s,m*n,p);
ss = ss(idx,:);
ss = reshape(ss,min(m,n),p)';
ss(ss<1e-5) = 1e-5;
spline1_uni = sum(sum(log(ss)));
s = spline(data.space,freq_pred2_uni',data.cond_resps(:,uniInds2,2)');
[m,n,p] = size(s);
idx = logical(speye(m,n));
ss = reshape(s,m*n,p);
ss = ss(idx,:);
ss = reshape(ss,min(m,n),p)';
ss(ss<1e-5) = 1e-5;
spline2_uni = sum(sum(log(ss)));
s = spline(data.space,freq_pred1_bi',data.cond_resps(:,biInds,1)');
[m,n,p] = size(s);
idx = logical(speye(m,n));
ss = reshape(s,m*n,p);
ss = ss(idx,:);
ss = reshape(ss,min(m,n),p)';
ss(ss<1e-5) = 1e-5;
spline1_bi = sum(sum(log(ss)));
s = spline(data.space,freq_pred2_bi',data.cond_resps(:,biInds,2)');
[m,n,p] = size(s);
idx = logical(speye(m,n));
ss = reshape(s,m*n,p);
ss = ss(idx,:);
ss = reshape(ss,min(m,n),p)';
ss(ss<1e-5) = 1e-5;
spline2_bi = sum(sum(log(ss)));

error = -(spline1_uni + spline1_bi + spline2_uni + spline2_bi);
if p_common < 0 || p_common > 1 || sigX1 < 0 || sigX2 < 0 || sigP < 0
    error = Inf;
end

if plot>0
    parameterTag = {'Subject ID', 'Strategy', 'P(C=1)', 'SD(X1)', 'SD(X2)',...
        'SD(Prior)', 'Mean(Prior)', 'delta_X1', 'delta_X2', 'delta_SD(X1)', 'delta_SD(X2)'};
    parameterTag(2,:) = {plot,selectionLabel,p_common,sigX1,sigX2,sigP,xP,delX1,delX2,delSigX1,delSigX2};
    bciPlot(data, sim, parameterTag);
end
end

function bciPlot(data, sim, parameterTag)
figSize = [1 1]; % 1st element width, 2nd height
figPos = [0 0]; % 1st element x, 2nd y
h = figure;
set(gcf,'WindowStyle', 'normal','units','normalized','position',[figPos,figSize],...
    'toolbar','none','menu','none','Name','Model Fitting Results');
set(0,'DefaultLineLineWidth',3);
scale = [min(data.space) max(data.space) 0 0.5];
trueVcol = [0.85,0.325,0.098];
trueTcol = [0,0.447,0.741];
Vcol = [0.85,0.325,0.098];
Tcol = [0,0.447,0.741];
nCon = numel(data.stim_locs);
alphaVal = 0.4;
s1 = subplot(nCon+1,nCon,1);hold on;
plot(0,0,':','Color',trueVcol)
plot(0,0,':','Color',trueTcol)
plot(0,0,'Color',Vcol)
plot(0,0,'Color',Tcol)
set(gca,'XTick', [], 'YTick', [])
box on
[hleg1, hobj1] = legend(s1,'X1 True','X2 True','X1 Fit','X2 Fit');
textobj = findobj(hobj1, 'type', 'text');
set(textobj, 'fontsize', 14);
set(hleg1,'position',get(s1,'position'));
for x1 = 1:nCon
    for x2 = 1:nCon
        if ~(x1==1 && x2==1)
            subplot(nCon+1,nCon,sub2ind([nCon,nCon],x2,x1));hold on;            
            if x1>1 && x2==1
                inds = find((data.stim(1,:)==data.stim_locs(x1)).*(isnan(data.stim(2,:))));
                [dist, ~] = histc(data.resp(1,inds),data.space);
                fill(data.space,dist/sum(dist),Vcol,'EdgeColor',Vcol,'FaceAlpha',alphaVal)
                Is = logical((sim(:,1)==(x1-1)).*isnan(sim(:,2)));
                [Ns, ~] = histc(sim(Is,3),data.space);
                plot(data.space,Ns/sum(Ns),'Color',Vcol);
                plot([data.stim(1,inds(1)) data.stim(1,inds(1))],[scale(3) scale(4)],':','Color',trueVcol);
            elseif x1>1
                inds = find((data.stim(1,:)==data.stim_locs(x1)).*(data.stim(2,:)==data.stim_locs(x2)));
                [dist, ~] = histc(data.resp(1,inds),data.space);
                fill(data.space,dist/sum(dist),Vcol,'EdgeColor',Vcol,'FaceAlpha',alphaVal)
                Is = logical((sim(:,1)==(x1-1)).*(sim(:,2)==(x2-1)));
                [Ns, ~] = histc(sim(Is,3),data.space);
                plot(data.space,Ns/sum(Ns),'Color',Vcol);
                plot([data.stim(1,inds(1)) data.stim(1,inds(1))],[scale(3) scale(4)],':','Color',trueVcol);
            end
            if x2>1 && x1==1
                inds = find((data.stim(2,:)==data.stim_locs(x2)).*(isnan(data.stim(1,:))));
                [dist, ~] = histc(data.resp(2,inds),data.space);
                fill(data.space,dist/sum(dist),Tcol,'EdgeColor',Tcol,'FaceAlpha',alphaVal)
                Is = logical(isnan(sim(:,1)).*(sim(:,2)==(x2-1)));
                [Ns, ~] = histc(sim(Is,4),data.space);
                plot(data.space,Ns/sum(Ns),'Color',Tcol);
                plot([data.stim(2,inds(1)) data.stim(2,inds(1))],[scale(3) scale(4)],':','Color',trueTcol);
            elseif x2>1
                inds = find((data.stim(1,:)==data.stim_locs(x1)).*(data.stim(2,:)==data.stim_locs(x2)));
                [dist, ~] = histc(data.resp(2,inds),data.space);
                fill(data.space,dist/sum(dist),Tcol,'EdgeColor',Tcol,'FaceAlpha',alphaVal)
                Is = logical((sim(:,1)==(x1-1)).*(sim(:,2)==(x2-1)));
                [Ns, ~] = histc(sim(Is,4),data.space);
                plot(data.space,Ns/sum(Ns),'Color',Tcol);
                plot([data.stim(2,inds(1)) data.stim(2,inds(1))],[scale(3) scale(4)],':','Color',trueTcol);
            end
            xlim([scale(1) scale(2)]);
            ylim([scale(3) scale(4)]);
            if x1~=nCon,set(gca,'XTick', []);end
            set(gca,'YTick', [])
            box on
        end
    end
end
param_fits_box = uipanel('Title','Optimized Parameters','FontSize',15,'Position',[.03,.03,.95,.15],'FontWeight','bold');
uitable('parent',param_fits_box,'data',parameterTag,'units','normalized','position',[0.05,0.05,.8,.9],'FontSize',12,...
    'rowname',[],'columnname',[]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 10]);

save_btn = uicontrol('parent',param_fits_box,'style','pushbutton','units','normalized',...
    'position',[0.9,0.05,0.1,0.3],'string','Screenshot',...
    'FontSize',13,'callback',@save);

    function save(varargin)
        answer = inputdlg('Screenshot Name?');
        if ~isempty(answer)
            set(save_btn,'visible','off');
            print(h,'-dpng','-r300',[answer{1} '.png']);
            set(save_btn,'visible','on');
        end
    end
end