function FittingPanel(str)
global numSeeds subject strategy
global pFixed pcomBound pcom0 sigX1Bound sigX1_0
global sigX2Bound sigX2_0 sigPBound sigP0 meanPBound meanP0 deltaX1Bound
global deltaX1_0 deltaX2Bound deltaX2_0 deltaSigX1Bound deltaSigX1_0
global deltaSigX2Bound deltaSigX2_0 tolerance
figSize = [1 1]; % 1st element width, 2nd height
figPos = [0 0]; % 1st element x, 2nd y
figure2 = figure('NumberTitle', 'off');
set(gcf,'WindowStyle', 'normal','units','normalized','Position',[figPos figSize],...
    'toolbar','none','menu','none','name','Model Fitting: Control Panel')
setting = uipanel('Title','Settings','FontSize',15,'Position',[0.1 0.75 0.8 0.2],...
    'FontWeight','bold');
parentColor = get(get(setting, 'parent'), 'color');
set(setting,'backgroundcolor',parentColor);

%%% strategies
uicontrol('parent',setting,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.62,0.2,0.15],'String','Decision Strategies','backgroundcolor', parentColor);

strategy1= uicontrol('parent',setting,'style','checkbox','units','normalized',...
    'position',[0.32,0.6,0.2,0.2],'string','Model Selection','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@strategy_choice);
strategy2 = uicontrol('parent',setting,'style','checkbox','units','normalized',...
    'position',[0.54,0.6,0.2,0.2],'string','Model Averaging','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@strategy_choice);
strategy3 = uicontrol('parent',setting,'style','checkbox','units','normalized',...
    'position',[0.76,0.6,0.2,0.2],'string','Probability Matching','Value',1,...
    'FontSize',13,'backgroundcolor', parentColor,'Callback',@strategy_choice);

strategy_choice;

%%%%%% Select a subject from files
uicontrol('parent',setting,'style','pushbutton','units','normalized',...
    'position',[0.05,0.2,0.17,0.3],'string','Select Data File',...
    'FontSize',14,'backgroundcolor', parentColor,'callback',@ChooseSubj);
subjFile = uicontrol('parent',setting,'style','text','units','normalized',...
    'position',[0.25,0.25,0.1,0.2],'backgroundcolor','white','callback',@ChooseSubj);

%%% input number of seeds
uicontrol('parent',setting,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.35,0.25,0.2,0.15],'String','Number of seeds','backgroundcolor', parentColor);
seedBox = uicontrol('parent',setting,'Style','edit','units','normalized',...
    'position',[0.55,0.25,0.1,0.2],'String',num2str(100),'Callback',@seed_callback);

%%% input tolerance
uicontrol('parent',setting,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.65,0.25,0.2,0.15],'String','Tolerance','backgroundcolor', parentColor);
toleranceBox = uicontrol('parent',setting,'Style','edit','units','normalized',...
    'position',[0.85,0.25,0.1,0.2],'String','','Callback',@tolerance_callback);
uicontrol('parent',setting,'Style','text','units','normalized','fontsize',12,...
    'position',[0.8,0.1,0.2,0.15],'String','Leave blank for default','foregroundcolor',[.4 .4 .4]);

seed_callback;
tolerance_callback;

parameters = uipanel('Title','Parameters','FontSize',15,'Position',[0.1 0.12 0.8 0.6]);
parentColor = get(get(parameters, 'parent'), 'color');
set(parameters,'backgroundcolor',parentColor,'FontWeight','bold')

uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.20,0.78,0.1,0.2],'String','Free Parameters','backgroundcolor', parentColor);
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.35,0.78,0.1,0.2],'String','Fixed Value','backgroundcolor', parentColor);
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.55,0.78,0.1,0.2],'String','Lower Bound','backgroundcolor', parentColor);
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',12,...
    'Position',[0.75,0.78,0.1,0.2],'String','Upper Bound','backgroundcolor', parentColor);

%%% p-common
pcomDefault=0.5; pcomBoundDefault = [0 1];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.8,0.2,0.1],'String','P(C=1)','backgroundcolor', parentColor);
pcomCheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.84,0.1,0.08],'backgroundcolor',parentColor,...
    'Value',1,'Callback',@checkbox_callback);
pcomFixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.86,0.1,0.05],'String',num2str(pcomDefault),'Callback',@edit_callback);
pcomLower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.86,0.1,0.05],'enable','off','String','','Callback',@edit_callback);
pcomUpper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.86,0.1,0.05],'enable','off','String','','Callback',@edit_callback);

%%% sigX1
sigX1Default=2; sigX1BoundDefault = [1 10];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.7,0.2,0.1],'String','SD(1)','backgroundcolor', parentColor);
sigX1CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.74,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',1,'Callback',@checkbox_callback);
sigX1Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.76,0.1,0.05],'String',num2str(sigX1Default),'Callback',@edit_callback);
sigX1Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.76,0.1,0.05],'enable','off','String',num2str(sigX1BoundDefault(1)),'Callback',@edit_callback);
sigX1Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.76,0.1,0.05],'enable','off','String',num2str(sigX1BoundDefault(2)),'Callback',@edit_callback);

%%% sigX2
sigX2Default=2; sigX2BoundDefault = [1 10];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.6,0.2,0.1],'String','SD(2)','backgroundcolor', parentColor);
sigX2CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.64,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',1,'Callback',@checkbox_callback);
sigX2Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.66,0.1,0.05],'String',num2str(sigX2Default),'Callback',@edit_callback);
sigX2Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.66,0.1,0.05],'enable','off','String',num2str(sigX2BoundDefault(1)),'Callback',@edit_callback);
sigX2Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.66,0.1,0.05],'enable','off','String',num2str(sigX2BoundDefault(2)),'Callback',@edit_callback);

%%% sigma_Prior
sigPDefault=10; sigPBoundDefault = [10 100];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.5,0.2,0.1],'String','SD(Prior)','backgroundcolor', parentColor);
sigPCheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.54,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',1,'Callback',@checkbox_callback);
sigPFixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.56,0.1,0.05],'String',num2str(sigPDefault),'Callback',@edit_callback);
sigPLower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.56,0.1,0.05],'enable','off','String',num2str(sigPBoundDefault(1)),'Callback',@edit_callback);
sigPUpper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.56,0.1,0.05],'enable','off','String',num2str(sigPBoundDefault(2)),'Callback',@edit_callback);

%%% mean_Prior
meanPDefault=0; meanPBoundDefault = [-40 40];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.4,0.2,0.1],'String','mean(Prior)','backgroundcolor', parentColor);
meanPCheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.44,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',0,'Callback',@checkbox_callback);
meanPFixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.46,0.1,0.05],'String',num2str(meanPDefault),'Callback',@edit_callback);
meanPLower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.46,0.1,0.05],'enable','off','String',num2str(meanPBoundDefault(1)),'Callback',@edit_callback);
meanPUpper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.46,0.1,0.05],'enable','off','String',num2str(meanPBoundDefault(2)),'Callback',@edit_callback);

%%% delta_X1
deltaX1Default=1; deltaX1BoundDefault = [1 5];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.3,0.2,0.1],'String','delta_1','backgroundcolor', parentColor);
deltaX1CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.34,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',0,'Callback',@checkbox_callback);
deltaX1Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.36,0.1,0.05],'String',num2str(deltaX1Default),'Callback',@edit_callback);
deltaX1Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.36,0.1,0.05],'enable','off','String',num2str(deltaX1BoundDefault(1)),'Callback',@edit_callback);
deltaX1Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.36,0.1,0.05],'enable','off','String',num2str(deltaX1BoundDefault(2)),'Callback',@edit_callback);

%%% delta_X2
deltaX2Default=1; deltaX2BoundDefault = [1 5];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.2,0.2,0.1],'String','delta_2','backgroundcolor', parentColor);
deltaX2CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.24,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',0,'Callback',@checkbox_callback);
deltaX2Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.26,0.1,0.05],'String',num2str(deltaX2Default),'Callback',@edit_callback);
deltaX2Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.26,0.1,0.05],'enable','off','String',num2str(deltaX2BoundDefault(1)),'Callback',@edit_callback);
deltaX2Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.26,0.1,0.05],'enable','off','String',num2str(deltaX2BoundDefault(2)),'Callback',@edit_callback);

%%% delta_sigmaX1
deltaSigX1Default=1; deltaSigX1BoundDefault = [1 5];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0.1,0.2,0.1],'String','delta_SD(1)','backgroundcolor', parentColor);
deltaSigX1CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.14,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',0,'Callback',@checkbox_callback);
deltaSigX1Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.16,0.1,0.05],'String',num2str(deltaSigX1Default),'Callback',@edit_callback);
deltaSigX1Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.16,0.1,0.05],'enable','off','String',num2str(deltaSigX1BoundDefault(1)),'Callback',@edit_callback);
deltaSigX1Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.16,0.1,0.05],'enable','off','String',num2str(deltaSigX1BoundDefault(2)),'Callback',@edit_callback);

%%% delta_sigmaX2
deltaSigX2Default=1; deltaSigX2BoundDefault = [1 5];
uicontrol('parent',parameters,'Style','text','units','normalized','FontSize',14,...
    'Position',[0.05,0,0.2,0.1],'String','delta_SD(2)','backgroundcolor', parentColor);
deltaSigX2CheckBox = uicontrol('parent',parameters,'Style','checkbox','units','normalized',...
    'position',[0.25,0.04,0.1,0.1],'backgroundcolor',parentColor,...
    'Value',0,'Callback',@checkbox_callback);
deltaSigX2Fixed = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.35,0.06,0.1,0.05],'String',num2str(deltaSigX2Default),'Callback',@edit_callback);
deltaSigX2Lower = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.55,0.06,0.1,0.05],'enable','off','String',num2str(deltaSigX2BoundDefault(1)),'Callback',@edit_callback);
deltaSigX2Upper = uicontrol('parent',parameters,'Style','edit','units','normalized',...
    'position',[0.75,0.06,0.1,0.05],'enable','off','String',num2str(deltaSigX2BoundDefault(2)),'Callback',@edit_callback);

pcomCurrent = pcomDefault;
pcomBoundCurrent = pcomBoundDefault;
sigX1Current = sigX1Default;
sigX1BoundCurrent = sigX1BoundDefault;
sigX2Current = sigX2Default;
sigX2BoundCurrent = sigX2BoundDefault;
sigPCurrent = sigPDefault;
sigPBoundCurrent = sigPBoundDefault;
meanPCurrent = meanPDefault;
meanPBoundCurrent = meanPBoundDefault;
deltaX1Current = deltaX1Default;
deltaX1BoundCurrent =  deltaX1BoundDefault;
deltaX2Current = deltaX2Default;
deltaX2BoundCurrent =  deltaX2BoundDefault;
deltaSigX1Current = deltaSigX1Default;
deltaSigX1BoundCurrent =  deltaSigX1BoundDefault;
deltaSigX2Current = deltaSigX2Default;
deltaSigX2BoundCurrent =  deltaSigX2BoundDefault;

%%% NEXT button
uicontrol('style','pushbutton','units','normalized','position',[0.7,0.02,0.2,0.08],...
    'string','Start Fitting','FontSize',13,'callback',@startFitting);

%%% BACK BUTTON
uicontrol('style','pushbutton','units','normalized',...
    'position',[0.1,0.02,0.2,0.08],'string','Main Menu',...
    'FontSize',13,'callback',@back);

%%% RESET BUTTON
uicontrol('style','pushbutton','units','normalized',...
    'position',[0.4,0.02,0.2,0.08],'string','Reset to Default',...
    'FontSize',13,'callback',@reset);

    function reset(~,~)
        set(seedBox, 'String', num2str(100));
        set(toleranceBox, 'String', num2str(100));
        set(pcomCheckBox, 'Value', 1);
        set(pcomFixed, 'enable', 'off', 'String', '');
        set(pcomUpper, 'enable', 'on', 'String', num2str(pcomBoundDefault(2)));
        set(pcomLower, 'enable', 'on', 'String', num2str(pcomBoundDefault(1)));
        pcomCurrent = pcomDefault;
        set(sigX1CheckBox, 'Value', 1);
        set(sigX1Fixed, 'enable', 'off', 'String', '');
        set(sigX1Upper, 'enable', 'on', 'String', num2str(sigX1BoundDefault(2)));
        set(sigX1Lower, 'enable', 'on', 'String', num2str(sigX1BoundDefault(1)));
        sigX1Current = sigX1Default;
        set(sigX2CheckBox, 'Value', 1);
        set(sigX2Fixed, 'enable', 'off', 'String', '');
        set(sigX2Upper, 'enable', 'on', 'String', num2str(sigX2BoundDefault(2)));
        set(sigX2Lower, 'enable', 'on', 'String', num2str(sigX2BoundDefault(1)));
        sigX2Current = sigX2Default;
        set(sigPCheckBox, 'Value', 1);
        set(sigPFixed, 'enable', 'off', 'String', '');
        set(sigPUpper, 'enable', 'on', 'String', num2str(sigPBoundDefault(2)));
        set(sigPLower, 'enable', 'on', 'String', num2str(sigPBoundDefault(1)));
        sigPCurrent = sigPDefault;
        set(meanPCheckBox, 'Value', 0);
        set(meanPFixed, 'enable', 'on', 'String', num2str(meanPDefault));
        set(meanPUpper, 'enable', 'off', 'String', '');
        set(meanPLower, 'enable', 'off', 'String', '');
        meanPBoundCurrent = meanPBoundDefault;
        set(deltaX1CheckBox, 'Value', 0);
        set(deltaX1Fixed, 'enable', 'on', 'String', num2str(deltaX1Default));
        set(deltaX1Upper, 'enable', 'off', 'String','');
        set(deltaX1Lower, 'enable', 'off', 'String', '');
        deltaX1BoundCurrent = deltaX1BoundDefault;
        set(deltaX2CheckBox, 'Value', 0);
        set(deltaSigX1CheckBox, 'Value', 0);
        set(deltaSigX1Fixed, 'enable', 'on', 'String', num2str(deltaSigX1Default));
        set(deltaSigX1Upper, 'enable', 'off', 'String','');
        set(deltaSigX1Lower, 'enable', 'off', 'String', '');
        deltaSigX1BoundCurrent = deltaSigX1BoundDefault;
        set(deltaX2CheckBox, 'Value', 0);
        set(deltaX2Fixed, 'enable', 'on', 'String', num2str(deltaX2Default));
        set(deltaX2Upper, 'enable', 'off', 'String','');
        set(deltaX2Lower, 'enable', 'off', 'String', '');
        deltaX2BoundCurrent = deltaX2BoundDefault;
        set(deltaSigX2CheckBox, 'Value', 0);
        set(deltaSigX2Fixed, 'enable', 'on', 'String', num2str(deltaSigX2Default));
        set(deltaSigX2Upper, 'enable', 'off', 'String','');
        set(deltaSigX2Lower, 'enable', 'off', 'String', '');
        deltaSigX2BoundCurrent = deltaSigX2BoundDefault;
        set(strategy1,'Value',1);
        set(strategy2,'Value',1);
        set(strategy3,'Value',1);
        set(subjFile,'string','');
    end

checkbox_callback;

   function strategy_choice(~,~)
        strategy = [0 0 0];
        if get(strategy1,'Value')==1
            strategy(1) = 1;
        end
        if get(strategy2,'Value')==1
            strategy(2) = 1;
        end
        if get(strategy3,'Value')==1
            strategy(3) = 1;
        end
    end
    function ChooseSubj(~,~)
        [subject_file, subject_path] = uigetfile('*.mat','Select the subject');
        if isequal(subject,0)
            subject = [];
        else
            subject = fullfile(subject_path,subject_file);
            set(subjFile,'string',subject_file);
        end
    end
    function seed_callback(~,~)
        numSeeds = str2double(get(seedBox, 'String'));
    end
    function tolerance_callback(~,~)
        tolerance = str2double(get(toleranceBox, 'String'));
    end
    function back(~,~)
        close(figure2);
    end
    function edit_callback(~,~)
        if ~get(pcomCheckBox,'Value')
            pcomCurrent = str2double(get(pcomFixed, 'String'));
        else
            pcomBoundCurrent = [str2double(get(pcomLower,'String')),str2double(get(pcomUpper, 'String'))];
        end
        if ~get(sigX1CheckBox,'Value')
            sigX1Current = str2double(get(sigX1Fixed, 'String'));
        else
            sigX1BoundCurrent = [str2double(get(sigX1Lower,'String')),str2double(get(sigX1Upper, 'String'))];
        end
        if ~get(sigX2CheckBox,'Value')
            sigX2Current = str2double(get(sigX2Fixed, 'String'));
        else
            sigX2BoundCurrent = [str2double(get(sigX2Lower,'String')),str2double(get(sigX2Upper, 'String'))];
        end
        if ~get(sigPCheckBox,'Value')
            sigPCurrent = str2double(get(sigPFixed, 'String'));
        else
            sigPBoundCurrent = [str2double(get(sigPLower,'String')),str2double(get(sigPUpper, 'String'))];
        end
        if ~get(meanPCheckBox,'Value')
            meanPCurrent = str2double(get(meanPFixed, 'String'));
        else
            meanPBoundCurrent = [str2double(get(meanPLower,'String')),str2double(get(meanPUpper, 'String'))];
        end
        if ~get(deltaX1CheckBox,'Value')
            deltaX1Current = str2double(get(deltaX1Fixed, 'String'));
        else
            deltaX1BoundCurrent =  [str2double(get(deltaX1Lower,'String')),str2double(get(deltaX1Upper, 'String'))];
        end
        if ~get(deltaX2CheckBox,'Value')
            deltaX2Current = str2double(get(deltaX2Fixed, 'String'));
        else
            deltaX2BoundCurrent =  [str2double(get(deltaX2Lower,'String')),str2double(get(deltaX2Upper, 'String'))];
        end
        if ~get(deltaSigX1CheckBox,'Value')
            deltaSigX1Current = str2double(get(deltaSigX1Fixed, 'String'));
        else
            deltaSigX1BoundCurrent =  [str2double(get(deltaSigX1Lower,'String')),str2double(get(deltaSigX1Upper, 'String'))];
        end
        if ~get(deltaSigX2CheckBox,'Value')
            deltaSigX2Current = str2double(get(deltaSigX2Fixed, 'String'));
        else
            deltaSigX2BoundCurrent =  [str2double(get(deltaSigX2Lower,'String')),str2double(get(deltaSigX2Upper, 'String'))];
        end
    end
    function checkbox_callback(~,~)
        pFixed = NaN(1,9);
        % p_common
        if get(pcomCheckBox,'Value')
            pcomBound = [str2double(get(pcomLower,'String')),str2double(get(pcomUpper, 'String'))];
            pcom0 = linspace(0.1,0.9,numSeeds);
            set(pcomFixed,'enable','off','String','')
            set(pcomLower,'enable','on','String',num2str(pcomBoundCurrent(1)))
            set(pcomUpper,'enable','on','String',num2str(pcomBoundCurrent(2)))
        else
            pFixed(1) = str2double(get(pcomFixed, 'String'));
            pcom0 = nan(1,numSeeds);
            pcomBound = nan(1,2);
            set(pcomFixed,'enable','on','String',num2str(pcomCurrent))
            set(pcomLower,'enable','off','String','')
            set(pcomUpper,'enable','off','String','')
        end        
        % sigma_x1
        if get(sigX1CheckBox,'Value')
            sigX1Bound = [str2double(get(sigX1Lower, 'String')),str2double(get(sigX1Upper, 'String'))];
            sigX1_0 = range(sigX1Bound)*rand(1,numSeeds)+sigX1Bound(1);
            set(sigX1Fixed,'enable','off','String','')
            set(sigX1Lower,'enable','on','String',num2str(sigX1BoundCurrent(1)))
            set(sigX1Upper,'enable','on','String',num2str(sigX1BoundCurrent(2)))
        else
            pFixed(2) = str2double(get(sigX1Fixed, 'String'));
            sigX1Bound = nan(1,2);
            sigX1_0 = nan(1,numSeeds);
            set(sigX1Fixed,'enable','on','String',num2str(sigX1Current))
            set(sigX1Lower,'enable','off','String','')
            set(sigX1Upper,'enable','off','String','')
        end        
        % sigma_x2
        if get(sigX2CheckBox,'Value')
            sigX2Bound = [str2double(get(sigX2Lower, 'String')),str2double(get(sigX2Upper, 'String'))];
            sigX2_0 = range(sigX2Bound)*rand(1,numSeeds)+sigX2Bound(1);
            set(sigX2Fixed,'enable','off','String','')
            set(sigX2Lower,'enable','on','String',num2str(sigX2BoundCurrent(1)))
            set(sigX2Upper,'enable','on','String',num2str(sigX2BoundCurrent(2)))
        else
            pFixed(3) = str2double(get(sigX2Fixed, 'String'));
            sigX2Bound = nan(1,2);
            sigX2_0 = nan(1,numSeeds);
            set(sigX2Fixed,'enable','on','String',num2str(sigX2Current))
            set(sigX2Lower,'enable','off','String','')
            set(sigX2Upper,'enable','off','String','')
        end       
        % sigma_prior
        if get(sigPCheckBox,'Value')
            sigPBound = [str2double(get(sigPLower, 'String')),str2double(get(sigPUpper, 'String'))];
            sigP0 = range(sigPBound)*rand(1,numSeeds)+sigPBound(1);
            set(sigPFixed,'enable','off','String','')
            set(sigPLower,'enable','on','String',num2str(sigPBoundCurrent(1)))
            set(sigPUpper,'enable','on','String',num2str(sigPBoundCurrent(2)))
        else
            pFixed(4) = str2double(get(sigPFixed, 'String'));
            sigPBound = nan(1,2);
            sigP0 = nan(1,numSeeds);
            set(sigPFixed,'enable','on','String',num2str(sigPCurrent))
            set(sigPLower,'enable','off','String','')
            set(sigPUpper,'enable','off','String','')
        end        
        % mean_prior
        if get(meanPCheckBox,'Value')
            meanPBound = [str2double(get(meanPLower, 'String')),str2double(get(meanPUpper, 'String'))];
            meanP0 = range(meanPBound)*rand(1,numSeeds)+meanPBound(1);
            set(meanPFixed,'enable','off','String','')
            set(meanPLower,'enable','on','String',num2str(meanPBoundCurrent(1)))
            set(meanPUpper,'enable','on','String',num2str(meanPBoundCurrent(2)))
        else
            pFixed(5) = str2double(get(meanPFixed, 'String'));
            meanPBound = nan(1,2);
            meanP0 = nan(1,numSeeds);
            set(meanPFixed,'enable','on','String',num2str(meanPCurrent))
            set(meanPLower,'enable','off','String','')
            set(meanPUpper,'enable','off','String','')
        end       
        % delta_x1
        if get(deltaX1CheckBox,'Value')
            deltaX1Bound = [str2double(get(deltaX1Lower, 'String')),str2double(get(deltaX1Upper, 'String'))];
            deltaX1_0 = range(deltaX1Bound)*rand(1,numSeeds)+deltaX1Bound(1);
            set(deltaX1Fixed,'enable','off','String','')
            set(deltaX1Lower,'enable','on','String',num2str(deltaX1BoundCurrent(1)))
            set(deltaX1Upper,'enable','on','String',num2str(deltaX1BoundCurrent(2)))
        else
            pFixed(6) = str2double(get(deltaX1Fixed, 'String'));
            deltaX1Bound = nan(1,2);
            deltaX1_0 = nan(1,numSeeds);
            set(deltaX1Fixed,'enable','on','String',num2str(deltaX1Current))
            set(deltaX1Lower,'enable','off','String','')
            set(deltaX1Upper,'enable','off','String','')
        end        
        % delta_x2
        if get(deltaX2CheckBox,'Value')
            deltaX2Bound = [str2double(get(deltaX2Lower, 'String')),str2double(get(deltaX2Upper, 'String'))];
            deltaX2_0 = range(deltaX2Bound)*rand(1,numSeeds)+deltaX2Bound(1);
            set(deltaX2Fixed,'enable','off','String','')
            set(deltaX2Lower,'enable','on','String',num2str(deltaX2BoundCurrent(1)))
            set(deltaX2Upper,'enable','on','String',num2str(deltaX2BoundCurrent(2)))
        else
            pFixed(7) = str2double(get(deltaX2Fixed, 'String'));
            deltaX2Bound = nan(1,2);
            deltaX2_0 = nan(1,numSeeds);
            set(deltaX2Fixed,'enable','on','String',num2str(deltaX2Current))
            set(deltaX2Lower,'enable','off','String','')
            set(deltaX2Upper,'enable','off','String','')
        end        
        % delta_sigmaX1
        if get(deltaSigX1CheckBox,'Value')
            deltaSigX1Bound = [str2double(get(deltaSigX1Lower, 'String')),str2double(get(deltaSigX1Upper, 'String'))];
            deltaSigX1_0 = range(deltaSigX1Bound)*rand(1,numSeeds)+deltaSigX1Bound(1);
            set(deltaSigX1Fixed,'enable','off','String','')
            set(deltaSigX1Lower,'enable','on','String',num2str(deltaSigX1BoundCurrent(1)))
            set(deltaSigX1Upper,'enable','on','String',num2str(deltaSigX1BoundCurrent(2)))
        else
            pFixed(8) = str2double(get(deltaSigX1Fixed, 'String'));
            deltaSigX1Bound = nan(1,2);
            deltaSigX1_0 = nan(1,numSeeds);
            set(deltaSigX1Fixed,'enable','on','String',num2str(deltaSigX1Current))
            set(deltaSigX1Lower,'enable','off','String','')
            set(deltaSigX1Upper,'enable','off','String','')
        end        
        % delta_sigmaX2
        if get(deltaSigX2CheckBox,'Value')
            deltaSigX2Bound = [str2double(get(deltaSigX2Lower, 'String')),str2double(get(deltaSigX2Upper, 'String'))];
            deltaSigX2_0 = range(deltaSigX2Bound)*rand(1,numSeeds)+deltaSigX2Bound(1);
            set(deltaSigX2Fixed,'enable','off','String','')
            set(deltaSigX2Lower,'enable','on','String',num2str(deltaSigX2BoundCurrent(1)))
            set(deltaSigX2Upper,'enable','on','String',num2str(deltaSigX2BoundCurrent(2)))
        else
            pFixed(9) = str2double(get(deltaSigX2Fixed, 'String'));
            deltaSigX2Bound = nan(1,2);
            deltaSigX2_0 = nan(1,numSeeds);
            set(deltaSigX2Fixed,'enable','on','String',num2str(deltaSigX2Current))
            set(deltaSigX2Lower,'enable','off','String','')
            set(deltaSigX2Upper,'enable','off','String','')
        end
    end
    function startFitting(~,~)
        if isempty(subject)
            errordlg('No Subject File Loaded','missing_subj_error');
        else
            checkbox_callback
            set(findall(figure2,'-property','Enable'),'Enable','off')
            if ~exist('str','var')||strcmp(str,'Continuous')
                oneDim_Fitting;
            elseif strcmp(str,'Discrete')
                oneDimDiscrete_Fitting;
            end
            set(findall(figure2,'-property','Enable'),'Enable','on')
            checkbox_callback
        end
    end
end