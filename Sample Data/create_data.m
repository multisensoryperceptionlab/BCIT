% creating data structure
data.N = 10000; % number of Monte Carlo samples
data.numBins = 50; % number of steps to discretize space by
data.stim_locs = [nan -24 -12 0 12 24]; % the 5 candidate stimulus locations, and nan for unisensory
data.start = min(data.stim_locs); 
data.end = max(data.stim_locs);
data.pad = (data.end - data.start)/3;
data.space = linspace(data.start - data.pad, data.end + data.pad, data.numBins);
data.conds = flipud(fullfact([numel(data.stim_locs) numel(data.stim_locs)])'-1); % creating a label vector for the conditions (stimulus pairs)
data.conds = data.stim_locs(data.conds(:,2:end)+1); 

pcom = 0.5; % prior probability p(C=1)
sig1 = 2; % sigma of modality 1
sig2 = 5; % sigma of modality 2
sigP = 15; % sigma of spatial prior
muP = 0; % mean of spatial prior
strat = 1; % use -1 for model selection, 0 for model averaging, 1 for probability matching

data.params = [pcom sig1 sig2 sigP muP strat];

data.subject = 3; % subject identifier number

% pseudorandomly generates an order of conditions for the simulated trial sequence
order = randperm(size(data.conds,2));
while length(order)<2000
    temp = randperm(size(data.conds,2));
    while temp(1)==order(end)
        temp = randperm(size(data.conds,2));
    end
    order = [order temp]; %#ok<*AGROW>
end
data.order = order;
data.numReps = sum(data.order==1);

data.cond_resps = nan(data.numReps,size(data.conds,2),2);
for i = 1:size(data.conds,2)
    [pred1,pred2] = bciModel(data.params,data.conds(:,i),data.space,data.N);
    if ~isnan(data.conds(1,i))
        pop_1 = [];
        for ii = 1:data.numBins
            pop_1 = [pop_1; repmat(data.space(ii),round(pred1(ii)/min(pred1(pred1>0))),1)];
        end
        data.cond_resps(:,i,1) = randsample(pop_1,data.numReps,true);
    end
    if ~isnan(data.conds(2,i))
        pop_2 = [];
        for ii = 1:data.numBins
            pop_2 = [pop_2; repmat(data.space(ii),round(pred2(ii)/min(pred2(pred2>0))),1)];
        end
        data.cond_resps(:,i,2) = randsample(pop_2,data.numReps,true);
    end
end

% simulate the responses on every trial as determined by the trial sequence
temp = ones(1,size(data.conds,2),2);
for i = 1:length(order)
    data.stim(:,i) = data.conds(:,order(i));
    data.resp(:,i) = [nan; nan];
    if isnan(data.stim(1,i))
        temp_ind = find(isnan(data.conds(1,:)).*(data.conds(2,:)==data.stim(2,i)));
        data.resp(2,i) = data.cond_resps(temp(1,temp_ind,2),temp_ind,2);
        temp(1,temp_ind,2) = temp(1,temp_ind,2) + 1;
    elseif isnan(data.stim(2,i))
        temp_ind = find((data.conds(1,:)==data.stim(1,i)).*isnan(data.conds(2,:)));
        data.resp(1,i) = data.cond_resps(temp(1,temp_ind,1),temp_ind,1);
        temp(1,temp_ind,1) = temp(1,temp_ind,1) + 1;
    else
        temp_ind = find((data.conds(1,:)==data.stim(1,i)).*((data.conds(2,:)==data.stim(2,i))));
        data.resp(1,i) = data.cond_resps(temp(1,temp_ind,1),temp_ind,1);
        data.resp(2,i) = data.cond_resps(temp(1,temp_ind,2),temp_ind,2);
        temp(1,temp_ind,1) = temp(1,temp_ind,1) + 1;
        temp(1,temp_ind,2) = temp(1,temp_ind,2) + 1;
    end
end

save([num2str(data.subject) '.mat'],'data')