function bcimGUI
% figure parameters
figSize = [600 400]; % 1st element width, 2nd height
figPos = [200 300]; % 1st element x, 2nd y

% Create figure
figure('NumberTitle', 'off');
set(gcf,'WindowStyle', 'normal',...
    'units','pixels',...
    'position',[figPos,figSize],...
    'toolbar','none',...
    'menu','none',...
    'Name','BCI Toolbox: Main Menu');

%Main Manu Panel
model = uipanel('Title','Model Type','FontSize',15,'Position',[0.1 0.25 0.8 0.6]);
parentColor = get(get(model, 'parent'), 'color');
set(model,'backgroundcolor',parentColor,'FontWeight','bold')

r1 = uicontrol('parent',model,'style','radio','units','normalized',...
    'position',[0.05,0.8,0.5,0.1],'string','1-D Continuous',...
    'backgroundcolor', parentColor,'FontSize',15,'value',1);
r2 = uicontrol('parent',model,'style','radio','units','normalized',...
    'position',[0.05,0.5,0.5,0.1],'string','1-D Discrete',...
    'backgroundcolor', parentColor,'FontSize',15);
r3 = uicontrol('parent',model,'style','radio','units','normalized',...
    'position',[0.05,0.2,0.5,0.1],'string','2-D Continuous',...
    'backgroundcolor', parentColor,'FontSize',15);

set(r1,'Userdata',[r2 r3],'Callback',@set_mutually_exclusive)
set(r2,'Userdata',[r1 r3],'Callback',@set_mutually_exclusive)
set(r3,'Userdata',[r1 r2],'Callback',@set_mutually_exclusive)


uicontrol('style','pushbutton','units','normalized',...
    'position',[0.15,0.08,0.2,0.1],'string','Simulate',...
    'FontSize',12,'callback',@simulate);
fitmodel=uicontrol('style','pushbutton','units','normalized',...
    'position',[0.65,0.08,0.2,0.1],'string','Fit Model',...
    'FontSize',12,'callback',@fitModel);

    function fitModel(varargin)
        if get(r1,'Value')
            FittingPanel('Continuous')
        end
    end


    function simulate(~,~)
        if get(r1,'Value')
            oneDim
        elseif get(r2,'Value')
            oneDimDiscrete
        elseif get(r3,'Value')
            twoDim
        end
    end


    function set_mutually_exclusive(varargin)
        current_obj = gcbo;
        objs_to_turn_off = get(current_obj,'Userdata');
        set(current_obj,'Value',1)
        set(objs_to_turn_off,'Value',0)
        if get(r1,'Value')
            set(fitmodel,'enable','on')
        elseif get(r3,'Value') || get (r2,'Value')
            set(fitmodel,'enable','off')
        end
    end
end
