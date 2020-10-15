function varargout = odqlab_design(varargin)
% ODQLAB_DESIGN ODQLab Design Window
%       Help message is unavailable yet

DEBUGMODE=0;

%  Initialization tasks
dtsize=get(0,'screensize');
bgcolor=get(0,'defaultUicontrolBackgroundColor');
handles.ODQDesign = figure('Visible','off','Name','Design Window',...
    'MenuBar','none','ToolBar','none','NumberTitle','off',...
    'pos',[dtsize(3)/2-445,dtsize(4)/2-250,800,450],'color',bgcolor,...
    'Resize','off','CloseRequestFcn',@dw_close_fcn);

%%% Defalt Properties %%%
EditDef=struct('Style','Edit','Units','pixels','HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1],'FontName','\default','FontSize',9);
TextDef=struct('Style','text','Units','pixels','HorizontalAlignment','left',...
    'FontName','\default','FontSize',9);
PbtnDef=struct('Style','pushbutton','Units','pixels','FontName','\default','FontSize',9);
RbtnDef=struct('Style','radiobutton','Units','pixels','FontName','\default','FontSize',9);
PanlDef=struct('Units','pixels','FontWeight','bold','FontSize',12,'FontName','\default');
%%%
txtwDef=struct('FontSize',16,'Interpreter','latex','Color',[1 1 1]);
txtkDef=struct('FontSize',16,'Interpreter','latex','Color',[0 0 0]);
linkDef=struct('LineWidth',2,'Color',[0 0 0]);
linrDef=struct('LineWidth',2,'Color',[1 0 0]);
linbDef=struct('LineWidth',2,'Color',[0 0 1]);
set(handles.ODQDesign,'defaultPatchEdgeColor','none')
%%%

uicontrol(handles.ODQDesign,'Style','text','Units','pixels','pos',[330,420,140,30],...
    'str','ODQLab','FontWeight','bold','FontSize',18,'FontName','\default')

handles.SysDef=uibuttongroup('Parent',handles.ODQDesign,'Units','pixels','pos',[10,115,500,310],...
    'Title','System Description','FontWeight','bold','FontSize',12,'FontName','\default',...
    'SelectionChangeFcn',@sys_sel_fcn);
uicontrol(handles.SysDef,RbtnDef,'pos',[35,205,165,25],...
    'str','Feedforward connection','Tag','ff');
uicontrol(handles.SysDef,RbtnDef,'pos',[230,205,260,25],...
    'str','Feedback connection with input quantizer','Tag','fbiq');
uicontrol(handles.SysDef,RbtnDef,'pos',[230,100,260,25],...
    'str','Feedback connection with output quantizer','Tag','fboq');
uicontrol(handles.SysDef,RbtnDef,'pos',[60,100,115,25],...
    'str','LFT connection','Tag','lft');
axes('Parent',handles.SysDef,'Units','pixels','position',[10,195,210,100],...
    'XLim',[4 44],'YLim',[0 20],'Visible','off','CreateFcn',@create_ff_block);
axes('Parent',handles.SysDef,'Units','pixels','position',[240,195,240,100],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off','CreateFcn',@create_fbiq_block);
axes('Parent',handles.SysDef,'Units','pixels','pos',[240,105,240,100],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off','CreateFcn',@create_fboq_block);
axes('Parent',handles.SysDef,'Units','pixels','pos',[10,105,210,100],...
    'XLim',[4 44],'YLim',[0 20],'Visible','off','CreateFcn',@create_lft_block);
odqdata.connection='ff';

handles.SysTab=uitable(handles.SysDef,'Units','pixels','pos',[30,5,260,90],...
    'ColumnName',{'Dimention','Inputs','Outputs'},'RowName',{'P','K','G'},...
    'Enable','inactive');
uicontrol(handles.SysDef,PbtnDef,'str','Set P','pos',[330,60,80,20],'Callback',@set_sys_callback)
uicontrol(handles.SysDef,PbtnDef,'str','Set K','pos',[330,35,80,20],'Callback',@set_sys_callback)
uicontrol(handles.SysDef,PbtnDef,'str','Set G','pos',[330,10,80,20],'Callback',@set_sys_callback)


handles.QSpec=uipanel(handles.ODQDesign,PanlDef,'pos',[520,215,270 210],...
    'Title','Quantizer Specification');
uicontrol(handles.QSpec,TextDef,'pos',[10,165,120,20],'str','Quantization interval');
uicontrol(handles.QSpec,TextDef,'pos',[10,115,120,20],'str','Evaluation period');
uicontrol(handles.QSpec,TextDef,'pos',[10, 65,120,20],'str','Quantizer gain');
uicontrol(handles.QSpec,TextDef,'pos',[20, 45, 50,20],'str','u -> v');
uicontrol(handles.QSpec,TextDef,'pos',[20, 20, 50,20],'str','w -> v');
handles.d=uicontrol(handles.QSpec,EditDef,'pos',[80,145, 50,20],'str','1');
handles.T=uicontrol(handles.QSpec,EditDef,'pos',[80, 95, 50,20],'str','Inf');
handles.gamma_uv=uicontrol(handles.QSpec,EditDef,'pos',[80, 45, 50,20],'str','Inf');
handles.gamma_wv=uicontrol(handles.QSpec,EditDef,'pos',[80, 20, 50,20],'str','Inf');

handles.LPsol=uibuttongroup('Parent',handles.QSpec,'Units','pixels',...
    'pos',[150,40,100,145],'Title','LP solver','FontSize',9,'FontName','\default',...
    'SelectionChangeFcn',@lp_sel_fcn);
uicontrol(handles.LPsol,RbtnDef,'pos',[10 105 80 20],'str','linprog');
uicontrol(handles.LPsol,RbtnDef,'pos',[10  80 80 20],'str','CPLEX');
uicontrol(handles.LPsol,RbtnDef,'pos',[10  55 80 20],'str','SDPT3');
uicontrol(handles.LPsol,RbtnDef,'pos',[10  30 80 20],'str','SeDuMi');
uicontrol(handles.LPsol,RbtnDef,'pos',[10   5 80 20],'str','SDPA','Visible','off');
odqdata.solver='linprog';

uicontrol(handles.QSpec,PbtnDef,'str','Design','pos',[170,10,80,25],...
    'Callback',@design_callback)

handles.QRed=uipanel(handles.ODQDesign,PanlDef,'pos',[520,115,270 90],...
    'Title','Quantizer Reduction');
uicontrol(handles.QRed,TextDef,'pos',[10,40,120,20],...
    'str','Quantizer dimension')
handles.dim=uicontrol(handles.QRed,EditDef,'pos',[80,20,50,20]);
uicontrol(handles.QRed,PbtnDef,'str','Reduce','pos',[170,10,80,25],...
    'Callback',@reduce_callback)

uicontrol(handles.ODQDesign,'Style','text','Units','pixels','pos',[30,90,100,20],...
    'str','Message','FontWeight','bold','FontSize',12,'FontName','\default',...
    'HorizontalAlignment','left')
handles.hint=uicontrol(handles.ODQDesign,EditDef,'pos',[30,10,730,80],...
    'max',5,'min',1,'Enable','inactive');

varargout{1}=handles.ODQDesign;
set(handles.ODQDesign,'Visible','on','UserData',odqdata);

    function dw_close_fcn(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        if isfield(odqdata,'flg')
            if isfield(odqdata.flg,'vw_open')
                if odqdata.flg.vw_open
                    delete(handles.ODQVerify)
                end
            end
        end
        delete(hObject)
    end

    function sys_sel_fcn(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        odqdata.connection=get(eventdata.NewValue,'Tag');
        set(handles.ODQDesign,'UserData',odqdata)
    end

    function set_sys_callback(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        MonoFont=get(0,'FixedWidthFontName');
        ParentPos=get(handles.ODQDesign,'pos');
        callSys=get(hObject,'str');
        EqDef=struct('Style','text','Units','pixels','FontSize',9,'FontName',MonoFont,...
            'HorizontalAlignment','left');
        switch callSys
            case 'Set P'
                Para={'a','b','c1','c2'};
                steq={'x[k+1] =  A*x[k] + B*v[k]',...
                    ' z[k]  = C1*x[k]',...
                    ' u[k]  = C2*x[k]'};
            case 'Set K'
                Para={'a','b1','b2','c','d1','d2'};
                steq={'x[k+1] = A*x[k] + B1*r[k] + B2*y[k]',...
                    ' u[k]  = C*x[k] + D1*r[k] + D2*y[k]'};
            case 'Set G'
                Para={'a','b1','b2','c1','c2','d1','d2'};
                steq={'x[k+1] =  A*x[k] + B1*r[k] + B2*v[k]',...
                    ' z[k]  = C1*x[k] + D1*r[k]',...
                    ' u[k]  = C2*x[k] + D2*r[k]'};
        end
        handles.SetSys = figure('Visible','off','MenuBar','none','ToolBar','none',...
            'NumberTitle','off','color',bgcolor,'Name',callSys,...
            'pos',[ParentPos(1)+450,ParentPos(2),270,length(Para)*45+160]);
        handles.SysEQ=uipanel(handles.SetSys,'Units','pixels',...
            'pos',[10,length(Para)*45+75,250,75],...
            'FontSize',10,'FontName','\default','Title',['System ' callSys(5)]);
        uicontrol(handles.SysEQ,EqDef,'pos',[10,10,230,40],'str',steq);
        handles.SysPara=uipanel(handles.SetSys,'Units','pixels',...
            'pos',[10,40,250,length(Para)*45+25],...
            'FontSize',10,'FontName','\default','Title','Parameters');
        for k=1:length(Para)
            uicontrol(handles.SysPara,TextDef,'str',[upper(Para{k}) ':'],...
                'pos',[10,30+(length(Para)-k)*45,230,20])
            handles.ParaIn(k)=uicontrol(handles.SysPara,EditDef,...
                'pos',[10,10+(length(Para)-k)*45,230,20]);
        end
        uicontrol(handles.SetSys,PbtnDef,'pos',[ 90 5 80 20],'str','OK','Callback',@sys_ok)
        uicontrol(handles.SetSys,PbtnDef,'pos',[180 5 80 20],'str','Cancel','Callback',@sys_cancel)
        
        if isfield(odqdata,callSys(5))
            for k=1:length(Para)
                set(handles.ParaIn(k),'str',odqdata.(['St',callSys(5)]).(Para{k}));
            end
        end
        
        set(handles.SetSys,'Visible','on')
        
        function sys_ok(hObject,eventdata)
            for k1=1:length(Para)
                if strcmp(strtrim(get(handles.ParaIn(k1),'str')),'')
                    errordlg('Please fill the all fields!','ODQ error')
                    return
                end
            end
            for k1=1:length(Para)
                odqdata.(['St',callSys(5)]).(Para{k1})=get(handles.ParaIn(k1),'str');
                odqdata.(callSys(5)).(Para{k1})=evalin('base',odqdata.(['St',callSys(5)]).(Para{k1}));
            end
            plantdata=get(handles.SysTab,'Data');
            switch callSys
                case 'Set P'
                    plantdata(1,1)=size(odqdata.P.a,1);
                    plantdata(1,2)=size(odqdata.P.b,2);
                    plantdata(1,3)=size(odqdata.P.c1,1);
                case 'Set K'
                    plantdata(2,1)=size(odqdata.K.a,1);
                    plantdata(2,2)=size(odqdata.K.b1,2);
                    plantdata(2,3)=size(odqdata.K.c,1);
                case 'Set G'
                    plantdata(3,1)=size(odqdata.G.a,1);
                    plantdata(3,2)=size(odqdata.G.b1,2);
                    plantdata(3,3)=size(odqdata.G.c1,1);
            end
            set(handles.SysTab,'Data',plantdata)
            set(handles.ODQDesign,'UserData',odqdata)
            close(handles.SetSys)
        end
        
        function sys_cancel(hObject,eventdata)
            close(handles.SetSys)
        end
        
    end

    function lp_sel_fcn(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        odqdata.solver=get(eventdata.NewValue,'str');
        set(handles.ODQDesign,'UserData',odqdata);
    end

    function design_callback(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        if isfield(odqdata,'flg')
            if isfield(odqdata.flg,'vw_open')
                if odqdata.flg.vw_open
                    delete(handles.ODQVerify)
                    odqdata.flg.vw_open=0;
                end
            end
        end
        odqdata.d=evalin('base',get(handles.d,'str'));
        odqdata.T=evalin('base',get(handles.T,'str'));
        odqdata.gamma.uv=evalin('base',get(handles.gamma_uv,'str'));
        odqdata.gamma.wv=evalin('base',get(handles.gamma_wv,'str'));
        dim=strtrim(get(handles.dim,'str'));
        if ~strcmp(odqdata.connection,'lft')
            if strcmp(odqdata.connection,'ff')
                odqdata.K=[];
            end
            odqdata.G=compg(odqdata.P,odqdata.K,odqdata.connection);
        end
        if size(odqdata.G.c1*odqdata.G.b2,2)<size(odqdata.G.c1*odqdata.G.b2,1) && T==inf
            hint=textwrap(handles.hint,{'Could not derive analytic solution.',...
                'Please set Evaluation time for numerical optimization'});
            set(handles.hint,'str',hint);
        else
            if isempty(dim)
                [odqdata.Q,odqdata.E,odqdata.Hk,odqdata.gain]=...
                    odq(odqdata.G,odqdata.T,odqdata.d,odqdata.gamma,[],odqdata.solver);
            else
                odqdata.dim=evalin('base',dim);
                [odqdata.Q,odqdata.E,odqdata.Hk,odqdata.gain]=...
                    odq(odqdata.G,odqdata.T,odqdata.d,odqdata.gamma,odqdata.dim,odqdata.solver);
            end
            odqdata.stb=odqstb(odqdata.Q);
            if ~odqdata.stb
                hint=textwrap(handles.hint,{'Optimal quantizer is NOT stable.',...
                    'Please set Evaluation time for numerical optimization'});
                set(handles.hint,'str',hint)
            elseif size(odqdata.Q.a,1)>size(odqdata.G.a,1)
                hint=textwrap(handles.hint,...
                    {'The Dimension of the quantizer is maybe too large.',...
                    'The following two approaches are usefull to reduce dimension:',...
                    '1. Set small evaluation time  OR',...
                    '2. Truncate small singular values.'});
                set(handles.hint,'str',hint)
            end
            odqdata.flg.vw_open=1;
            set(handles.ODQDesign,'UserData',odqdata);
            handles.ODQVerify=odqlab_verify('ODQ_Designer',handles.ODQDesign);
        end
    end

    function reduce_callback(hObject,eventdata)
        odqdata=get(handles.ODQDesign,'UserData');
        if isfield(odqdata,'flg')
            if isfield(odqdata.flg,'vw_open')
                if odqdata.flg.vw_open
                    delete(handles.ODQVerify)
                    odqdata.flg.vw_open=0;
                end
            end
        end
        odqdata.d=evalin('base',get(handles.d,'str'));
        odqdata.T=evalin('base',get(handles.T,'str'));
        odqdata.gamma.uv=evalin('base',get(handles.gamma_uv,'str'));
        odqdata.gamma.wv=evalin('base',get(handles.gamma_wv,'str'));
        dim=strtrim(get(handles.dim,'str'));
        if ~strcmp(odqdata.connection,'lft')
            if strcmp(odqdata.connection,'ff')
                odqdata.K=[];
            end
            odqdata.G=compg(odqdata.P,odqdata.K,odqdata.connection);
        end
        if isempty(dim)
            hint=textwrap(handles.hint,{'Please set the quantizer dimension'});
            set(handles.hint,'str',hint)
        else
            odqdata.dim=evalin('base',dim);
            [odqdata.Q,odqdata.Hk]=odqreal(odqdata.G,odqdata.Hk,odqdata.dim);
        end
        odqdata.stb=odqstb(odqdata.Q);
        if ~odqdata.stb
            hint=textwrap(handles.hint,{'Please set T and gamma',...
                'numerical optimization'});
            set(handles.hint,'str',hint)
        end
        odqdata.E=odqcost(odqdata.G,odqdata.Q,odqdata.d,odqdata.T);
        odqdata.gain=odqgain(odqdata.Q,odqdata.T);
        odqdata.flg.vw_open=1;
        set(handles.ODQDesign,'UserData',odqdata);
        handles.ODQVerify=odqlab_verify('ODQ_Designer',handles.ODQDesign);
    end

    function create_ff_block(hObject,eventdata)
        line([ 4 11],[11 11],linbDef,'Parent',hObject);
        line([20 27],[11 11],linrDef,'Parent',hObject);
        line([36 43],[11 11],linkDef,'Parent',hObject);
        rectangle('pos',[28 8 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',hObject);
        rectangle('pos',[12 8 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(30.4,11,'$P$',txtwDef,'Parent',hObject);
        text(14.4,11,'$Q$',txtkDef,'Parent',hObject);
        patch([10,12,10],[12,11,10],'b','Parent',hObject)
        patch([26,28,26],[12,11,10],'r','Parent',hObject)
        patch([42,44,42],[12,11,10],'k','Parent',hObject)
    end

    function create_fbiq_block(hObject,eventdata)
        line([ 0  7],[16 16],linkDef,'Parent',hObject);
        line([16 19],[15 15],linbDef,'Parent',hObject);
        line([28 31],[15 15],linrDef,'Parent',hObject);
        line([40 47],[16 16],linkDef,'Parent',hObject);
        line([40 42 42 5 5 7],[14 14 8 8 14 14],linkDef,'Parent',hObject);
        rectangle('pos',[32 12 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',hObject);
        rectangle('pos',[ 8 12 8 6],'FaceColor',[1.0 0.7 0.0],'Parent',hObject);
        rectangle('pos',[20 12 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(34.4,15,'$P$',txtwDef,'Parent',hObject);
        text(10.4,15,'$K$',txtwDef,'Parent',hObject);
        text(22.4,15,'$Q$',txtkDef,'Parent',hObject);
        patch([18,20,18],[16,15,14],'b','Parent',hObject)
        patch([30,32,30],[16,15,14],'r','Parent',hObject)
        patch([6,8,6;6,8,6;46,48,46]',[17,16,15;15,14,13;17,16,15]','k','Parent',hObject)
    end

    function create_fboq_block(hObject,eventdata)
        line([ 0  7],[16 16],linkDef,'Parent',hObject);
        line([16 31],[15 15],linkDef,'Parent',hObject);
        line([40 47],[16 16],linkDef,'Parent',hObject);
        line([40 42 42 29],[14 14  8  8],linbDef,'Parent',hObject);
        line([20  5  5  7],[ 8  8 14 14],linrDef,'Parent',hObject);
        rectangle('pos',[32 12 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',hObject);
        rectangle('pos',[ 8 12 8 6],'FaceColor',[1.0 0.7 0.0],'Parent',hObject);
        rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(34.4,15,'$P$',txtwDef,'Parent',hObject);
        text(10.4,15,'$K$',txtwDef,'Parent',hObject);
        text(22.4, 8,'$Q$',txtkDef,'Parent',hObject);
        patch([30,28,30],[ 9, 8, 7],'b','Parent',hObject)
        patch([ 6, 8, 6],[15,14,13],'r','Parent',hObject)
        patch([6,8,6;30,32,30;46,48,46]',[17,16,15;16,15,14;17,16,15]','k','Parent',hObject)
    end

    function create_lft_block(hObject,eventdata)
        line([ 4 19],[16 16],linkDef,'Parent',hObject);
        line([28 43],[16 16],linkDef,'Parent',hObject);
        line([28 36 36 29],[14 14  8  8],linbDef,'Parent',hObject);
        line([20 12 12 19],[ 8  8 14 14],linrDef,'Parent',hObject);
        rectangle('pos',[20 12 8 6],'FaceColor',[0.0 0.7 0.3],'Parent',hObject);
        rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(22.4,15,'$G$',txtwDef,'Parent',hObject);
        text(22.4, 8,'$Q$',txtkDef,'Parent',hObject);
        patch([30,28,30],[ 9, 8, 7],'b','Parent',hObject)
        patch([18,20,18],[15,14,13],'r','Parent',hObject)
        patch([18,20,18;42,44,42]',[17,16,15;17,16,15]','k','Parent',hObject)
    end

end


%#ok<*INUSD>
%#ok<*INUSL>