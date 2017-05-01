function [pred1,pred2] = bciModel(params,stims,space,N)
%Basic parameters
p_common = params(1);
sig1 = params(2); var1 = sig1^2;
sig2 = params(3); var2 = sig2^2;
sigP = params(4); varP = sigP^2;
muP = params(5);
stim1 = stims(1);
stim2 = stims(2);

%Generation of different conditions/stim locations
var_common = var1 * var2 + var1 * varP + var2 * varP;
var12_hat = 1/(1/var1 + 1/var2 + 1/varP);
var1_hat = 1/(1/var1 + 1/varP);
var2_hat = 1/(1/var2 + 1/varP);
var1_indep = var1 + varP;
var2_indep = var2 + varP;
x1 = bsxfun(@plus, stim1, sig1 * randn(N,1));
x2 = bsxfun(@plus, stim2, sig2 * randn(N,1));

%Distance between stim locations
quad_common = (x1-x2).^2 * varP + (x1-muP).^2 * var2 + (x2-muP).^2 * var1;
quad1_indep = (x1-muP).^2;
quad2_indep = (x2-muP).^2;

%Likelihood calculations and 
likelihood_common = exp(-quad_common/(2*var_common))/(2*pi*sqrt(var_common));
likelihood1_indep = exp(-quad1_indep/(2*var1_indep))/sqrt(2*pi*var1_indep);
likelihood2_indep = exp(-quad2_indep/(2*var2_indep))/sqrt(2*pi*var2_indep);
likelihood_indep =  likelihood1_indep .* likelihood2_indep;
post_common = likelihood_common * p_common;
post_indep = likelihood_indep * (1-p_common);
pC = post_common./(post_common + post_indep);

%Perceived location of causes
s_hat_common = ((x1/var1) + (x2/var2) + repmat(muP,N,1)/varP) * var12_hat;
s1_hat_indep = ((x1/var1) + repmat(muP,N,1)/varP) * var1_hat;
s2_hat_indep = ((x2/var2) + repmat(muP,N,1)/varP) * var2_hat;

%Independent Causes
if any(isnan(stims))
    s1_hat = s1_hat_indep;
    s2_hat = s2_hat_indep;
else
    %Decision Strategies - Model Selection
    if params(end)<0 
        s1_hat = (pC>0.5).*s_hat_common + (pC<=0.5).*s1_hat_indep;
        s2_hat = (pC>0.5).*s_hat_common + (pC<=0.5).*s2_hat_indep;
        %Model Matching
    elseif params(end)==0
        s1_hat = (pC).*s_hat_common + (1-pC).*s1_hat_indep;
        s2_hat = (pC).*s_hat_common + (1-pC).*s2_hat_indep;
        %Model Averaging
    elseif params(end)>0
        match = 1 - rand(N, 1);
        s1_hat = (pC>match).*s_hat_common + (pC<=match).*s1_hat_indep;
        s2_hat = (pC>match).*s_hat_common + (pC<=match).*s2_hat_indep;
    end
end

%Prediction of location estimates
h1 = hist(s1_hat, space);
h2 = hist(s2_hat, space);

pred1 = bsxfun(@rdivide,h1,sum(h1));
pred2 = bsxfun(@rdivide,h2,sum(h2));
end