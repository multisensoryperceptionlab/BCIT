function stop = myoutput(x, optimValues, ~)
persistent all_fvals all_x
global first_time
if first_time
    all_fvals = []; 
    all_x = []; 
    first_time = false;
elseif isempty(all_fvals) && isempty(all_x)
    all_fvals = optimValues.fval;
    all_x(1,:) = x;
    fprintf('ParamVals = '),fprintf('\t%f',x),fprintf('\tFunVal = %f\n',optimValues.fval)
elseif all_fvals(end)~=optimValues.fval && sum(all_x(end,:)==x)~=6
    all_fvals(end+1) = optimValues.fval;
    all_x(end+1,:) = x;    
    fprintf('ParamVals = '),fprintf('\t%f',x),fprintf('\tFunVal = %f\n',optimValues.fval)
end
stop = false;