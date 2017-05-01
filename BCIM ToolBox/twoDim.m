function twoDim
% Create Figure Window
% Create Figure Window
figSize = [1 1]; % 1st element width, 2nd height
figPos = [0 0]; % 1st element x, 2nd y
figure3 = figure('NumberTitle', 'off');
set(gcf,'WindowStyle', 'normal','units','normalized','Position',[figPos figSize],...
    'toolbar','none','menu','none','name','BCI Toolbox: Two-Dimension Continuous')

%%% Create Radio Buttons
settings = uipanel('Title','Settings','FontSize',15,'Position',[0.53 0.73 0.45 0.18]);
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
    'position',[0.7,0.7,0.3,0.15],'string','Spatiotemporal Prior',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);

% display
uicontrol('parent',settings,'Style','text','units','normalized','FontSize',12,...
    'Position',[0,0.3,0.2,0.25],'String','Model Estimates','backgroundcolor', parentColor);
mode_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.25,0.4,0.3,0.2],'string','Mode','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
mean_check= uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.48,0.4,0.3,0.2],'string','Mean',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);
disp_val_check = uicontrol('parent',settings,'style','checkbox','units','normalized',...
    'position',[0.7,0.4,0.3,0.2],'string','Display Values','value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@slider_callback);

% strategies
uicontrol('parent',settings,'Style','text','units','normalized','FontSize',12,...
    'Position',[0,0.05,0.2,0.25],'String','Decision Strategies','backgroundcolor', parentColor);
selection = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.25,0.1,0.3,0.2],'string','Model Selection',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);
averaging = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.45,0.1,0.3,0.2],'string','Model Averaging','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);
matching = uicontrol('parent',settings,'style','radio','units','normalized',...
    'position',[0.65,0.1,0.3,0.2],'string','Probability Matching',...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@set_mutually_exclusive);

set(selection,'Userdata',[averaging matching]);
set(averaging,'Userdata',[selection matching]);
set(matching,'Userdata',[selection averaging]);


%%% stimulus properties
stimulus = uipanel('Title','Stimulus','FontSize',15,...
    'Position',[0.53 0.55 0.45 0.15],'BackgroundColor',parentColor);
uipanel('Parent', stimulus,'Title',' Spatial ','FontSize',15,...
    'Position',[0.01 0.08 0.5 0.85],'BackgroundColor',parentColor);
uipanel('Parent', stimulus,'Title',' Temporal ','FontSize',15,...
    'Position',[0.52 0.08 0.47 0.85],'BackgroundColor',parentColor);

% slider1x
v1x_bnd = [-40 40]; slmin = -40; slmax = 40; v1x_start = -10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.02,0.5,0.1,0.2],'String','Stimulus 1','foregroundcolor','b','backgroundcolor', parentColor);
slider1x = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v1x_start,'units','normalized',...
    'position',[0.2,0.5,0.3,0.2],'Callback',{@slider_callback});
box1x = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.13,0.5,0.06,0.2],'String',num2str(v1x_start),'Callback',@box_callback);

% slider 2x
v2x_bnd = [-40 40]; slmin = -40; slmax = 40; v2x_start = 10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.02,0.17,0.1,0.2],'String','Stimulus 2','foregroundcolor','r','backgroundcolor',parentColor);
slider2x = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v2x_start,'units','normalized',...
    'position',[0.2,0.18,0.3,0.2],'Callback',{@slider_callback});
box2x = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.13,0.18,0.06,0.2],'String',num2str(v2x_start),'Callback',@box_callback);

% slider 1t
v1t_bnd = [-40 40]; slmin = -40; slmax = 40; v1t_start = -10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.53,0.5,0.1,0.2],'String','Stimulus 1','foregroundcolor','b','backgroundcolor', parentColor);
slider1t = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v1t_start,'units','normalized',...
    'position',[0.7,0.5,0.28,0.2],'Callback',{@slider_callback});
box1t = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.63,0.5,0.06,0.2],'String',num2str(v1t_start),'Callback',@box_callback);

% slider 2t
v2t_bnd = [-40 40]; slmin = -40; slmax = 40; v2t_start = 10;
uicontrol('parent',stimulus,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.53,0.17,0.1,0.2],'String','Stimulus 2','foregroundcolor','r','backgroundcolor',parentColor);
slider2t = uicontrol('parent',stimulus,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v2t_start,'units','normalized',...
    'position',[0.7,0.18,0.28,0.2],'Callback',{@slider_callback});
box2t = uicontrol('parent',stimulus,'Style','edit','units','normalized','position',[0.63,0.18,0.06,0.2],'String',num2str(v2t_start),'Callback',@box_callback);

%%% Parameters
parameters = uipanel('Title','Parameters','FontSize',15,...
    'Position',[0.53 0.13 0.45 0.38],'BackgroundColor',parentColor);
cf = 0.15/0.38;

% p-common
v3_bnd = [0 1]; slmin = 0; slmax = 1; v3_start = 0.5;
annotation(parameters,'textbox',[0.02,0.84,0.15,0.2*cf],'string','$P(C=1)$',...
    'interpreter','latex','linestyle','none','fontsize',16,'fontweight','bold');
slider3 = uicontrol('parent',parameters,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.01 0.01],'Value',v3_start,'units','normalized',...
    'position',[0.3,0.82,0.6,0.2*cf],'Callback',{@slider_callback}); %left, bottom, w, h
box3 = uicontrol('parent',parameters,'Style','edit','units','normalized','position',[0.18,0.82,0.1,0.2*cf],...
    'String',num2str(v3_start),'Callback',@box_callback);

% Spatial Parameters
spatial= uipanel('Parent', parameters,'Title',' Spatial ','FontSize',15,...
    'Position',[0.01 0.08 0.5 0.7],'BackgroundColor',parentColor);
cf2 = 0.15/0.2;

v41_bnd = [.1 50]; slmin = 0.1; slmax = 50; v41_start = 10;
annotation(spatial,'textbox',[0,0.8,0.25,0.2*cf2],'string','$\sigma_{1,X}$',...
    'Color','b','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider41 = uicontrol('parent',spatial,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v41_start,'units','normalized',...
    'position',[0.38,0.75,0.6,0.2*cf2],'Callback',{@slider_callback});
box41 = uicontrol('parent',spatial,'Style','edit','units','normalized',...
    'position',[0.25,0.77,0.12,0.2*cf2],'String',num2str(v41_start),'Callback',@box_callback);


v51_bnd = [.1 50]; slmin = 0.1; slmax = 50; v51_start = 10;
annotation(spatial,'textbox',[0,0.55,0.25,0.2*cf2],'string','$\sigma_{2,X}$',...
    'Color','r','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider51 = uicontrol('parent',spatial,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v51_start,'units','normalized',...
    'position',[0.38,0.5,0.6,0.2*cf2],'Callback',{@slider_callback});
box51 = uicontrol('parent',spatial,'Style','edit','units','normalized',...
    'position',[0.25,0.52,0.12,0.2*cf2],'String',num2str(v51_start),'Callback',@box_callback);

v61_bnd = [-40 40]; slmin = -40; slmax = 40; v61_start = 0;
annotation(spatial,'textbox',[0,0.3,0.25,0.2*cf2],'string','$\mu_{Prior,X}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider61 = uicontrol('parent',spatial,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v61_start,'units','normalized',...
    'position',[0.38,0.25,0.6,0.2*cf2],'Callback',{@slider_callback});
box61 = uicontrol('parent',spatial,'Style','edit','units','normalized',...
    'position',[0.25,0.27,0.12,0.2*cf2],'String',num2str(v61_start),'Callback',@box_callback);

v71_bnd = [.1 50]; slmin = .1; slmax = 50; v71_start = 20;
annotation(spatial,'textbox',[0,0.05,0.25,0.2*cf2],'string','$\sigma_{Prior,X}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider71 = uicontrol('parent',spatial,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v71_start,'units','normalized',...
    'position',[0.38,0,0.6,0.2*cf2],'Callback',{@slider_callback});
box71 = uicontrol('parent',spatial,'Style','edit','units','normalized',...
    'position',[0.25,0.02,0.12,0.2*cf2],'String',num2str(v71_start),'Callback',@box_callback);

% Temporal parameters
temporal= uipanel('parent',parameters,'Title',' Temporal ','FontSize',15,...
    'Position',[0.52 0.08 0.47 0.7],'BackgroundColor',parentColor);

v42_bnd = [.1 50]; slmin = 0.1; slmax = 50; v42_start = 10;
annotation(temporal,'textbox',[0,0.8,0.25,0.2*cf2],'string','$\sigma_{1,T}$',...
    'Color','b','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider42 = uicontrol('parent',temporal,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v42_start,'units','normalized',...
    'position',[0.38,0.75,0.6,0.2*cf2],'Callback',{@slider_callback});
box42 = uicontrol('parent',temporal,'Style','edit','units','normalized',...
    'position',[0.25,0.77,0.12,0.2*cf2],'String',num2str(v42_start),'Callback',@box_callback);


v52_bnd = [.1 50]; slmin = 0.1; slmax = 50; v52_start = 10;
annotation(temporal,'textbox',[0,0.55,0.25,0.2*cf2],'string','$\sigma_{2,T}$',...
    'Color','r','interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider52 = uicontrol('parent',temporal,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v52_start,'units','normalized',...
    'position',[0.38,0.5,0.6,0.2*cf2],'Callback',{@slider_callback});
box52 = uicontrol('parent',temporal,'Style','edit','units','normalized',...
    'position',[0.25,0.52,0.12,0.2*cf2],'String',num2str(v52_start),'Callback',@box_callback);

v62_bnd = [-40 40]; slmin = -40; slmax = 40; v62_start = 0;
annotation(temporal,'textbox',[0,0.3,0.25,0.2*cf2],'string','$\mu_{Prior,T}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider62 = uicontrol('parent',temporal,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[1 1]./(slmax-slmin),'Value',v62_start,'units','normalized',...
    'position',[0.38,0.25,0.6,0.2*cf2],'Callback',{@slider_callback});
box62 = uicontrol('parent',temporal,'Style','edit','units','normalized',...
    'position',[0.25,0.27,0.12,0.2*cf2],'String',num2str(v62_start),'Callback',@box_callback);

v72_bnd = [.1 50]; slmin = .1; slmax = 50; v72_start = 20;
annotation(temporal,'textbox',[0,0.05,0.25,0.2*cf2],'string','$\sigma_{Prior,T}$',...
    'Color',[0.4660 0.6740 0.1880],'interpreter','latex','linestyle','none','fontsize',22,'fontweight','bold');
slider72 = uicontrol('parent',temporal,'style','slider','Min',slmin,'Max',slmax,...
    'SliderStep',[0.1 0.1]./(slmax-slmin),'Value',v72_start,'units','normalized',...
    'position',[0.38,0,0.6,0.2*cf2],'Callback',{@slider_callback});
box72 = uicontrol('parent',temporal,'Style','edit','units','normalized',...
    'position',[0.25,0.02,0.12,0.2*cf2],'String',num2str(v72_start),'Callback',@box_callback);


% add a title for the plot
% uicontrol('Style','text','units','normalized',...
%     'Position',[0.06,0.9,0.4,0.04],'String','Two-dimension Plot of Continuous Estimates',...
%     'FontSize',18, 'backgroundcolor', parentColor);

% save & return button
uicontrol('style','pushbutton','units','normalized',...
    'position',[0.55,0.03,0.1,0.08],'string','Screenshot',...
    'FontSize',13,'callback',@save);

uicontrol('style','pushbutton','units','normalized',...
    'position',[0.7,0.03,0.1,0.08],'string','Reset to Default',...
    'FontSize',13,'callback',@reset);

uicontrol('style','pushbutton','units','normalized',...
    'position',[0.85,0.03,0.1,0.08],'string','Main Menu',...
    'FontSize',13,'callback',@returnToMain);


% Store gui data for later use
slider_callback(figure3,1);

    function save(~,~)
        answer = inputdlg('Screenshot Name?');
        if ~isempty(answer)
            saveas(figure3,answer{1});
        end
    end

    function reset(varargin)
        set(box1x, 'String', v1x_start);
        set(box2x, 'String', v2x_start);
        set(box1t, 'String', v1t_start);
        set(box2t, 'String', v2t_start);
        set(box3, 'String', v3_start);
        set(box41, 'String', v41_start);
        set(box51, 'String', v51_start);
        set(box61, 'String', v61_start);
        set(box71, 'String', v71_start);
        set(box42, 'String', v41_start);
        set(box52, 'String', v51_start);
        set(box62, 'String', v61_start);
        set(box72, 'String', v71_start);
        set(slider1x,'Value',v1x_start);
        set(slider2x,'Value',v2x_start);
        set(slider1t,'Value',v1t_start);
        set(slider2t,'Value',v2t_start);
        set(slider3,'Value',v3_start);
        set(slider41,'Value',v41_start);
        set(slider51,'Value',v51_start);
        set(slider61,'Value',v61_start);
        set(slider71,'Value',v71_start);
        set(slider42,'Value',v42_start);
        set(slider52,'Value',v52_start);
        set(slider62,'Value',v62_start);
        set(slider72,'Value',v72_start);
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
        close(figure3);
    end

    function slider_callback(~,~)
        v1 = get(slider3, 'Value');
        v2x = get(slider1x, 'Value');
        v3x = get(slider2x, 'Value');
        v2t = get(slider1t, 'Value');
        v3t = get(slider2t, 'Value');
        v41 = get(slider41, 'Value');
        v51 = get(slider51, 'Value');
        v42 = get(slider42, 'Value');
        v52 = get(slider52, 'Value');
        v61 = get(slider61, 'Value');
        v62 = get(slider62, 'Value');
        v71 = get(slider71, 'Value');
        v72 = get(slider72, 'Value');
        
        set(box3,'String',v1);
        set(box1x,'String',v2x);
        set(box2x,'String',v3x);
        set(box1t,'String',v2t);
        set(box2t,'String',v3t);
        set(box41,'String',v41);
        set(box51,'String',v51);
        set(box42,'String',v42);
        set(box52,'String',v52);
        set(box61,'String',v61);
        set(box62,'String',v62);
        set(box71,'String',v71);
        set(box72,'String',v72);
        
        bciPlot(v1,v2x,v2t,v3x,v3t,v41,v51,v42,v52,v61,v62,v71,v72);
    end

    function box_callback(varargin)
        if all(ismember(varargin{1}.String, '-.1234567890'))
            v1 = str2double(get(box3, 'String'));
            v2x = str2double(get(box1x, 'String'));
            v3x = str2double(get(box2x, 'String'));
            v2t = str2double(get(box1t, 'String'));
            v3t = str2double(get(box2t, 'String'));
            v41 = str2double(get(box41, 'String'));
            v51 = str2double(get(box51, 'String'));
            v42 = str2double(get(box42, 'String'));
            v52 = str2double(get(box52, 'String'));
            v61 = str2double(get(box61, 'String'));
            v62 = str2double(get(box62, 'String'));
            v71 = str2double(get(box71, 'String'));
            v72 = str2double(get(box72, 'String'));
            
            v1 = (v1>v3_bnd(2))*v3_bnd(2) + (v1<=v3_bnd(2))*v1;
            v1 = (v1<v3_bnd(1))*v3_bnd(1) + (v1>=v3_bnd(1))*v1;
            v2x = (v2x>v1x_bnd(2))*v1x_bnd(2) + (v2x<=v1x_bnd(2))*v2x;
            v2x = (v2x<v1x_bnd(1))*v1x_bnd(1) + (v2x>=v1x_bnd(1))*v2x;
            v3x = (v3x>v2x_bnd(2))*v2x_bnd(2) + (v3x<=v2x_bnd(2))*v3x;
            v3x = (v3x<v2x_bnd(1))*v2x_bnd(1) + (v3x>=v2x_bnd(1))*v3x;
            v2t = (v2t>v1t_bnd(2))*v1t_bnd(2) + (v2t<=v1t_bnd(2))*v2t;
            v2t = (v2t<v1t_bnd(1))*v1t_bnd(1) + (v2t>=v1t_bnd(1))*v2t;
            v3t = (v3t>v2t_bnd(2))*v2t_bnd(2) + (v3t<=v2t_bnd(2))*v3t;
            v3t = (v3t<v2t_bnd(1))*v2t_bnd(1) + (v3t>=v2t_bnd(1))*v3t;
            v41 = (v41>v41_bnd(2))*v41_bnd(2) + (v41<=v41_bnd(2))*v41;
            v41 = (v41<v41_bnd(1))*v41_bnd(1) + (v41>=v41_bnd(1))*v41;
            v42 = (v42>v42_bnd(2))*v42_bnd(2) + (v42<=v42_bnd(2))*v42;
            v42 = (v42<v42_bnd(1))*v42_bnd(1) + (v42>=v42_bnd(1))*v42;
            v51 = (v51>v51_bnd(2))*v51_bnd(2) + (v51<=v51_bnd(2))*v51;
            v51 = (v51<v51_bnd(1))*v51_bnd(1) + (v51>=v51_bnd(1))*v51;
            v52 = (v52>v52_bnd(2))*v52_bnd(2) + (v52<=v52_bnd(2))*v52;
            v52 = (v52<v52_bnd(1))*v52_bnd(1) + (v52>=v52_bnd(1))*v52;
            v61 = (v61>v61_bnd(2))*v61_bnd(2) + (v61<=v61_bnd(2))*v61;
            v61 = (v61<v61_bnd(1))*v61_bnd(1) + (v61>=v61_bnd(1))*v61;
            v62 = (v62>v62_bnd(2))*v62_bnd(2) + (v62<=v62_bnd(2))*v62;
            v62 = (v62<v62_bnd(1))*v62_bnd(1) + (v62>=v62_bnd(1))*v62;
            v71 = (v71>v71_bnd(2))*v71_bnd(2) + (v71<=v71_bnd(2))*v71;
            v71 = (v71<v71_bnd(1))*v71_bnd(1) + (v71>=v71_bnd(1))*v71;
            v72 = (v72>v72_bnd(2))*v72_bnd(2) + (v72<=v72_bnd(2))*v72;
            v72 = (v72<v72_bnd(1))*v72_bnd(1) + (v72>=v72_bnd(1))*v72;
            
            set(box3, 'String', num2str(v1));
            set(box1x, 'String', num2str(v2x));
            set(box2x, 'String', num2str(v3x));
            set(box1t, 'String', num2str(v2t));
            set(box2t, 'String', num2str(v3t));
            set(box41, 'String', num2str(v41));
            set(box42, 'String', num2str(v42));
            set(box51, 'String', num2str(v51));
            set(box52, 'String', num2str(v52));
            set(box61,'String',num2str(v61));
            set(box62,'String',num2str(v62));
            set(box71,'String',num2str(v71));
            set(box72,'String',num2str(v72));
            
            set(slider3,'Value',v1);
            set(slider1x,'Value',v2x);
            set(slider2x,'Value',v3x);
            set(slider1t,'Value',v2t);
            set(slider2t,'Value',v3t);
            set(slider41,'Value',v41);
            set(slider51,'Value',v51);
            set(slider42,'Value',v42);
            set(slider52,'Value',v52);
            set(slider61,'Value',v61);
            set(slider62,'Value',v62);
            set(slider71,'Value',v71);
            set(slider72,'Value',v72);
            
            bciPlot(v1,v2x,v2t,v3x,v3t,v41,v51,v42,v52,v61,v62,v71,v72);
            
        else
            warndlg('Input must be numeric');
        end
    end

    function bciPlot(v1,v2x,v2t,v3x,v3t,v41,v51,v42,v52,v61,v62,v71,v72)
        global trueT trueV x
        
        % specify the location of the figure
        f = subplot(1,2,1);
        size = get(f,'Position');
        set(f,'Position',size + [-0.08 0 0.12 -0.08]);
        [~,freq_predV_X,freq_predT_X,freq_predV_T,freq_predT_T] = bciModel([[v1;v1],[v2x;v2t],[v3x;v3t],[v41;v42],[v51;v52],[v61;v62],[v71;v72]]);
        hold on;
        
        % True Positions
        p1 = plot3(trueV(1),trueV(2),zeros(1,2),'bo','MarkerFaceColor','b','MarkerSize',12,'MarkerEdgeColor','k');
        p2 = plot3(trueT(1),trueT(2),zeros(1,2),'ro','MarkerFaceColor','r','MarkerSize',12,'MarkerEdgeColor','k');
        legend_strs = {'Stimulus 1','Stimulus 2'};
        legend_vars = [p1(1) p2(1)];
        axis([-40 40 -40 40]);xlabel('Space (Arbitrary Units)','FontSize',16);ylabel('Time (Arbitrary Units)','FontSize',16)        
        set(gca,'fontsize',16);
        
        % posterior
        if get(posterior_check,'Value')==1
            p3 = plot3(100,100,0,'r-');
            p4 = plot3(100,100,0,'b-');
            contour(x,x,(freq_predV_T)'*(freq_predV_X),'LineColor','b');view(0,90);
            contour(x,x,(freq_predT_T)'*(freq_predT_X),'LineColor','r');view(0,90);
            legend_vars(end+1:end+2) = [p3 p4];
            legend_strs(end+1:end+2) = {'Resp. Distribution 1','Resp. Distribution 2'};
        end
        
        % likelihood
        if get(likelihood_check,'Value')==1
            p5 = plot3(100,100,0,'Color',[0.8500,0.3250,0.0980],'LineStyle','--');
            p6 = plot3(100,100,0,'Color',[0,0.4470,0.7410],'LineStyle','--');
            contour(x,x,normpdf(x,trueV(2),v42)'*normpdf(x,trueV(1),v41),'LineColor',[0.8500,0.3250,0.0980],'LineStyle','--')
            contour(x,x,normpdf(x,trueT(2),v52)'*normpdf(x,trueT(1),v51),'LineColor',[0,0.4470,0.7410],'LineStyle','--')
            legend_vars(end+1:end+2) = [p5 p6];
            legend_strs(end+1:end+2) = {'Stimulus Encoding 1','Stimulus Encoding 2'};
        end
        
        % prior
        if get(prior_check,'Value')==1
            p7 = plot3(100,100,0,'Color',[0.4660 0.6740 0.1880],'LineStyle','--');
            contour(x,x,normpdf(x,v62,v72)'*normpdf(x,v61,v71),'LineColor',[0.4660 0.6740 0.1880],'LineStyle','--');
            legend_vars(end+1) = p7;
            legend_strs(end+1) = {'Spatial Prior'};
        end
        
        % MAP estimates
        if get(mode_check,'Value')==1
            est_V = [x(find(freq_predV_T==max(freq_predV_T),1)); x(find(freq_predV_X==max(freq_predV_X),1))];
            est_T = [x(find(freq_predT_T==max(freq_predT_T),1)); x(find(freq_predT_X==max(freq_predT_X),1))];
            p8 = plot3(est_V(2),est_V(1),zeros(1,2),'bd','MarkerSize',12,'MarkerFaceColor','b','MarkerEdgeColor','k');
            p9 = plot3(est_T(2),est_T(1),zeros(1,2),'rd','MarkerSize',12,'MarkerFaceColor','r','MarkerEdgeColor','k');
            legend_vars(end+1:end+2) = [p8(1) p9(1)];
            legend_strs(end+1:end+2) = {'Mode 1','Mode 2'};
            if get(disp_val_check,'value')==1
                text(est_V(2)+1,est_V(1)+1,...
                    sprintf('(%.2f,%.2f)',est_V(2),est_V(1)),'fontsize',14)
                text(est_T(2)+1,est_T(1)+1,...
                    sprintf('(%.2f,%.2f)',est_T(2),est_T(1)),'fontsize',14)
            end
        end
        
        % Mean estimates
        if get(mean_check,'Value')==1
            vMean = [sum(x.*freq_predV_T) sum(x.*freq_predV_X)];
            tMean = [sum(x.*freq_predT_T) sum(x.*freq_predT_X)];
            p10 = plot3(vMean(2),vMean(1),zeros(1,2),'bs','MarkerSize',12,'MarkerFaceColor','b','MarkerEdgeColor','k');
            p11 = plot3(tMean(2),tMean(1),zeros(1,2),'rs','MarkerSize',12,'MarkerFaceColor','r','MarkerEdgeColor','k');
            legend_vars(end+1:end+2) = [p10(1) p11(1)];
            legend_strs(end+1:end+2) = {'Mean 1','Mean 2'};
            if get(disp_val_check,'value')==1
                text(vMean(2)+1,vMean(1)-1,...
                    sprintf('(%.2f,%.2f)',vMean(2),vMean(1)),'fontsize',14)
                text(tMean(2)+1,tMean(1)-1,...
                    sprintf('(%.2f,%.2f)',tMean(2),tMean(1)),'fontsize',14)
            end
        end
        
        % Legend
        legend(legend_vars,legend_strs,'Location',[0.08,0.72,0.1,0.1]);
        hold off;
    end

    function [pC,freq_predV_X,freq_predT_X,freq_predV_T,freq_predT_T] = bciModel(params)
        global trueT trueV x
        lowerBnd = -42; upperBnd = 42; numBins = 50;
        x = linspace(lowerBnd,upperBnd,numBins); % discretizing the space
        N = 10000;
        p_common = params(1,1);
        sigV = params(:,4); varV = sigV.^2;
        sigT = params(:,5); varT = sigT.^2;
        sigP = params(:,7); varP = sigP.^2;
        xP = params(:,6);
        var_common = varV .* varT + varV .* varP + varT .* varP;
        varVT_hat = 1./(1./varV + 1./varT + 1./varP);
        varV_hat = 1./(1./varV + 1./varP);
        varT_hat = 1./(1./varT + 1./varP);
        varV_indep = varV + varP;
        varT_indep = varT + varP;
        trueV = params(:,2);
        trueT = params(:,3);
        xV = bsxfun(@plus, trueV, repmat(sigV,1,N) .* randn(2, N));
        xT = bsxfun(@plus, trueT, repmat(sigT,1,N) .* randn(2, N));
        quad_common = (xV-xT).^2 .* repmat(varP,1,N) + (xV-repmat(xP,1,N)).^2 .* repmat(varT,1,N) + (xT-repmat(xP,1,N)).^2 .* repmat(varV,1,N);
        quadV_indep = (xV-repmat(xP,1,N)).^2;
        quadT_indep = (xT-repmat(xP,1,N)).^2;
        likelihood_common = bsxfun(@rdivide,exp(-quad_common./(2*repmat(var_common,1,N))),(2*pi*sqrt(var_common)));
        likelihood_common2 = likelihood_common(1,:) .* likelihood_common(2,:);
        likelihoodV_indep = bsxfun(@rdivide,exp(-quadV_indep./(2*repmat(varV_indep,1,N))),sqrt(2*pi*varV_indep));
        likelihoodT_indep = bsxfun(@rdivide,exp(-quadT_indep./(2*repmat(varT_indep,1,N))),sqrt(2*pi*varT_indep));
        likelihood_indep2 =  likelihoodV_indep(1,:) .* likelihoodV_indep(2,:) .* likelihoodT_indep(1,:) .* likelihoodT_indep(2,:);
        post_common = likelihood_common2 * p_common;
        post_indep = likelihood_indep2 * (1-p_common);
        pC = post_common./(post_common + post_indep);
        match = 1 - rand(1, N);
        s_hat_common = ((xV./repmat(varV,1,N)) + (xT./repmat(varT,1,N)) + repmat(xP,1,N)./repmat(varP,1,N)) .* repmat(varVT_hat,1,N);
        sV_hat_indep = ((xV./repmat(varV,1,N)) + repmat(xP,1,N)./repmat(varP,1,N)) .* repmat(varV_hat,1,N);
        sT_hat_indep = ((xT./repmat(varT,1,N)) + repmat(xP,1,N)./repmat(varP,1,N)) .* repmat(varT_hat,1,N);
        
        if get(selection, 'Value')
            sV_hat_X = (pC>0.5).*s_hat_common(1,:) + (pC<=0.5).*sV_hat_indep(1,:);
            sT_hat_X = (pC>0.5).*s_hat_common(1,:) + (pC<=0.5).*sT_hat_indep(1,:);
        elseif get(averaging, 'Value')
            sV_hat_X = (pC).*s_hat_common(1,:) + (1-pC).*sV_hat_indep(1,:);
            sT_hat_X = (pC).*s_hat_common(1,:) + (1-pC).*sT_hat_indep(1,:);
        elseif get(matching, 'Value')
            sV_hat_X = (pC>match).*s_hat_common(1,:) + (pC<=match).*sV_hat_indep(1,:);
            sT_hat_X = (pC>match).*s_hat_common(1,:) + (pC<=match).*sT_hat_indep(1,:);
        end
        
        h = hist(sV_hat_X, x);
        freq_predV_X = bsxfun(@rdivide,h,sum(h));
        h = hist(sT_hat_X, x);
        freq_predT_X = bsxfun(@rdivide,h,sum(h));
        
        if get(selection, 'Value')
            sV_hat_T = (pC>0.5).*s_hat_common(2,:) + (pC<=0.5).*sV_hat_indep(2,:);
            sT_hat_T = (pC>0.5).*s_hat_common(2,:) + (pC<=0.5).*sT_hat_indep(2,:);
        elseif get(averaging, 'Value')
            sV_hat_T = (pC).*s_hat_common(2,:) + (1-pC).*sV_hat_indep(2,:);
            sT_hat_T = (pC).*s_hat_common(2,:) + (1-pC).*sT_hat_indep(2,:);
        elseif get(matching, 'Value')
            sV_hat_T = (pC>match).*s_hat_common(2,:) + (pC<=match).*sV_hat_indep(2,:);
            sT_hat_T = (pC>match).*s_hat_common(2,:) + (pC<=match).*sT_hat_indep(2,:);
        end
        
        h = hist(sV_hat_T, x);
        freq_predV_T = bsxfun(@rdivide,h,sum(h));
        h = hist(sT_hat_T, x);
        freq_predT_T = bsxfun(@rdivide,h,sum(h));
        
    end

    function set_mutually_exclusive(varargin)
        current_obj = gcbo;
        objs_to_turn_off = get(current_obj,'Userdata');
        set(current_obj,'Value',1)
        set(objs_to_turn_off,'Value',0)
        slider_callback(gcbo);
    end
end