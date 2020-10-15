function varargout = odqlab_verify(varargin)
% ODQLAB_VERIFY ODQLab Verification Window
%       Help message is unavailable yet

odqgui_input = find(strcmp(varargin, 'ODQ_Designer'));
if ~isempty(odqgui_input)
    handles.ODQDesign = varargin{odqgui_input+1};
else
    errordlg('Please design optimal dynamic quantizer','ERROR','modal');
    error('ODQ ERROR')
end

%  Initialization tasks
BSsize=get(handles.ODQDesign,'pos');
bgcolor=get(0,'defaultUicontrolBackgroundColor');
handles.ODQVerify = figure('Visible','off','Name','Verification Window',...
    'MenuBar','none','ToolBar','none','NumberTitle','off',...
    'pos',[BSsize(1)+20,BSsize(2)-50,1000,475],'color',bgcolor,...
    'CloseRequestFcn',@vw_close_fcn);

%%% Defalt Properties %%%
EditDf1=struct('Style','edit','Units','pixels','HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1],'FontName','\default','FontSize',9,'Enable','inactive');
EditDf2=struct('Style','edit','Units','pixels','HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1],'FontName','\default','FontSize',9);
TextDef=struct('Style','text','Units','pixels','HorizontalAlignment','left',...
    'FontName','\default','FontSize',9);
PbtnDef=struct('Style','pushbutton','Units','pixels','FontName','\default','FontSize',9);
PanlDef=struct('Units','pixels','FontWeight','bold','FontSize',12,'FontName','\default');
%%%
set(handles.ODQVerify,'defaultPatchEdgeColor','none')
%%%
uicontrol(handles.ODQVerify,'Style','text','Units','pixels','pos',[430,445,140,30],...
    'str','ODQLab','FontWeight','bold','FontSize',18,'FontName','\default')

odqdata=get(handles.ODQDesign,'UserData');
if size(odqdata.Q.a,1)>1000
    odqdata.E_inf='skipped';
else
    odqdata.E_inf = odqcost(odqdata.G,odqdata.Q,odqdata.d,inf);
end
staticQ.a  = 0;
staticQ.b1 = zeros(1,size(odqdata.G.c2,1));
staticQ.b2 = zeros(1,size(odqdata.G.c2,1));
staticQ.c  = zeros(size(odqdata.G.c2,1),1);
odqdata.E_max = odqcost(odqdata.G,staticQ,odqdata.d,inf);
odqdata.E_min = norm(odqdata.G.c1*odqdata.G.b2,inf)*odqdata.d/2;

if odqdata.stb
    StStb='STABLE';
else
    StStb='UNSTABLE';
end


handles.ResDQ=uipanel(handles.ODQVerify,PanlDef,'pos',[10,110,350,340],'Title','Designed Quantizer');
uicontrol(handles.ResDQ,TextDef,'pos',[10,290,50,20],'str','Stability');
uicontrol(handles.ResDQ,TextDef,'pos',[10,265,80,20],'str','Quantizer gain');
uicontrol(handles.ResDQ,TextDef,'pos',[20,245,50,20],'str','u -> v');
uicontrol(handles.ResDQ,TextDef,'pos',[20,220,50,20],'str','w -> v');
uicontrol(handles.ResDQ,TextDef,'pos',[10,195,65,20],'str','Dimension');
uicontrol(handles.ResDQ,TextDef,'pos',[160,290,50,20],'str','E(T,Q)');
uicontrol(handles.ResDQ,TextDef,'pos',[160,260,50,20],'str','E(Inf,Q)');
uicontrol(handles.ResDQ,TextDef,'pos',[160,225,90,30],'str',{'Lower bound','of E(Inf,Q)'});
uicontrol(handles.ResDQ,TextDef,'pos',[160,195,90,30],'str',{'Upper bound','of E(Inf,Q)'});
handles.stb    =uicontrol(handles.ResDQ,EditDf1,'pos',[80,290,70,20],'str',StStb);
handles.gain_uv=uicontrol(handles.ResDQ,EditDf1,'pos',[80,245,70,20],'str',odqdata.gain.uv);
handles.gain_wv=uicontrol(handles.ResDQ,EditDf1,'pos',[80,220,70,20],'str',odqdata.gain.wv);
handles.dim    =uicontrol(handles.ResDQ,EditDf1,'pos',[80,195,70,20],'str',size(odqdata.Q.a,1));
handles.E_T    =uicontrol(handles.ResDQ,EditDf1,'pos',[250,290,85,20],'str',odqdata.E);
handles.E_inf  =uicontrol(handles.ResDQ,EditDf1,'pos',[250,260,85,20],'str',odqdata.E_inf);
handles.E_min  =uicontrol(handles.ResDQ,EditDf1,'pos',[250,230,85,20],'str',odqdata.E_min);
handles.E_max  =uicontrol(handles.ResDQ,EditDf1,'pos',[250,200,85,20],'str',odqdata.E_max);

uicontrol(handles.ResDQ,'Style','text','Units','pixels','pos',[100,170,170,20],...
    'str','Singular value distribution','HorizontalAlignment','center',...
    'FontName','\default','FontSize',9);
handles.hnkl=axes('Parent',handles.ResDQ,'Units','pixels','pos',[80,20,210,150],'Box','on');

singular_xrange=0:size(odqdata.Hk.S,1)-1;
stairs(handles.hnkl,singular_xrange,diag(odqdata.Hk.S),'LineWidth',2);
set(handles.hnkl,'Yscale','log','YGrid','on');
redline=zeros(1,size(odqdata.Hk.S,1));
for n=1:size(odqdata.Hk.S,1)-1
    if odqdata.Hk.S(n+1,n+1)/odqdata.Hk.S(n,n)<0.1
        redline(n)=1;
    end
end
if max(redline)==1
    singular_yrange=get(handles.hnkl,'YLim');
    xredline=find(redline);
    for n=1:length(xredline)
        line([xredline(n) xredline(n)],singular_yrange,'color',[1 0 0],'Parent',handles.hnkl)
    end
    set(handles.hnkl,'XTick',xredline,'XTickLabel',xredline);
end

if strcmp(odqdata.connection,'lft')
    sysP='G';
else
    sysP='P';
end

handles.EzSim=uipanel(handles.ODQVerify,PanlDef,'pos',[365,10,625,440],'Title','Simulation');
uicontrol(handles.EzSim,TextDef,'pos',[ 35,400,100,15],'str','Reference input');
uicontrol(handles.EzSim,TextDef,'pos',[190,400,120,15],'str','Initial state');
uicontrol(handles.EzSim,TextDef,'pos',[190,380, 20,18],'str',sysP);
uicontrol(handles.EzSim,TextDef,'pos',[295,380, 20,18],'str','K');
uicontrol(handles.EzSim,TextDef,'pos',[410,400,100,15],'str','Simulation time');
handles.simR=uicontrol(handles.EzSim,EditDf2,'pos',[ 35,380,140,20],'str','sin(k)+0.5*cos(k)');
handles.iniP=uicontrol(handles.EzSim,EditDf2,'pos',[205,380, 80,20],'str','0');
handles.iniK=uicontrol(handles.EzSim,EditDf2,'pos',[310,380, 80,20],'str','0','Enable','off');
handles.simT=uicontrol(handles.EzSim,EditDf2,'pos',[410,380,100,20],'str','100');
uicontrol(handles.EzSim,PbtnDef,'pos',[530,370, 80,30],'str','Start',...
    'Callback',@startsim);

handles.simblock=axes('Parent',handles.EzSim,'Units','pixels','pos',[230 140 180 80],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off');
if strcmp(odqdata.connection,'ff')
    create_ff_block;
elseif strcmp(odqdata.connection,'fbiq')
    create_fbiq_block;
elseif strcmp(odqdata.connection,'fboq')
    create_fboq_block;
elseif strcmp(odqdata.connection,'lft')
    create_lft_block;
end

handles.axesu   =axes('Parent',handles.EzSim,'Units','pixels',...
    'pos',[ 40 235 250 120],'Box','on','XGrid','on','Ygrid','on');
handles.axesv   =axes('Parent',handles.EzSim,'Units','pixels',...
    'pos',[ 40  20 250 120],'Box','on','XGrid','on','Ygrid','on');
handles.axesz   =axes('Parent',handles.EzSim,'Units','pixels',...
    'pos',[360 235 250 120],'Box','on','XGrid','on','Ygrid','on');
handles.axesdiff=axes('Parent',handles.EzSim,'Units','pixels',...
    'pos',[360  20 250 120],'Box','on','XGrid','on','Ygrid','on');
ylabel(handles.axesu   ,'Quantizer input'  )
ylabel(handles.axesv   ,'Quantizer output' )
ylabel(handles.axesz   ,'Output')
ylabel(handles.axesdiff,'Output difference')

handles.SimBtns=uipanel(handles.ODQVerify,PanlDef,'pos',[10,60,350,50],'Title','Simulink');
uicontrol(handles.SimBtns,PbtnDef,'pos',[50,7,120,20],'str','Simulation only',...
    'Callback',@sim_callback);
uicontrol(handles.SimBtns,PbtnDef,'pos',[200,7,120,20],'str','Implement with xPC',...
    'Callback',@exp_callback,'enable','off');

handles.SaveBtns=uipanel(handles.ODQVerify,PanlDef,'pos',[10,10,350,50],'Title','E x p o r t');
uicontrol(handles.SaveBtns,PbtnDef,'pos',[50,7,120,20],...
    'str','Save to Workspace','Callback',@save_q_callback);
uicontrol(handles.SaveBtns,PbtnDef,'pos',[200,7,120,20],...
    'str','Save to MAT-file','Callback',@save_q_callback);

iniP=zeros(size(odqdata.(sysP).a,1),1);
set(handles.iniP,'str',mat2str(iniP));
if strncmp(odqdata.connection,'fb',2)
    set(handles.iniK,'Enable','on');
    iniK=zeros(size(odqdata.K.a,1),1);
    set(handles.iniK,'str',mat2str(iniK));
end
if odqdata.T~=inf
    set(handles.simT,'str',num2str(odqdata.T))
end

set(handles.ODQDesign,'UserData',odqdata)
varargout{1}=handles.ODQVerify;
set(handles.ODQVerify,'Visible','on');

    function vw_close_fcn(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        odqdata.flg.vw_open=0;
        set(handles.ODQDesign,'UserData',odqdata);
        delete(hObject);
    end


    function save_q_callback(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        callmode=get(hObject,'str');
        
        VWpos=get(handles.ODQVerify,'pos');
        handles.datasel=figure('Units','pixels','pos',[VWpos(1)+200 VWpos(2)+100 300 100],...
            'Visible','off','windowstyle','modal','Userdata','Qonly',...
            'Color',bgcolor,'MenuBar','none','ToolBar','figure','NumberTitle','off',...
            'Name','Which you want to save?');
        handles.selpnl=uibuttongroup(handles.datasel,'Units','pixels','BorderType','none',...
            'pos',[10 45 280 50],'SelectionChangeFcn',@datasel_changefcn);
        uicontrol(handles.selpnl,'Style','radiobutton','Tag','Qonly','Units','pixels',...
            'pos',[0 25 100 20],'str','Quantizer only')
        uicontrol(handles.selpnl,'Style','radiobutton','Tag','AllData','Units','pixels',...
            'pos',[0 0 200 20],'str','All Data (stored in structure array)')
        uicontrol(handles.datasel,PbtnDef,'str','OK','pos',[120 10 80 20],'Callback',@savedata_ok);
        uicontrol(handles.datasel,PbtnDef,'str','Cancel','pos',[210 10 80 20],'Callback',@savedata_ng)
        
        set(handles.datasel,'Visible','on')
        
        function datasel_changefcn(hObject, eventdata)
            switch get(eventdata.NewValue,'Tag')
                case 'Qonly'
                    set(handles.datasel,'UserData','Qonly');
                case 'AllData'
                    set(handles.datasel,'UserData','AllData');
            end
        end
        
        function savedata_ok(hObject, eventdata)
            save_flag=get(handles.datasel,'UserData');
            val_name=inputdlg('Variable name in workspace');
            if ~isempty(val_name{1})
                if strcmp(save_flag,'Qonly') && strcmp(callmode,'Save to Workspace')
                    assignin('base',val_name{1},odqdata.Q)
                    fprintf('Quantizer exported in Workspace!\n');
                elseif strcmp(save_flag,'AllData') && strcmp(callmode,'Save to Workspace')
                    odqdata_ex=data_export(odqdata);
                    assignin('base',val_name{1},odqdata_ex)
                    fprintf('Quantizer exported in Workspace!\n');
                elseif strcmp(save_flag,'Qonly') && strcmp(callmode,'Save to MAT-file')
                    odqsave.name='Quantizer'; 
                    eval(['odqsave.' val_name{1} '=' 'odqdata.Q;']);
                    [filename,pathname]=uiputfile('*.mat','Save quantizer to MAT-file','quantizer.mat');
                    if filename
                        save([pathname,filename],'-struct','odqsave',val_name{1})
                    end
                elseif strcmp(save_flag,'AllData') && strcmp(callmode,'Save to MAT-file')
                    odqdata_ex=data_export(odqdata); %#ok<NASGU>
                    odqsave.name='ODQ_DATA'; 
                    eval(['odqsave.' val_name{1} '=' 'odqdata_ex;']);
                    [filename, pathname]=uiputfile('*.mat','Save quantizer to MAT-file','quantizer.mat');
                    if filename
                        save([pathname filename],'-struct','odqsave',val_name{1})
                    end
                end
            end
            close(handles.datasel)
        end
        
        function savedata_ng(hObject, eventdata)
            close(handles.datasel)
        end
        
    end


    function odqdata_ex=data_export(odqdata)
        if ~strcmp(odqdata.connection,'lft')
            odqdata_ex.P          = odqdata.P;
            if ~strcmp(odqdata.connection,'ff')
                odqdata_ex.K          = odqdata.K;
            end
        end
        odqdata_ex.G          = odqdata.G;
        odqdata_ex.Q          = odqdata.Q;
        odqdata_ex.Hk         = odqdata.Hk;
        odqdata_ex.gamma      = odqdata.gamma;
        odqdata_ex.gain       = odqdata.gain;
        odqdata_ex.connection = odqdata.connection;
        odqdata_ex.d          = odqdata.d;
        odqdata_ex.T          = odqdata.T;
        odqdata_ex.solver     = odqdata.solver;
        odqdata_ex.dim        = size(odqdata.Q.a,1);
        odqdata_ex.E          = odqdata.E;
        odqdata_ex.E_inf      = odqdata.E_inf;
        odqdata_ex.E_min      = odqdata.E_min;
        odqdata_ex.E_max      = odqdata.E_max;
    end


    function startsim(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        G = odqdata.G;
        Q = odqdata.Q;
        d = odqdata.d;
        
        Rt=get(handles.simR,'str');
        x0_P=get(handles.iniP,'str');
        x0_K=get(handles.iniK,'str');
        kFinal=str2double(get(handles.simT,'str'));
        k=1:(kFinal+1); %#ok<NASGU>
        x  = zeros( size(G.a ,1) , kFinal+1 );
        xQ = zeros( size(G.a ,1) , kFinal+1 );
        z  = zeros( size(G.c1,1) , kFinal+1 );
        zQ = zeros( size(G.c1,1) , kFinal+1 );
        u  = zeros( size(G.c2,1) , kFinal+1 );
        uQ = zeros( size(G.c2,1) , kFinal+1 );
        xi = zeros( size(Q.a ,1) , kFinal+1 );
        v  = zeros( size(Q.c ,1) , kFinal+1 );
        
        t = 0:kFinal;
        flg.r_work  = 0;
        flg.x0_P_work = 0;
        flg.x0_K_work = 0;
        work_val = evalin('base','who');
        for i = 1:size(work_val)
            if strcmp(work_val(i,:),Rt)
                r=evalin('base',Rt);
                flg.r_work=1;
            end
            if strcmp(work_val(i,:),x0_P)
                x0_P=evalin('base',x0_K);
                flg.x0_P_work=1;
            end
            if strcmp(work_val(i,:),x0_K)
                x0_K=evalin('base',x0_K);
                flg.x0_K_work=1;
            end
        end
        if ~flg.r_work
            r = eval(Rt);
        end
        if isscalar(r)
            r = r*ones(1,kFinal+1);
        end
        if flg.x0_P_work
            x0_P2 = x0_P;
        else
            x0_P2 = eval(x0_P);
        end
        if flg.x0_K_work
            x0_K2 = x0_K;
        else
            x0_K2 = eval(x0_K);
        end
        if strcmp(odqdata.connection,'ff') || strcmp(odqdata.connection,'lft')
            x(:,1)  = x0_P2;
            xQ(:,1) = x0_P2;
        else
            x(:,1)  = [x0_P2;x0_K2];
            xQ(:,1) = [x0_P2;x0_K2];
        end
        %%% start simulation %%%
        for i=1:kFinal+1
            z(:,i)  = G.c1*x(:,i)  + G.d1*r(:,i);
            zQ(:,i) = G.c1*xQ(:,i) + G.d1*r(:,i);
            u(:,i)  = G.c2*x(:,i)  + G.d2*r(:,i);
            uQ(:,i) = G.c2*xQ(:,i) + G.d2*r(:,i);
            v(:,i)  = d*round( ( Q.c*xi(:,i) + uQ(:,i) )/d );
            xi(:,i+1) = Q.a*xi(:,i) + Q.b1*uQ(:,i) + Q.b2*v(:,i);
            x(:,i+1)  = G.a*x(:,i)  + G.b1*r(:,i) + G.b2*u(:,i);
            xQ(:,i+1) = G.a*xQ(:,i) + G.b1*r(:,i) + G.b2*v(:,i);
        end
        stairs(handles.axesu   ,t,uQ'    );
        stairs(handles.axesv   ,t,v'    );
        stairs(handles.axesz   ,t,zQ'   );
        stairs(handles.axesdiff,t,zQ'-z');
        ylabel(handles.axesu   ,'Quantizer input'  ,'FontSize',10)
        ylabel(handles.axesv   ,'Quantizer output' ,'FontSize',10)
        ylabel(handles.axesz   ,'Output'           ,'FontSize',10)
        ylabel(handles.axesdiff,'Output difference','FontSize',10)
        set(handles.axesu   ,'XGrid','on','YGrid','on')
        set(handles.axesv   ,'XGrid','on','YGrid','on')
        set(handles.axesz   ,'XGrid','on','YGrid','on')
        set(handles.axesdiff,'XGrid','on','YGrid','on')
    end


    function create_ff_block(hObject,eventdata)
        line([ 4 11],[11 11],'LineWidth',2,'Color',[0 0 1]);
        line([20 27],[11 11],'LineWidth',2,'Color',[1 0 0]);
        line([36 43],[11 11],'LineWidth',2,'Color',[0 0 0]);
        rectangle('pos',[28 8 8 6],'FaceColor',[0.7 0.3 1.0]);
        rectangle('pos',[12 8 8 6],'FaceColor',[1.0 1.0 0.0]);
        text(30.4,11,'$P$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(14.4,11,'$Q$','FontSize',14,'Interpreter','latex','Color',[0 0 0]);
        patch([10,12,10],[12,11,10],'b')
        patch([26,28,26],[12,11,10],'r')
        patch([42,44,42],[12,11,10],'k')
        rectangle('pos',[38 9.5 3 3],'Curvature',[1,1],'linewidth',1)
        rectangle('pos',[22 9.5 3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[1 0 0])
        rectangle('pos',[ 6 9.5 3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[0 0 1])
        line([39.5,39.5,44],[12.5,15,20],'LineWidth',1,'Color',[0 0 0])
        line([23.5,23.5, 8],[ 9.5, 4, 0],'LineWidth',1,'Color',[1 0 0])
        line([ 7.5, 7.5, 5],[12.5,15,20],'LineWidth',1,'Color',[0 0 1])
    end


    function create_fbiq_block(hObject,eventdata)
        line([ 0  7],[14 14],'LineWidth',2,'Color',[0 0 0]);
        line([16 19],[13 13],'LineWidth',2,'Color',[0 0 1]);
        line([28 31],[13 13],'LineWidth',2,'Color',[1 0 0]);
        line([40 47],[14 14],'LineWidth',2,'Color',[0 0 0]);
        line([40 42 42 5 5 7],[12 12 6 6 12 12],'LineWidth',2,'Color',[0 0 0]);
        rectangle('pos',[32 10 8 6],'FaceColor',[0.7 0.3 1.0]);
        rectangle('pos',[ 8 10 8 6],'FaceColor',[1.0 0.7 0.0]);
        rectangle('pos',[20 10 8 6],'FaceColor',[1.0 1.0 0.0]);
        text(34.4,13,'$P$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(10.4,13,'$K$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(22.4,13,'$Q$','FontSize',14,'Interpreter','latex','Color',[0 0 0]);
        patch([18,20,18],[14,13,12],'b')
        patch([30,32,30],[14,13,12],'r')
        patch([6,8,6;6,8,6;46,48,46]',[15,14,13;13,12,11;15,14,13]','k')
        line([44,44],[14,20],'LineWidth',1,'Color',[0 0 0])
        line([29,29, 8],[13, 4, 0],'LineWidth',1,'Color',[1 0 0])
        line([17,17,12],[13,18,20],'LineWidth',1,'Color',[0 0 1])
        % rectangle('pos',[9.625 6.625 0.75 0.75],'Curvature',[1,1],'LineWidth',1)
        % rectangle('pos',[2.625  5.25 0.75 0.75],'Curvature',[1,1],'LineWidth',1,'EdgeColor',[1 0 0])
        % rectangle('pos',[7.625 6.125 0.75 0.75],'Curvature',[1,1],'LineWidth',1,'EdgeColor',[0 0 1])
    end


    function create_fboq_block(hObject,eventdata)
        line([ 0  7],[16 16],'LineWidth',2,'Color',[0 0 0]);
        line([16 31],[15 15],'LineWidth',2,'Color',[0 0 0]);
        line([40 47],[16 16],'LineWidth',2,'Color',[0 0 0]);
        line([40 42 42 29],[14 14  8  8],'LineWidth',2,'Color',[0 0 1]);
        line([20  5  5  7],[ 8  8 14 14],'LineWidth',2,'Color',[1 0 0]);
        rectangle('pos',[32 12 8 6],'FaceColor',[0.7 0.3 1.0]);
        rectangle('pos',[ 8 12 8 6],'FaceColor',[1.0 0.7 0.0]);
        rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0]);
        text(34.4,15,'$P$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(10.4,15,'$K$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(22.4, 8,'$Q$','FontSize',14,'Interpreter','latex','Color',[0 0 0]);
        patch([30,28,30],[ 9, 8, 7],'b')
        patch([ 6, 8, 6],[15,14,13],'r')
        patch([6,8,6;30,32,30;46,48,46]',[17,16,15;16,15,14;17,16,15]','k')
        rectangle('pos',[42 14.5 3 3],'Curvature',[1,1],'linewidth',1)
        rectangle('pos',[10  6.5 3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[1 0 0])
        rectangle('pos',[35  6.5 3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[0 0 1])
        line([43.5,43.5],[17.5,20],'LineWidth',1,'Color',[0 0 0])
        line([11  , 8  ],[ 6.7, 0],'LineWidth',1,'Color',[1 0 0])
        line([35  ,16  ],[ 9  ,20],'LineWidth',1,'Color',[0 0 1])
    end


    function create_lft_block(hObject,eventdata)
        line([ 4 19],[16 16],'LineWidth',2,'Color',[0 0 0]);
        line([28 43],[16 16],'LineWidth',2,'Color',[0 0 0]);
        line([28 36 36 29],[14 14  8  8],'LineWidth',2,'Color',[0 0 1]);
        line([20 12 12 19],[ 8  8 14 14],'LineWidth',2,'Color',[1 0 0]);
        rectangle('pos',[20 12 8 6],'FaceColor',[0.0 0.7 0.3]);
        rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0]);
        text(22.4,15,'$G$','FontSize',14,'Interpreter','latex','Color',[1 1 1]);
        text(22.4, 8,'$Q$','FontSize',14,'Interpreter','latex','Color',[0 0 0]);
        patch([30,28,30],[ 9, 8, 7],'b')
        patch([18,20,18],[15,14,13],'r')
        patch([18,20,18;42,44,42]',[17,16,15;17,16,15]','k')
        rectangle('pos',[38.5 14.5 3 3],'Curvature',[1,1],'linewidth',1)
        rectangle('pos',[10.5  9   3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[1 0 0])
        rectangle('pos',[30.5 12.5 3 3],'Curvature',[1,1],'linewidth',1,'EdgeColor',[0 0 1])
        line([40  ,40],[17.5,20],'LineWidth',1,'Color',[0 0 0])
        line([11.3, 8],[ 9  , 0],'LineWidth',1,'Color',[1 0 0])
        line([32,32,20],[15.3,18,20],'LineWidth',1,'Color',[0 0 1])
    end

    function sim_callback(hObject,eventdata)
        % FIXME
        % Warning for too large quantizer
        odqdata=get(handles.ODQDesign,'UserData');
        ParaP={'a','b','c1','c2'};
        ParaK={'a','b1','b2','c','d1','d2'};
        ParaG={'a','b1','b2','c1','c2','d1','d2'};
        ParaQ={'a','b1','b2','c'};
        switch odqdata.connection
            case 'ff'
                open odqsim_ff.slx;
                for kQ=1:4
                    set_param('odqsim_ff/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kP=1:4
                    set_param('odqsim_fbiq/P (Discrete)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                    set_param('odqsim_fbiq/P (Continuous)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                end
                save_system('odqsim_ff',[pwd '/odqsim_ff'],'BreakAllLinks',true);
            case 'fbiq'
                open odqsim_fbiq.slx;
                for kQ=1:4
                    set_param('odqsim_fbiq/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqsim_fbiq/K (Discrete)',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                    set_param('odqsim_fbiq/K (Continuous)',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                for kP=1:4
                    set_param('odqsim_fbiq/P (Discrete)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                    set_param('odqsim_fbiq/P (Continuous)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                end
                save_system('odqsim_fbiq',[pwd '/odqsim_fbiq'],'BreakAllLinks',true);
            case 'fboq'
                open odqsim_fboq.slx;
                for kQ=1:4
                    set_param('odqsim_fboq/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqsim_fboq/K (Discrete)',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                    set_param('odqsim_fboq/K (Continuous)',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                for kP=1:4
                    set_param('odqsim_fboq/P (Discrete)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                    set_param('odqsim_fboq/P (Continuous)',upper(ParaP{kP}),mat2str(odqdata.P.(ParaP{kP})));
                end
                save_system('odqsim_fboq',[pwd '/odqexp_fboq'],'BreakAllLinks',true);
            case 'lft'
                open odqsim_lft.slx;
                for kQ=1:4
                    set_param('odqsim_lft/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kG=1:7
                    set_param('odqsim_fboq/G (Discrete)',upper(ParaG{kG}),mat2str(odqdata.G.(ParaK{kG})));
                    set_param('odqsim_fboq/G (Continuous)',upper(ParaK{kG}),mat2str(odqdata.G.(ParaK{kG})));
                end
                save_system('odqsim_lft',[pwd '/odqexp_lft'],'BreakAllLinks',true);
        end
    end


    function exp_callback(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        %ParaP={'a','b','c1','c2'};
        ParaK={'a','b1','b2','c','d1','d2'};
        %ParaG={'a','b1','b2','c1','c2','d1','d2'};
        ParaQ={'a','b1','b2','c'};
        if ispc
            xpcexplr
            xpclib
        end
        switch odqdata.connection
            case 'ff'
                open odqexp_ff.mdl;
                for kQ=1:4
                    set_param('odqexp_ff/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                save_system('odqexp_ff',[pwd '/odqexp_ff'],'BreakAllLinks',true);
            case 'fbiq'
                open odqexp_fbiq.mdl;
                for kQ=1:4
                    set_param('odqexp_fbiq/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqexp_fbiq/K',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                save_system('odqexp_fbiq',[pwd '/odqexp_fbiq'],'BreakAllLinks',true);
            case 'fboq'
                open odqexp_fboq.mdl;
                for kQ=1:4
                    set_param('odqexp_fboq/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqexp_fboq/K',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                save_system('odqexp_fboq',[pwd '/odqexp_fboq'],'BreakAllLinks',true);
            case 'lft'
                open odqexp_lft.mdl;
                for kQ=1:4
                    set_param('odqexp_lft/ODQ',upper(ParaQ{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                save_system('odqexp_lft',[pwd '/odqexp_lft'],'BreakAllLinks',true);
        end
    end

end

%#ok<*INUSD>
%#ok<*INUSL>
