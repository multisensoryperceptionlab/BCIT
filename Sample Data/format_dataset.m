
fprintf('\nThis helper function will guide you through the process of formatting your dataset')
fprintf('\nBefore we begin, make sure that you have the following variables in your workspace:\n')
fprintf('\n   subject:\tsubject identifier, numeric')
fprintf('\n         N:\tnumber of monte carlo trials, default 10000')
fprintf('\n stim_locs:\trow vector for all locations where stimuli could have been presented at')
fprintf('\n   numBins:\tnumber of steps to discretize space by, default 50')
fprintf('\n      stim:\tarray with columns for trials, rows for modalities. stores conds presentation')
fprintf('\n      resp:\tarray with columns for trials, rows for modalities. stores responses\n\n')

reply1 = input('Are you ready to move on? [y/n]: ','s');
if strcmp(reply1,'y')
    data = struct;
    reply_subject = input('\nWhat is the name of the variable for `subject`? ','s');
    if ~exist(reply_subject,'var')
        fprintf('\nvariable %s does not exist. Exitting\n',reply_subject)
        cont = false;
    else
        cont = true;
        eval(['data.subject = ' reply_subject ';'])
    end    
    if cont
        reply_N = input('\nWhat is the name of the variable for `N`? ','s');
        if ~exist(reply_N,'var')
            fprintf('\nvariable %s does not exist. Exitting\n',reply_N)
            cont = false;
        else
            cont = true;
            eval(['data.N = ' reply_N ';'])
        end        
    end
    if cont
        reply_stim_locs = input('\nWhat is the name of the variable for `stim_locs`? ','s');
        if ~exist(reply_stim_locs,'var')
            fprintf('\nvariable %s does not exist. Exitting\n',reply_stim_locs)
            cont = false;
        else
            cont = true;
            eval(['data.stim_locs = ' reply_stim_locs ';'])
            data.conds = flipud(fullfact([numel(data.stim_locs) numel(data.stim_locs)])'-1); % creating a label vector for the conditions (stimulus pairs)
            data.conds = data.stim_locs(data.conds(:,2:end)+1);
            fprintf('\nThe following variable is being created for you: \n     ');
            fprintf('conds:\tarray with columns for all stimulus combinations, rows for modalities\n')
        end        
    end
    if cont
        reply_numBins = input('\nWhat is the name of the variable for `numBins`? ','s');
        if ~exist(reply_numBins,'var')
            fprintf('\nvariable %s does not exist. Exitting\n',reply_numBins)
            cont = false;
        else
            cont = true;
            fprintf('\nThe following variable is being created for you: \n     ');
            fprintf('space:\trow vector for the discrete units of the space\n')
            eval(['data.numBins = ' reply_numBins ';'])
            sp_start = min(data.stim_locs); 
            sp_end = max(data.stim_locs);
            sp_pad = (sp_end - sp_start)/3;
            data.space = linspace(sp_start - sp_pad, sp_end + sp_pad, data.numBins);
        end       
    end
    if cont
        reply_stim = input('\nWhat is the name of the variable for `stim`? ','s');
        if ~exist(reply_stim,'var')
            fprintf('\nvariable %s does not exist. Exitting\n',reply_stim)
            cont = false;
        else
            cont = true;
            eval(['data.stim = ' reply_stim ';'])
        end        
    end
    if cont
        reply_resp = input('\nWhat is the name of the variable for `resp`? ','s');
        if ~exist(reply_resp,'var')
            fprintf('\nvariable %s does not exist. Exitting\n',reply_resp)
            cont = false;
        else
            cont = true;
            eval(['data.resp = ' reply_resp ';'])
            fprintf('\nThe following variable is being created for you: \n');
            fprintf('cond_resps:\tarray with columns as in conds, rows for trials. stores responses ordered by conds\n')
            data.numReps = sum((data.stim(1,:)==data.stim_locs(2)) .* (data.stim(2,:)==data.stim_locs(2)));
            data.cond_resps = nan(data.numReps,size(data.conds,2),2);
            for i=1:size(data.conds,2)
                if ~any(isnan(data.conds(:,i)))
                    inds = logical((data.stim(1,:)==data.conds(1,i)) .* (data.stim(2,:)==data.conds(2,i)));
                elseif isnan(data.conds(1,i))
                    inds = logical((isnan(data.stim(1,:))) .* (data.stim(2,:)==data.conds(2,i)));
                elseif isnan(data.conds(2,i))
                    inds = logical((data.stim(1,:)==data.conds(1,i)) .* isnan(data.stim(2,:)));
                end
                data.cond_resps(:,i,1) = data.resp(1,inds);
                data.cond_resps(:,i,2) = data.resp(2,inds);
            end
        end        
    end
    if cont
        reply_savename = input('\nWhat would you like to name the saved dataset? ','s');
        save(reply_savename,'data')
        clearvars('-except','data',reply_resp,reply_numBins,reply_stim,reply_stim_locs,reply_N,reply_subject)
    end
else
    fprintf('Exitting!\n')
end