function oneDim
% Create Figure Window
figSize = [1 1]; % 1st element width, 2nd height
figPos = [0 0]; % 1st element x, 2nd y
figure1 = figure('NumberTitle', 'off');
set(gcf,'WindowStyle', 'normal','units','normalized','Position',[figPos figSize],...
    'toolbar','none','menu','none','name','BCI Toolbox: One-Dimension Continuous')

% Create Radio Buttons
settings = uipanel('Title','Settings','FontSize',15,'Position',[0.53 0.65 0.45 0.2]);
parentColor = get(get(settings,'parent'),'color');
set(settings,'BackgroundColor',parentColor);

% type of plot
uicontrol('parent',settings,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.0,0.63,0.2,0.2],'String','Model Elements','backgroundcolor', parentColor);
posterior_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.25,0.7,0.3,0.15],'string','Resp. Distribution','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
likelihood_check = uicontrol('parent',settings, 'style','checkbox','units','normalized',...
    'position',[0.48,0.7,0.3,0.15],'string','Stimulus Encoding',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
prior_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.7,0.7,0.3,0.15],'string','Spatial Prior',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);

% display
uicontrol('parent',settings,'Style','text','units','normalized','FontSize',12,...
    'Position',[0,0.3,0.2,0.25],'String','Model Estimates','backgroundcolor', parentColor);
mode_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.25,0.4,0.3,0.2],'string','Mode','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
mean_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.48,0.4,0.3,0.2],'string','Mean',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
disp_val_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.7,0.4,0.3,0.2],'string','Display Values','value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);

% strategies
uicontrol('parent',settings,'Style','text','units','normalized','FontSize',12,...
    'Position',[0,0.037,0.2,0.2],'String','Decision Strategies','backgroundcolor', parentColor);
selection = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.25,0.1,0.3,0.2],'string','Model Selection',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);
averaging = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.48,0.1,0.3,0.2],'string','Model Averaging','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);
matching = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.7,0.1,0.3,0.2],'string','Probability Matching',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);

set(selection,'Userdata',[averaging matching]);
set(averaging,'Userdata',[selection matching]);
set(matching,'Userdata',[averaging selection]);


% Create Sliders

% stimulus properties
stimulus = uipanel('Title','Stimulus','FontSize',15,...
    'Position',[0.53 0.48 0.45 0.15],'BackgroundColor',parentColor);

% slider x1
v1_bnd = [-40 40];
slmin = v1_bnd(1); slmax = v1_bnd(2); v1_start = -10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.02,0.63,0.15,0.2],'String','Stimulus 1','ForegroundColor','b','backgroundcolor', parentColor);
slider1 = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v1_start,'units','normalized',...
    'position',[0.3,0.63,0.6,0.2],'Callback',{@slider_callback});
box1 = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.18,0.63,0.1,0.2],...
    'String',num2str(v1_start),'Callback',@box_callback);

% slider x2
slmin = v1_bnd(1); slmax = v1_bnd(2); v2_start = 10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.02,0.23,0.15,0.2],'String','Stimulus 2','ForegroundColor','r','backgroundcolor', parentColor);
slider2 = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v2_start,'units','normalized',...
    'position',[0.3,0.23,0.6,0.2],'Callback',{@slider_callback});
box2 = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.18,0.23,0.1,0.2],...
    'String',num2str(v2_start),'Callback',@box_callback);


%%% parameters
parameters = uipanel('Title','Parameters','FontSize',15,...
    'Position',[0.53 0.15 0.45 0.3],'BackgroundColor',parentColor);
cf = 0.15/0.25;

% slider 3
v3_bnd = [0 1];
slmin = v3_bnd(1); slmax = v3_bnd(2); v3_start = 0.5;
annotation(parameters,'textbox',[0.02,0.8,0.15,0.2*cf],'string','$P(C=1)$',...
    'interpreter','latex','linestyle','none','fontsize',16,'fontweight','bold');
slider3 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.01 0.01],'Value',v3_start,'units','normalized',...
    'position',[0.3,0.8,0.6,0.2*cf],'Callback',{@slider_callback}); %left, bottom, w, h
box3 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.8,0.1,0.2*cf],...
    'String',num2str(v3_start),'Callback',@box_callback);

% slider 4
v4_bnd = [0.1 50];
slmin = v4_bnd(1); slmax = v4_bnd(2); v4_start = 2;
annotation(parameters,'textbox',[0.02,0.64,0.15,0.2*cf],'string','$\sigma_1$',...
    'Color','b','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider4 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v4_start,'units','normalized',...
    'position',[0.3,0.64,0.6,0.2*cf],'Callback',{@slider_callback});
box4 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.64,0.1,0.2*cf],...
    'String',num2str(v4_start),'Callback',@box_callback);

% slider 5
v5_bnd = [0.1 50];
slmin = v5_bnd(1); slmax = v5_bnd(2); v5_start = 10;
annotation(parameters,'textbox',[0.02,0.46,0.15,0.2*cf],'string','$\sigma_2$',...
    'Color','r','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider5 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v5_start,'units','normalized',...
    'position',[0.3,0.46,0.6,0.2*cf],'Callback',{@slider_callback});
box5 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.46,0.1,0.2*cf],...
    'String',num2str(v5_start),'Callback',@box_callback);


% slider 6
v6_bnd = [0.1 50];
slmin = v6_bnd(1); slmax = v6_bnd(2); v6_start = 20;
annotation(parameters,'textbox',[0.02,0.28,0.15,0.2*cf],'string','$\sigma_{Prior}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider6 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v6_start,'units','normalized',...
    'position',[0.3,0.28,0.6,0.2*cf],'Callback',{@slider_callback});
box6 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.28,0.1,0.2*cf],...
    'String',num2str(v6_start),'Callback',@box_callback);


% slider 7
v7_bnd = [-40 40];
slmin = v7_bnd(1); slmax = v7_bnd(2); v7_start = 0;
annotation(parameters,'textbox',[0.02,0.1,0.15,0.2*cf],'string','$\mu_{Prior}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider7 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v7_start,'units','normalized',...
    'position',[0.3,0.1,0.6,0.2*cf],'Callback',{@slider_callback});
box7 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.1,0.1,0.2*cf],...
    'String',num2str(v7_start),'Callback',@box_callback);

%%% save & return button
uicontrol('style','pushbutton','units','normalized',...
    'position',[0.55,0.05,0.1,0.08],'string','Screenshot',...
    'FontSize',13,'callback',@save);

uicontrol('style','pushbutton','units','normalized',...
    'position',[0.7,0.05,0.1,0.08],'string','Reset to Default',...
    'FontSize',13,'callback',@reset);

uicontrol('style','pushbutton','units','normalized',...
    'position',[0.85,0.05,0.1,0.08],'string','Main Menu',...
    'FontSize',13,'callback',@returnToMain);

%%% Store gui data for later use
slider_callback(figure1,1);

    function save(varargin)
        answer = inputdlg('Screenshot Name?');
        if ~isempty(answer)
            saveas(figure1,answer{1});
        end
    end

    function reset(varargin)
        set(box1, 'String', v1_start);
        set(box2, 'String', v2_start);
        set(box3, 'String', v3_start);
        set(box4, 'String', v4_start);
        set(box5, 'String', v5_start);
        set(box6, 'String', v6_start);
        set(box7, 'String', v7_start);
        set(slider1,'Value',v1_start);
        set(slider2,'Value',v2_start);
        set(slider3,'Value',v3_start);
        set(slider4,'Value',v4_start);
        set(slider5,'Value',v5_start);
        set(slider6,'Value',v6_start);
        set(slider7,'Value',v7_start);
        set(posterior_check,'Value',1);
        set(likelihood_check,'Value',0);
        set(prior_check,'Value',0);
        set(averaging,'Value',1);
        set(matching,'Value',0);
        set(selection,'Value',0);
        set(mode_check,'Value',1);
        set(mean_check,'Value',0);
        set(disp_val_check,'Value',1);
        slider_callback;
    end

    function returnToMain(varargin)
        close(figure1);
    end

    function slider_callback(varargin)
        v1 = get(slider1, 'Value');
        v2 = get(slider2,'Value');
        v3 = get(slider3, 'Value');
        v4 = get(slider4, 'Value');
        v5 = get(slider5, 'Value');
        v6 = get(slider6, 'Value');
        v7 = get(slider7, 'Value');
        
        set(box3,'String',v3);
        set(box1,'String',v1);
        set(box2,'String',v2);
        set(box4,'String',v4);
        set(box5,'String',v5);
        set(box6,'String',v6);
        set(box7,'String',v7);
        
        bciPlot(v3,v1,v2,v4,v5,v6,v7);
    end

    function box_callback(varargin)
        if all(ismember(varargin{1}.String, '-.1234567890'))
            v1 = str2double(get(box1, 'String'));
            v2 = str2double(get(box2, 'String'));
            v3 = str2double(get(box3, 'String'));
            v4 = str2double(get(box4, 'String'));
            v5 = str2double(get(box5, 'String'));
            v6 = str2double(get(box6, 'String'));
            v7 = str2double(get(box7, 'String'));
            v1 = (v1>v1_bnd(2))*v1_bnd(2) + (v1<=v1_bnd(2))*v1;
            v1 = (v1<v1_bnd(1))*v1_bnd(1) + (v1>=v1_bnd(1))*v1;
            v2 = (v2>v1_bnd(2))*v1_bnd(2) + (v2<=v1_bnd(2))*v2;
            v2 = (v2<v1_bnd(1))*v1_bnd(1) + (v2>=v1_bnd(1))*v2;
            v3 = (v3>v3_bnd(2))*v3_bnd(2) + (v3<=v3_bnd(2))*v3;
            v3 = (v3<v3_bnd(1))*v3_bnd(1) + (v3>=v3_bnd(1))*v3;
            v4 = (v4>v4_bnd(2))*v4_bnd(2) + (v4<=v4_bnd(2))*v4;
            v4 = (v4<v4_bnd(1))*v4_bnd(1) + (v4>=v4_bnd(1))*v4;
            v5 = (v5>v5_bnd(2))*v5_bnd(2) + (v5<=v5_bnd(2))*v5;
            v5 = (v5<v5_bnd(1))*v5_bnd(1) + (v5>=v5_bnd(1))*v5;
            v6 = (v6>v6_bnd(2))*v6_bnd(2) + (v6<=v6_bnd(2))*v6;
            v6 = (v6<v6_bnd(1))*v6_bnd(1) + (v6>=v6_bnd(1))*v6;
            v7 = (v7>v7_bnd(2))*v7_bnd(2) + (v7<=v7_bnd(2))*v7;
            v7 = (v7<v7_bnd(1))*v7_bnd(1) + (v7>=v7_bnd(1))*v7;
            set(box1, 'String', num2str(v1));
            set(box2, 'String', num2str(v2));
            set(box3, 'String', num2str(v3));
            set(box4, 'String', num2str(v4));
            set(box5, 'String', num2str(v5));
            set(box6, 'String', num2str(v6));
            set(box7, 'String', num2str(v7));
            set(slider1,'Value',v1);
            set(slider2,'Value',v2);
            set(slider3,'Value',v3);
            set(slider4,'Value',v4);
            set(slider5,'Value',v5);
            set(slider6,'Value',v6);
            set(slider7,'Value',v7);
            
            bciPlot(v3,v1,v2,v4,v5,v6,v7);
            
        else
            warndlg('Input must be numeric');
        end
    end

    function bciPlot(v1,v21,v22,v3,v4,v5,v6)
        % specify the location of the figure
        f = subplot(1,2,1);
        size = get(f,'Position');
        set(f,'Position',size + [-0.08 0 0.12 -0.08]);        
        
        % Model Estimates
        [x,freq_predV_bi,freq_predT_bi] = bciModel([v1,v21,v22,v3,v4,v5,v6]);
        plot(-1000,-1000),hold on
        set(gca,'fontsize',16);
        
        % true position
        upper_margin = 0.1*max([freq_predV_bi,freq_predT_bi]);
        axis([min(x) max(x) 0 max([freq_predV_bi,freq_predT_bi])+upper_margin])
        p1 = line([v21 v21]',...
            [0 max([freq_predV_bi,freq_predT_bi])+upper_margin]',...
            'LineWidth',2,'LineStyle','--','Color',[0,0,1]');
        p2 = line([v22 v22]',...
            [0 max([freq_predV_bi,freq_predT_bi])+upper_margin]',...
            'LineWidth',2,'LineStyle','--','Color',[1,0,0]');
        legend_strs = {'Stimulus 1','Stimulus 2'};
        legend_vars = [p1 p2];
        xlabel('Space (Arbitrary Units)', 'Fontsize', 16);
        ylabel('Probability', 'Fontsize', 16);
        
        % likelihoods
        if get(likelihood_check,'Value')==1
            p3 = plot(x,normpdf(x,v21,v3),'LineWidth',2,'Color',[0,0.4470,0.7410],'LineStyle',':');
            p4 = plot(x,normpdf(x,v22,v4),'LineWidth',2,'Color',[0.8500,0.3250,0.0980],'LineStyle',':');
            legend_strs(end+1:end+2) = {'Stimulus Encoding 1','Stimulus Encoding 2'};
            legend_vars(end+1:end+2) = [p3 p4];
        end
        
        % prior
        if get(prior_check,'Value')==1
            p5 = plot(x,normpdf(x,v6,v5),'LineWidth',2,'Color',[0.4660 0.6740 0.1880],'LineStyle',':');
            legend_strs(end+1) = {'Spatial Prior'};
            legend_vars(end+1) = [p5];
        end
        
        % posterior
        if get(posterior_check,'Value')==1
            p6 = plot(x,freq_predV_bi,'LineWidth',2,'Color',[0,0,1]);
            p7 = plot(x,freq_predT_bi,'LineWidth',2,'Color',[1,0,0]);
            legend_strs(end+1:end+2) = {'Resp. Distribution 1','Resp. Distribution 2'};
            legend_vars(end+1:end+2) = [p6 p7];
        end
        
        % max estimates
        if get(mode_check,'Value')==1
            est_V = max(freq_predV_bi);
            est_T = max(freq_predT_bi);
            p8 = plot(x(find(freq_predV_bi==est_V,1)),...
                est_V,'bd','MarkerFaceColor','b','MarkerSize',12,'MarkerEdgeColor','k');
            p9 = plot(x(find(freq_predT_bi==est_T,1)),...
                est_T,'rd','MarkerFaceColor','r','MarkerSize',12,'MarkerEdgeColor','k');
            legend_strs(end+1:end+2) = {'Mode 1','Mode 2'};
            legend_vars(end+1:end+2) = [p8 p9];
            if get(disp_val_check,'value')==1
                text(x(find(freq_predV_bi==est_V,1))+1,est_V+upper_margin/3,...
                    sprintf('%.2f',x(find(freq_predV_bi==est_V,1))),'fontsize',14)
                text(x(find(freq_predT_bi==est_T,1))+1,est_T+upper_margin/3,...
                    sprintf('%.2f',x(find(freq_predT_bi==est_T,1))),'fontsize',14)
            end
        end
        
        % mean estimates
        if get(mean_check,'Value')==1
            est_V_x = sum(x.*freq_predV_bi);
            est_T_x = sum(x.*freq_predT_bi);
            est_V_y = spline(x, freq_predV_bi, est_V_x);
            est_T_y = spline(x, freq_predT_bi, est_T_x);
            p10 = plot(est_V_x, est_V_y, 'bs','MarkerFaceColor','b','MarkerSize',12,'MarkerEdgeColor','k');
            p11 = plot(est_T_x, est_T_y, 'rs','MarkerFaceColor','r','MarkerSize',12,'MarkerEdgeColor','k');
            legend_strs(end+1:end+2) = {'Mean 1','Mean 2'};
            legend_vars(end+1:end+2) = [p10 p11];
            if get(disp_val_check,'value')==1
                text(est_V_x+1,est_V_y+upper_margin/3,sprintf('%.2f',est_V_x),'fontsize',14)
                text(est_T_x+1,est_T_y+upper_margin/3,sprintf('%.2f',est_T_x),'fontsize',14)
            end
        end
        
        % legend
        legend(legend_vars,legend_strs,'Location',[0.07,0.73,0.1,0.1])
        hold off;
    end

    function [x,freq_predV_bi,freq_predT_bi] = bciModel(params)
        global trueT trueV
        lowerBnd = -42; upperBnd = 42; numBins = 50;
        x = linspace(lowerBnd,upperBnd,numBins); % discretizing the space
        N = 10000;
        p_common = params(1);
        x1 = params(2);
        x2 = params(3);
        sigV = params(4); varV = sigV^2;
        sigT = params(5); varT = sigT^2;
        sigP = params(6); varP = sigP^2;
        xP = params(7);
        var_common = varV * varT + varV * varP + varT * varP;
        varVT_hat = 1/(1/varV + 1/varT + 1/varP);
        varV_hat = 1/(1/varV + 1/varP);
        varT_hat = 1/(1/varT + 1/varP);
        varV_indep = varV + varP;
        varT_indep = varT + varP;
        trueV = x1;
        trueT = x2;
        xV = bsxfun(@plus, trueV, sigV * randn(N,1));
        xT = bsxfun(@plus, trueT, sigT * randn(N,1));
        quad_common = (xV-xT).^2 * varP + (xV-xP).^2 * varT + (xT-xP).^2 * varV;
        quadV_indep = (xV-xP).^2;
        quadT_indep = (xT-xP).^2;
        likelihood_common = exp(-quad_common/(2*var_common))/(2*pi*sqrt(var_common));
        likelihoodV_indep = exp(-quadV_indep/(2*varV_indep))/sqrt(2*pi*varV_indep);
        likelihoodT_indep = exp(-quadT_indep/(2*varT_indep))/sqrt(2*pi*varT_indep);
        likelihood_indep =  likelihoodV_indep .* likelihoodT_indep;
        post_common = likelihood_common * p_common;
        post_indep = likelihood_indep * (1-p_common);
        pC = post_common./(post_common + post_indep);
        s_hat_common = ((xV/varV) + (xT/varT) + repmat(xP,N,1)/varP) * varVT_hat;
        sV_hat_indep = ((xV/varV) + repmat(xP,N,1)/varP) * varV_hat;
        sT_hat_indep = ((xT/varT) + repmat(xP,N,1)/varP) * varT_hat;
        if get(selection, 'Value')
            sV_hat_bi = (pC>0.5).*s_hat_common + (pC<=0.5).*sV_hat_indep;
            sT_hat_bi = (pC>0.5).*s_hat_common + (pC<=0.5).*sT_hat_indep;
        elseif get(averaging, 'Value')
            sV_hat_bi = (pC).*s_hat_common + (1-pC).*sV_hat_indep;
            sT_hat_bi = (pC).*s_hat_common + (1-pC).*sT_hat_indep;
        elseif get(matching, 'Value')
            match = 1 - rand(N, 1);
            sV_hat_bi = (pC>match).*s_hat_common + (pC<=match).*sV_hat_indep;
            sT_hat_bi = (pC>match).*s_hat_common + (pC<=match).*sT_hat_indep;
        end
        
        h = hist(sV_hat_bi, x);
        freq_predV_bi = bsxfun(@rdivide,h,sum(h));
        h = hist(sT_hat_bi, x);
        freq_predT_bi = bsxfun(@rdivide,h,sum(h));
    end

    function set_mutually_exclusive(varargin)
        current_obj = gcbo;
        objs_to_turn_off = get(current_obj,'Userdata');
        set(current_obj,'Value',1)
        set(objs_to_turn_off,'Value',0)
        slider_callback(gcbo);
    end
end