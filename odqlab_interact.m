function odqlab_interact(varargin)
% ODQLAB_INTERACT ODQLab with interaction mode
%       Help message is unavailable yet


%  Initialization tasks
dtsize=get(0,'screensize');
odqnavi_window = figure('Visible','off','Name','ODQLab','MenuBar','none',...
    'NumberTitle','off','pos',[dtsize(3)/2-400,dtsize(4)/2-225,800,450]);

debugmode=0;

%%%%% Defalt Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EditDef=struct('Style','edit','Units','pixels','HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);
PbtnDef=struct('Style','pushbutton','Units','pixels');
HeadDef=struct('Style','text','Units','pixels');
TextDef=struct('Style','text','Units','pixels','HorizontalAlignment','left');
DataDef=struct('Style','text','Units','pixels','FontName','monospased');
RbtnDef=struct('Style','radiobutton','Units','pixels');
ParaP={'a','b','c1','c2'};
ParaK={'a','b1','b2','c','d1','d2'};
ParaG={'a','b1','b2','c1','c2','d1','d2'};
ParaQ={'a','b1','b2','c'};

txtwDef=struct('FontSize',16,'Interpreter','latex','Color',[1 1 1]);
txtkDef=struct('FontSize',16,'Interpreter','latex','Color',[0 0 0]);
linkDef=struct('LineWidth',2,'Color',[0 0 0]);
linrDef=struct('LineWidth',2,'Color',[1 0 0]);
linbDef=struct('LineWidth',2,'Color',[0 0 1]);
set(odqnavi_window,'defaultPatchEdgeColor','none')

%%%%% Construct the components %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
workflow=uipanel(odqnavi_window,'Units','pixels','pos',[10 40 100 400],...
    'BorderType','etchedin','UserData',0);
stintro=uicontrol(workflow,HeadDef,'str','Introduction',...
    'pos',[10 370 80 20],'FontWeight','bold');
stsystm=uicontrol(workflow,HeadDef,'str','System type',...
    'pos',[10 340 80 20],'FontWeight','normal');
stplant=uicontrol(workflow,HeadDef,'str','Plant',...
    'pos',[10 310 80 20],'FontWeight','normal');
stcntrl=uicontrol(workflow,HeadDef,'str','Controller',...
    'pos',[10 280 80 20],'FontWeight','normal');
stqntzr=uicontrol(workflow,HeadDef,'str',{'Quantizer','specification'},...
    'pos',[10 245 80 30],'FontWeight','normal');
stsmmry=uicontrol(workflow,HeadDef,'str','Design',...
    'pos',[10 210 80 20],'FontWeight','normal');


buttonback=uicontrol(odqnavi_window,PbtnDef,'str','Back',...
    'pos',[630 10 70 21],'Enable','off','Callback',@buttonback_callback);
buttonnext=uicontrol(odqnavi_window,PbtnDef,'str','Next',...
    'pos',[710 10 70 21],'Enable','on','Callback',@buttonnext_callback);


intropanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','on');
uicontrol(intropanel,HeadDef,'str','ODQLab',...
    'pos',[250 350 180 40],'FontWeight','bold','FontSize',18);
uicontrol(intropanel,TextDef,'str',...
    {'This Program guides to design','a dynamic quantizer for control.',...
    'It is not need advansed knowledge','for the quantized control.'},...
    'pos',[10 220 250 80],'FontSize',12);
uicontrol(intropanel,TextDef,'str',...
    {'(C) 2011 Mechanical system control Lab,','Kyoto University',...
    'Gokasho, Uji, Kyoto 611-0011, Japan',...
    'http://www.robot.kuass.kyoto-u.ac.jp/'},...
    'pos',[340 10 330 80]);


systempanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of SystemPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(systempanel,TextDef,'str',...
    'Select the type of the quantized system to be considered:',...
    'pos',[10 330 500 30],'FontSize',12);
connection=uibuttongroup('Parent',systempanel,'Units','pixels','pos',[70 40 565 260],...
    'BorderType','none','SelectionChangeFcn',@connenction_selectionchangefcn);
uicontrol(connection,RbtnDef,'pos',[30 140 190 30],...
    'str','Feedforward connection','Tag','ff');
uicontrol(connection,RbtnDef,'pos',[290 140 280 30],...
    'str','Feedback connection with input quantizer','Tag','fbiq');
uicontrol(connection,RbtnDef,'pos',[290 0 280 30],...
    'str','Feedback connection with output quantizer','Tag','fboq');
uicontrol(connection,RbtnDef,'pos',[30 0 190 30],...
    'str','LFT connection','Tag','lft');
axes('Parent',connection,'Units','pixels','pos',[0 145 245 120],...
    'XLim',[4 44],'YLim',[0 20],'Visible','off','CreateFcn',@axesff_createfcn);
axes('Parent',connection,'Units','pixels','pos',[285 145 280 120],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off','CreateFcn',@axesfbiq_createfcn);
axes('Parent',connection,'Units','pixels','pos',[285 5 280 120],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off','CreateFcn',@axesfboq_createfcn);
axes('Parent',connection,'Units','pixels','pos',[0 5 245 120],...
    'XLim',[4 44],'YLim',[0 20],'Visible','off','CreateFcn',@axeslft_createfcn);
odqdata.connection='ff';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


plantpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of PlantPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(plantpanel,TextDef,'str',...
    'Set the plant:',...
    'pos',[10 330 500 30],'FontSize',12);
plantset=uibuttongroup('Parent',plantpanel,'Units','pixels','pos',[10 250 200 100],...
    'BorderType','none','SelectionChangeFcn',@plant_selectionchangefcn);
uicontrol(plantset,RbtnDef,'pos',[0 50 180 30],'str','Transfer function','Tag','tf');
uicontrol(plantset,RbtnDef,'pos',[0 20 180 30],'str','State space','Tag','ss');
%%%%% Transfer Function %%%%%
planttf=uipanel(plantpanel,'Units','pixels','pos',[340 10 330 380],...
    'BorderType','none','Visible','on');
uicontrol(planttf,TextDef,'pos',[0 275 100 20],'str','Numerator');
uicontrol(planttf,TextDef,'pos',[0 225 100 20],'str','Denominator');
editnumP=uicontrol(planttf,EditDef,'pos',[0 250 300 30]);
editdenP=uicontrol(planttf,EditDef,'pos',[0 200 300 30]);
%%%%% State Space %%%%%
plantss=uipanel(plantpanel,'Units','pixels','pos',[340 10 330 380],...
    'BorderType','none','Visible','off');
uicontrol(plantss,TextDef,'pos',[10 300 150 60],'str',...
    {'x[k+1] = A*x[k] + B*v[k]',' z[k] = C1*x[k]',' y[k] = C2*x[k]'});
editP=zeros(1,4);
for kp=1:4
    uicontrol(plantss,TextDef,'pos',[0 325-50*kp 30 20],'str',upper(ParaP{kp}));
    editP(kp)=uicontrol(plantss,EditDef,'pos',[0 300-50*kp 300 30]);
end
odqdata.Ptype='tf';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ctrlpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of ControllerPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(ctrlpanel,TextDef,'str',...
    'Set the controller:',...
    'Units','pixels','pos',[10 330 500 30],'FontSize',12);
controlset=uibuttongroup('Parent',ctrlpanel,'Units','pixels','pos',[10 250 200 100],...
    'BorderType','none','SelectionChangeFcn',@controller_selectionchangefcn);
uicontrol(controlset,RbtnDef,'pos',[0 50 180 30],'str','Transfer function','Tag','tf');
uicontrol(controlset,RbtnDef,'pos',[0 20 180 30],'str','State space','Tag','ss');
%%%%% Transfer Function %%%%%
ctrltf=uipanel(ctrlpanel,'Units','pixels','pos',[340 10 330 380],...
    'BorderType','none','Visible','on');
uicontrol(ctrltf,TextDef,'pos',[0 275 100 20],'str','Numerator');
uicontrol(ctrltf,TextDef,'pos',[0 225 100 20],'str','Denominator');
editnumK=uicontrol(ctrltf,EditDef,'pos',[0 250 300 30]);
editdenK=uicontrol(ctrltf,EditDef,'pos',[0 200 300 30]);
%%%%% State Space %%%%%
ctrlss=uipanel(ctrlpanel,'Units','pixels','pos',[340 10 330 380],...
    'BorderType','none','Visible','off');
uicontrol(ctrlss,TextDef,'pos',[10 310 300 50],'str',...
    {'x[k+1] = A*x[k] + B1*r[k] + B2*y[k]',' u[k] = C*x[k] + D1*r[k] + D2*y[k]'});
editK=zeros(1,6);
for kp=1:6
    uicontrol(ctrlss,TextDef,'pos',[0 335-50*kp 30 20],'str',upper(ParaK{kp}));
    editK(kp)=uicontrol(ctrlss,EditDef,'pos',[0 310-50*kp 300 30]);
end
odqdata.Ktype='tf';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lftpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of lftPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(lftpanel,TextDef,'str',...
    'Set the LFT system:',...
    'pos',[10 330 500 30],'FontSize',12);
lftset=uibuttongroup('Parent',lftpanel,'Units','pixels','pos',[10 250 200 100],...
    'BorderType','none','SelectionChangeFcn',@lft_selectionchangefcn);
uicontrol(lftset,RbtnDef,'pos',[0 50 180 30],...
    'str','Transfer function','Tag','tf','Enable','off','Value',0);
uicontrol(lftset,RbtnDef,'pos',[0 20 180 30],...
    'str','State space','Tag','ss','Value',1);
%%%%% Transfer Function %%%%%
% lfttf=uipanel(lftpanel,'Units','pixels','pos',[340 10 330 380],...
%     'BorderType','none','Visible','on');
% uicontrol(planttf,TextDef,'pos',[0 275 100 20],'str','Numerator');
% uicontrol(planttf,TextDef,'pos',[0 225 100 20],'str','Denominator');
% editnumG=uicontrol(lfttf,EditDef,'pos',[0 250 300 30]);
% editdenG=uicontrol(lfttf,EditDef,'pos',[0 200 300 30]);
%%%%% State Space %%%%%
lftss=uipanel(lftpanel,'Units','pixels','pos',[340 10 330 380],...
    'BorderType','none','Visible','on');
uicontrol(lftss,TextDef,'pos',[10 300 200 60],'str',...
    {'x[k+1] = A*x[k] + B1*r[k] + B2*u[k]',...
    ' z[k] = C1*x[k] +D1*r[k]',...
    ' v[k] = C2*x[k] +D2*r[k]'});
editG=zeros(1,6);
for kp=1:7
    uicontrol(lftss,TextDef,'pos',[0 290-40*kp 30 20],'str',upper(ParaG{kp}));
    editG(kp)=uicontrol(lftss,EditDef,'pos',[30 290-40*kp 270 30]);
end
odqdata.Gtype='ss';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Qpanel1=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of QuantizerPanel 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(Qpanel1,TextDef,'str',...
    {'Set the quantization interval:'},...
    'pos',[10 310 500 50],'FontSize',12);
axes('Parent',Qpanel1,'Units','pixels','pos',[50 50 240 240],...
    'Visible','on','Box','on','XLim',[0 8],'YLim',[0 8],'XTick',0:1:8,'YTick',0:1:8,...
    'XTickLabel',[],'YTickLabel',[],'XGrid','on','YGrid','on',...
    'CreateFcn',@axesinterval_createfcn);
uicontrol(Qpanel1,TextDef,'str','Quantization interval',...
    'pos',[300 200 120 20]);
editd=uicontrol(Qpanel1,EditDef,'pos',[300 175 50 30],'str','1');

Qpanel2=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of QuantizerPanel 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(Qpanel2,TextDef,'pos',[10 330 500 30],'FontSize',12,'str',...
    'Set the Evaluation time:');
axes('Parent',Qpanel2,'Units','pixels','pos',[50 100 580 200],...
    'Visible','on','Box','on','CreateFcn',@axesE_createfcn);
uicontrol(Qpanel2,TextDef,'pos',[240 60 100 25],'str',...
    'Evaluation time');
editT=uicontrol(Qpanel2,EditDef,'pos',[340 60 50 30],'str','Inf');

Qpanel3=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of QuantizerPanel 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(Qpanel3,TextDef,'pos',[10 330 500 30],'FontSize',12,'str',...
    'Set the upper bounds of quantizer gains:');
uicontrol(Qpanel3,TextDef,'pos',[380 265 150 20],'str',...
    'Quantizer gain (u -> v)');
uicontrol(Qpanel3,TextDef,'pos',[380 105 150 20],'str',...
    'Quantizer gain (w -> v)');
edituv=uicontrol(Qpanel3,EditDef,'pos',[380 230 50 30],'str','Inf');
editwv=uicontrol(Qpanel3,EditDef,'pos',[380  70 50 30],'str','Inf');
axes('Parent',Qpanel3,'Units','pixels','pos',[50 170 300 150],...
    'Visible','off','CreateFcn',@axesuv_createfcn);
axes('Parent',Qpanel3,'Units','pixels','pos',[50 10 300 150],...
    'Visible','off','CreateFcn',@axeswv_createfcn);

Qpanel4=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of QuantizerPanel 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(Qpanel4,TextDef,'str',...
    'Select a linear programing solver:',...
    'pos',[10 330 500 30],'FontSize',12);
lpsolver=uibuttongroup('Parent',Qpanel4,'Units','pixels','pos',[100 150 200 170],...
    'BorderType','none','SelectionChangeFcn',@lpsolver_selectionchangefcn);
uicontrol(lpsolver,RbtnDef,'pos',[10 120 180 30],'str','linprog');
uicontrol(lpsolver,RbtnDef,'pos',[10  90 180 30],'str','CPLEX');
uicontrol(lpsolver,RbtnDef,'pos',[10  60 180 30],'str','SDPT3');
uicontrol(lpsolver,RbtnDef,'pos',[10  30 180 30],'str','SeDuMi');
uicontrol(lpsolver,RbtnDef,'pos',[10   0 180 30],'str','SDPA','Visible','off');
odqdata.solver='linprog';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sumpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of SummaryPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
summaryPtype=uicontrol(sumpanel,TextDef,'pos',[10 350 290 30],'str','P:');
summaryKtype=uicontrol(sumpanel,TextDef,'pos',[10 170 290 30],'str','K:');
uicontrol(sumpanel,TextDef,'pos',[300 350 250 30],'str','Quantization inteval');
uicontrol(sumpanel,TextDef,'pos',[300 280 250 30],'str','Evaluation period');
uicontrol(sumpanel,TextDef,'pos',[300 210 250 30],'str','Quantizer gain');
uicontrol(sumpanel,TextDef,'pos',[300 140 250 30],'str','LP solver');
summaryPdata =uicontrol(sumpanel,DataDef,'pos',[ 10 200 290 150],'str','Undefined');
summaryKdata =uicontrol(sumpanel,DataDef,'pos',[ 10  70 290 100],'str','Undefined');
summaryddata =uicontrol(sumpanel,DataDef,'pos',[300 320 250  30],'str','Undefined');
summaryTdata =uicontrol(sumpanel,DataDef,'pos',[300 250 250  30],'str','Undefined');
summaryuvdata=uicontrol(sumpanel,DataDef,'pos',[300 180 100  30],'str','Undefined');
summarywvdata=uicontrol(sumpanel,DataDef,'pos',[400 180 100  30],'str','Undefined');
summarylpdata=uicontrol(sumpanel,HeadDef,'pos',[300 110 250  30],'str','Undefined');


respanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of ResultPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(respanel,TextDef,'pos',[10 300 100 30],'str','Quantizer gain (u->v)');
uicontrol(respanel,TextDef,'pos',[10 270 100 30],'str','Quantizer gain (u->w)');
uicontrol(respanel,TextDef,'pos',[10 240 100 30],'str','Dimension');
uicontrol(respanel,TextDef,'pos',[10 210 100 30],'str','E(T,Q)');
uicontrol(respanel,TextDef,'pos',[10 180 100 30],'str','E(Inf,Q)');
uicontrol(respanel,TextDef,'pos',[10 150 100 30],'str',{'Lower bound','of E(Inf,Q)'}');
uicontrol(respanel,TextDef,'pos',[10 120 100 30],'str',{'Upper bound','of E(Inf,Q)'}');
resultuv    =uicontrol(respanel,HeadDef,'pos',[120 300 150 30],'str','Undefined');
resultwv    =uicontrol(respanel,HeadDef,'pos',[120 270 150 30],'str','Undefined');
resultdim   =uicontrol(respanel,HeadDef,'pos',[120 240 150 30],'str','Undefined');
resultET    =uicontrol(respanel,HeadDef,'pos',[120 210 150 30],'str','Undefined');
resultEinf  =uicontrol(respanel,HeadDef,'pos',[120 180 150 30],'str','Undefined');
resultLEinf =uicontrol(respanel,HeadDef,'pos',[120 150 150 30],'str','Undefined');
resultUEinf =uicontrol(respanel,HeadDef,'pos',[120 120 150 30],'str','Undefined');
uicontrol(respanel,HeadDef,'pos',[350 300 250 30],'str',...
    'Singular value distribution');
axeshnkl=axes('Parent',respanel,'Units','pixels','pos',[350 100 250 200],...
    'Visible','on','Box','on');
uicontrol(respanel,TextDef,'pos',[350 50 250 20],'str',...
    'Quantizer reduction');
setdim=uicontrol(respanel,'Style','popupmenu','str','none','Value',1,...
    'Units','pixels','pos',[400 20 100 30],'Callback',@setdim_callback,'BackgroundColor',[1 1 1]);
setdimcustom=uicontrol(respanel,EditDef,'Visible','off',...
    'pos',[500 20 60 30],'BackgroundColor',[1 1 1]);


savepanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of SavelPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(savepanel,TextDef,'pos',[10 330 500 30],'FontSize',12,'str',...
    'What will you do next?');
uicontrol(savepanel,PbtnDef,'str','Save to Workspace',...
    'pos',[100 250 140 21],'Callback',@save_q_callback);
uicontrol(savepanel,PbtnDef,'str','Save to MAT-file',...
    'pos',[250 250 140 21],'Callback',@save_q_callback);
uicontrol(savepanel,PbtnDef,'str','Numerical simuration',...
    'pos',[150 200 140 21],'Callback',@numsim_callback);
uicontrol(savepanel,PbtnDef,'str','Experiment',...
    'pos',[150 150 140 21],'Callback',@exp_callback);


setsimpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of SetsimPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uicontrol(setsimpanel,TextDef,'str',...
    'Set the simulation conditions:',...
    'pos',[10 330 500 30],'FontSize',12);
simblock=axes('parent',setsimpanel,'units','pixels','pos',[200 150 280 120],...
    'XLim',[0 48],'YLim',[0 20],'Visible','off');
steditR  =uicontrol(setsimpanel,HeadDef,'pos',[ 80 260 100 20],'str','Reference input');
steditxP0=uicontrol(setsimpanel,HeadDef,'pos',[360 290 100 20],'str','Initial value (P)');
steditxK0=uicontrol(setsimpanel,HeadDef,'pos',[210 290 100 20],'str','Initial value (K)');
uicontrol(setsimpanel,HeadDef,'pos',[280 150 100 20],'str','Simulation time');
editR  =uicontrol(setsimpanel,EditDef,'pos',[130 240 50 20],'str','0');
editxP0=uicontrol(setsimpanel,EditDef,'pos',[385 270 50 20],'str','[0;0;0;0]');
editxK0=uicontrol(setsimpanel,EditDef,'pos',[245 270 50 20],'str','0');
editfinaltime=uicontrol(setsimpanel,EditDef,'pos',[300 130 50 20],'str','100');

simpanel=uipanel(odqnavi_window,'Units','pixels','pos',[110 40 680 400],...
    'BorderType','etchedin','Visible','off');
%%%%% Components of SimulationPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axesu   =axes('Parent',simpanel,'Units','pixels','pos',[ 50 260 250 130],...
    'Box','on','XGrid','on','Ygrid','on');
axesv   =axes('Parent',simpanel,'Units','pixels','pos',[ 50  50 250 130],...
    'Box','on','XGrid','on','Ygrid','on');
axesz   =axes('Parent',simpanel,'Units','pixels','pos',[420 260 250 130],...
    'Box','on','XGrid','on','Ygrid','on');
axesdiff=axes('Parent',simpanel,'Units','pixels','pos',[420  50 250 130],...
    'Box','on','XGrid','on','Ygrid','on');
ylabel(axesu   ,'Quantizer input'  )
ylabel(axesv   ,'Quantizer output' )
ylabel(axesz   ,'Output')
ylabel(axesdiff,'Output difference')


set(odqnavi_window,'UserData',odqdata);
set(odqnavi_window,'Visible','on');


%%%%% Callbacks for Panel Change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function buttonnext_callback(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'UserData');
        process=get(workflow,'UserData');
        switch process
            case 0
                set(intropanel ,'Visible','off');
                set(systempanel,'Visible','on');
                set(buttonback,'Enable','on');
                set(stintro,'FontWeight','normal')
                set(stsystm,'FontWeight','bold')
                process=1;
                
            case 1
                set(stsystm,'FontWeight','normal')
                set(stplant,'FontWeight','bold')
                set(systempanel,'Visible','off');
                if strcmp(odqdata.connection,'lft')
                    set(lftpanel,'Visible','on');
                    set(stcntrl,'FontWeight','bold')
                    process=2.5;
                else
                    set(plantpanel ,'Visible','on');
                    process=2;
                end
            case 2
                switch odqdata.Ptype
                    case 'tf'
                        tmp_P.num=get(editnumP,'str');
                        tmp_P.den=get(editdenP,'str');
                        P.num =evalin('base',tmp_P.num);
                        P.den =evalin('base',tmp_P.den);
                        
                    case 'ss'
                        for kr=1:4
                            tmp_P.(ParaP{kr})=get(editP(kr),'str');
                            P.(ParaP{kr})=evalin('base',tmp_P.(ParaP{kr}));
                        end
                end
                odqdata.P=P;
                set(odqnavi_window,'UserData',odqdata)
                
                set(plantpanel  ,'Visible','off');
                set(stplant     ,'FontWeight','normal')
                if strcmp(odqdata.connection,'ff')
                    set(Qpanel1,'Visible','on');
                    set(stqntzr ,'FontWeight','bold')
                    process=4;
                else
                    set(ctrlpanel,'Visible','on');
                    set(stcntrl,'FontWeight','bold')
                    process=3;
                end
            case 3
                switch odqdata.Ktype
                    case 'tf'
                        tmp_K.num=get(editnumK,'str');
                        tmp_K.den=get(editdenK,'str');
                        K.num =evalin('base',tmp_K.num);
                        K.den =evalin('base',tmp_K.den);
                    case 'ss'
                        for kr=1:6
                            tmp_K.(ParaK{kr})=get(editK(kr),'str');
                            K.(ParaK{kr})=evalin('base',tmp_K.(ParaK{kr}));
                        end
                end
                odqdata.K=K;
                set(odqnavi_window,'UserData',odqdata)
                
                set(ctrlpanel,'Visible','off');
                set(Qpanel1  ,'Visible','on');
                set(stcntrl,'FontWeight','normal')
                set(stqntzr,'FontWeight','bold')
                process=4;
            case 2.5
                switch odqdata.Gtype
                    case 'tf'
                        tmp_G.num=get(editnumG,'str');
                        tmp_G.den=get(editdenG,'str');
                        G.num =evalin('base',tmp_G.num);
                        G.den =evalin('base',tmp_G.den);
                    case 'ss'
                        for kr=1:7
                            tmp_G.(ParaG{kr})=get(editG(kr),'str');
                            G.(ParaG{kr})=evalin('base',tmp_G.(ParaG{kr}));
                        end
                end
                odqdata.G=G;
                set(odqnavi_window,'UserData',odqdata)
                
                set(lftpanel,'Visible','off');
                set(Qpanel1 ,'Visible','on');
                set(stcntrl,'FontWeight','normal')
                set(stplant,'FontWeight','normal')
                set(stqntzr,'FontWeight','bold')
                process=4;
            case 4
                odqdata.d=str2double(get(editd,'str'));
                set(odqnavi_window,'UserData',odqdata);
                
                set(Qpanel1,'Visible','off');
                set(Qpanel2,'Visible','on');
                process=4.2;
            case 4.2
                odqdata.T=str2double(get(editT,'str'));
                set(odqnavi_window,'UserData',odqdata);
                
                set(Qpanel2,'Visible','off');
                set(Qpanel3,'Visible','on');
                process=4.3;
            case 4.3
                odqdata.gamma.uv=str2double(get(edituv,'str'));
                odqdata.gamma.wv=str2double(get(editwv,'str'));
                set(odqnavi_window,'UserData',odqdata);
                
                set(Qpanel3,'Visible','off');
                set(Qpanel4,'Visible','on');
                set(buttonnext,'str','Design');
                process=4.4;
            case 4.4
                odqdata.T=str2double(get(editT,'str'));
                set(odqnavi_window,'UserData',odqdata);
                setsummary
                if ~strcmp(odqdata.connection,'lft') && strcmp(odqdata.Ptype,'tf')
                    [P.a, P.b, P.c1, P.d]=tf2ss(odqdata.P.num,odqdata.P.den);
                    P.c2=P.c1;
                    odqdata.P=P;
                end
                if strncmp(odqdata.connection,'fb',2) && strcmp(odqdata.Ktype,'tf')
                    [K.a, K.b2, K.c, K.d2]=tf2ss(odqdata.K.num,odqdata.K.den);
                    K.b1=K.b2;
                    K.d1=K.d2;
                    odqdata.K=K;
                end
                
                set(Qpanel4 ,'Visible','off');
                set(sumpanel,'Visible','on');
                set(stqntzr,'FontWeight','normal');
                set(stsmmry,'FontWeight','bold');
                process=5;
            case 5
                con=odqdata.connection;
                if strcmp(con,'lft')
                    G=odqdata.G;
                else
                    P=odqdata.P;
                    if strcmp(con,'ff')
                        K=[];
                    else
                        K=odqdata.K;
                    end
                    G=compg(P,K,con);
                end
                T=odqdata.T;
                d=odqdata.d;
                gamma=odqdata.gamma;
                solver=odqdata.solver;
                [Q, E, Hk, gain]=odq(G,T,d,gamma,[],solver);
                if ~strcmp(con,'lft')
                    odqdata.P=P;
                    odqdata.K=K;
                end
                odqdata.G=G;
                odqdata.connection=con;
                odqdata.Q=Q;
                odqdata.E=E;
                odqdata.Hk=Hk;
                odqdata.gain=gain;
                set(odqnavi_window,'UserData',odqdata)
                setresult
                set(sumpanel,'Visible','off');
                set(respanel,'Visible','on');
                set(hObject,'str','Next');
                set(stsmmry,'FontWeight','normal')
                %                set(stsummary,'FontWeight','bold')
                process=6;
            case 6
                if get(setdim,'Value')==1
                    set(respanel ,'Visible','off');
                    set(savepanel,'Visible','on');
                    %                set(stsummary,'FontWeight','normal')
                    %                set(stsummary,'FontWeight','bold')
                    set(buttonnext,'Enable','off')
                    process=7;
                else
                    G =odqdata.G;
                    Hk=odqdata.Hk;
                    T =odqdata.T;
                    d =odqdata.d;
                    dimchoice=get(setdim,'Value');
                    dimcandidate=get(setdim,'str');
                    customdim=size(dimcandidate,1);
                    if dimchoice==customdim
                        dim=str2double(get(setdimcustom,'str'));
                    else
                        dim=str2double(dimcandidate(dimchoice));
                    end
                    [Q, Hk] = odqreal(G,Hk,dim);
                    E = odqcost(G,Q,d,T);
                    gain = odqgain(Q,T);
                    odqdata.Q=Q;
                    odqdata.E=E;
                    odqdata.Hk=Hk;
                    odqdata.gain=gain;
                    set(odqnavi_window,'UserData',odqdata)
                    setresult
                    set(setdim,'Value',1);
                    set(buttonnext,'str','Next')
                end
            case 7
                set(savepanel  ,'Visible','off');
                set(setsimpanel,'Visible','on');
                %                set(stquantizer,'FontWeight','normal')
                %                set(stsummary,'FontWeight','bold')
                process=8;
            case 8
                set(setsimpanel,'Visible','off');
                set(simpanel   ,'Visible','on');
                set(buttonnext,'str','Start');
                process=9;
            case 9
                startsim;
                process=10;
        end
        set(workflow      ,'UserData',process);
        set(odqnavi_window,'UserData',odqdata);
    end

    function buttonback_callback(hObject,eventdata,handles)
        process=get(workflow,'UserData');
        switch process
            case {9,10}
                set(simpanel   ,'Visible','off');
                set(setsimpanel,'Visible','on');
                %                set(stsummary,'FontWeight','normal')
                %                set(stsummary,'FontWeight','bold')
                process=8;
            case 8
                set(setsimpanel,'Visible','off');
                set(savepanel  ,'Visible','on');
                %                set(stsummary,'FontWeight','normal')
                %                set(stsummary,'FontWeight','bold')
                set(buttonnext ,'Enable','off');
                process=7;
            case 7
                set(savepanel,'Visible','off');
                set(respanel ,'Visible','on');
                %                set(stsummary,'FontWeight','normal')
                %                set(stsummary,'FontWeight','bold')
                set(buttonnext,'Enable','on')
                process=6;
            case 6
                set(respanel,'Visible','off');
                set(sumpanel,'Visible','on');
                set(buttonnext,'str','Design');
                %                set(stsummary,'FontWeight','normal')
                set(stsmmry,'FontWeight','bold')
                process=5;
            case 5
                set(sumpanel,'Visible','off');
                set(Qpanel4 ,'Visible','on');
                set(buttonnext,'str','Next');
                set(stsmmry  ,'FontWeight','normal')
                set(stqntzr,'FontWeight','bold')
                process=4.4;
            case 4.4
                set(Qpanel4,'Visible','off');
                set(Qpanel3,'Visible','on');
                process=4.3;
            case 4.3
                set(Qpanel3,'Visible','off');
                set(Qpanel2,'Visible','on');
                process=4.2;
            case 4.2
                set(Qpanel2,'Visible','off');
                set(Qpanel1,'Visible','on');
                process=4;
            case 4
                set(Qpanel1,'Visible','off');
                set(stqntzr,'FontWeight','normal');
                set(stcntrl,'FontWeight','bold');
                if strcmp(odqdata.connection,'lft')
                    set(stplant,'FontWeight','bold');
                    set(lftpanel,'Visible','on');
                    process=2.5;
                else
                    set(ctrlpanel  ,'Visible','on');
                    process=3;
                end
            case 2.5
                set(lftpanel   ,'Visible','off');
                set(systempanel,'Visible','on');
                set(stcntrl,'FontWeight','normal')
                set(stplant,'FontWeight','normal')
                set(stsystm,'FontWeight','bold')
                process=2;
            case 3
                set(ctrlpanel ,'Visible','off');
                set(plantpanel,'Visible','on');
                set(stcntrl,'FontWeight','normal')
                set(stplant,'FontWeight','bold')
                process=2;
            case 2
                set(plantpanel ,'Visible','off');
                set(systempanel,'Visible','on');
                set(stplant,'FontWeight','normal')
                set(stsystm,'FontWeight','bold')
                process=1;
            case 1
                set(systempanel,'Visible','off');
                set(intropanel ,'Visible','on');
                set(hObject,'Enable','off');
                set(stsystm,'FontWeight','normal')
                set(stintro,'FontWeight','bold')
                process=0;
        end
        set(workflow,'UserData',process);
        set(odqnavi_window,'UserData',odqdata);
    end


%%%%% Callbacks for SystemPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function axesff_createfcn(hObject,eventdata,handles)
        block=create_ff_block(hObject);
        set(hObject,'UserData',block)
    end
    function axesfbiq_createfcn(hObject,eventdata,handles)
        block=create_fbiq_block(hObject);
        set(hObject,'UserData',block)
    end
    function axesfboq_createfcn(hObject,eventdata,handles)
        block=create_fboq_block(hObject);
        set(hObject,'UserData',block)
    end
    function axeslft_createfcn(hObject,eventdata,handles)
        block=create_GQ_block(hObject);
        set(hObject,'UserData',block)
    end
    function connenction_selectionchangefcn(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'UserData');
        odqdata.connection=get(eventdata.NewValue,'Tag');
        set(odqnavi_window,'UserData',odqdata)
    end


%%%%% Callbacks for PlantPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plant_selectionchangefcn(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'UserData');
        odqdata.Ptype=get(eventdata.NewValue,'Tag');
        switch odqdata.Ptype
            case 'tf'
                set(planttf,'Visible','on');
                set(plantss,'Visible','off');
            case 'ss'
                set(planttf,'Visible','off');
                set(plantss,'Visible','on');
        end
        set(odqnavi_window,'Userdata',odqdata);
    end

%%%%% Callbacks for ControllerPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function controller_selectionchangefcn(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'UserData');
        odqdata.Ktype=get(eventdata.NewValue,'Tag');
        switch odqdata.Ktype
            case 'tf'
                set(ctrltf,'Visible','on');
                set(ctrlss,'Visible','off');
            case 'ss'
                set(ctrltf,'Visible','off');
                set(ctrlss,'Visible','on');
        end
        set(odqnavi_window,'Userdata',odqdata);
    end


%%%%% Callbacks for QuantizerPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function axesinterval_createfcn(hObject,eventdata,handles)
        line([0.1 7.9 NaN 4 4],[4 4 NaN 0.1 7.9],linkDef,'Parent',hObject);
        patch([7.8,8,7.8;3.9,4,4.1]',[4.1,4,3.9;7.8,8,7.8]','k','Parent',hObject)
        line([0 0.5 0.5 1.5 1.5 2.5 2.5 3.5 3.5 4.5 4.5 5.5 5.5 6.5 6.5 7.5 7.5 8],...
            [0 0   1   1   2   2   3   3   4   4   5   5   6   6   7   7   8   8],...
            linrDef,'Parent',hObject);
        line([5.4,5.4],[4.1,4.9],linkDef,'Parent',hObject);
        patch([5.3,5.4,5.5;5.3,5.4,5.5]',[4.8,5,4.8;4.2,4,4.2]','k','Parent',hObject)
        text(5.8,4.5,'$d$',txtkDef,'Parent',hObject);
        
    end
    function axesE_createfcn(hObject,eventdata,handles)
        plot(0:0.1:10,2*sin(2.*(0:0.1:10)),'LineWidth',2,'Color',[0 0 1],'Parent',hObject);
        hold(hObject,'on')
        stairs(-0.1:0.2:10.1,2*sin(2.*(0:0.2:10.2)),'LineWidth',2,'Color',[1 0 0],'Parent',hObject);
        hold(hObject,'off')
        set(hObject,'XLim',[0 10],'YLim',[-4 4],'XTick',0:1:10,'YTick',-4:1:4,...
            'XTickLabel',[],'YTickLabel',[],'XGrid','on','YGrid','on');
        %         line([0  1  1  2  2  3  3  4  5  5  6  6  7  7  8  8  9  9 10],...
        %              [3  3  0  0 -3 -3  3  3  3 -3 -3  0  0  3  3 -3 -3  0  0],...
        %              linrDef,'Parent',hObject);
        line([0.2,7.8],[-2.5,-2.5],linkDef,'Parent',hObject);
        patch([0.25,0,0.25;7.75,8,7.75]',[-2.3,-2.5,-2.7;-2.3,-2.5,-2.7]','k','Parent',hObject)
        text(4,-3,'$T$',txtkDef,'Parent',hObject);
    end
    function axesuv_createfcn(hObject,eventdata,handles)
        plot(1:0.1:3,sin(6.5*(0:0.1:2))+4,'LineWidth',2,'Color',[0 0 1],'Parent',hObject);
        hold(hObject,'on')
        plot(7:0.1:9,1.5*sin(6.5*(0:0.1:2))+4,'LineWidth',2,'Color',[1 0 0],'Parent',hObject);
        hold(hObject,'off')
        set(hObject,'XLim',[0 10],'YLim',[0 8],'Visible','off');
        line([1 3 NaN 1 3 NaN 7.0 9.0 NaN 7.0 9.0],...
            [3 3 NaN 5 5 NaN 5.5 5.5 NaN 2.5 2.5],...
            linkDef,'Parent',hObject);
        line([2.0 2.0 NaN 2.0 2.0 NaN 8.0 8.0 NaN 8.0 8.0],...
            [1.1 2.9 NaN 6.9 5.1 NaN 0.1 2.4 NaN 7.9 5.6],...
            linkDef,'Parent',hObject);
        patch([1.8,2.0,2.2;1.8,2.0,2.2;7.8,8.0,8.2;7.8,8.0,8.2]',...
            [2.0,3.0,2.0;6.0,5.0,6.0;1.5,2.5,1.5;6.5,5.5,6.5]',...
            'k','Parent',hObject)
        line([3 7 NaN 3 7],[5 5.5 NaN 3 2.5],...
            'LineWidth',1,'LineStyle',':','Color',[0 0 0],'Parent',hObject);
        line([3.1 3.9],[4 4],linbDef,'Parent',hObject);
        line([6.1 6.9],[4 4],linrDef,'Parent',hObject);
        patch([3.5,4,3.5]',[3.75,4,4.25]','b','Parent',hObject)
        patch([6.5,7,6.5]',[3.75,4,4.25]','r','Parent',hObject)
        rectangle('pos',[4 3 2 2],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(4.75,4,'$Q$',txtkDef,'Parent',hObject);
        text(0.2,4,'$u$',txtkDef,'Parent',hObject);
        text(9.5,4,'$v$',txtkDef,'Parent',hObject);
    end
    function axeswv_createfcn(hObject,eventdata,handles)
        plot(1:0.1:3,sin(6.5*(0:0.1:2))+4,'LineWidth',2,'Color',[0 0 1],'Parent',hObject);
        hold(hObject,'on')
        plot(7:0.1:9,1.5*sin(6.5*(0:0.1:2))+4,'LineWidth',2,'Color',[1 0 0],'Parent',hObject);
        hold(hObject,'off')
        set(hObject,'XLim',[0 10],'YLim',[0 8],'Visible','off');
        line([1 3 NaN 1 3 NaN 7.0 9.0 NaN 7.0 9.0],...
            [3 3 NaN 5 5 NaN 5.5 5.5 NaN 2.5 2.5],...
            linkDef,'Parent',hObject);
        line([2.0 2.0 NaN 2.0 2.0 NaN 8.0 8.0 NaN 8.0 8.0],...
            [1.1 2.9 NaN 6.9 5.1 NaN 0.1 2.4 NaN 7.9 5.6],...
            linkDef,'Parent',hObject);
        patch([1.8,2.0,2.2;1.8,2.0,2.2;7.8,8.0,8.2;7.8,8.0,8.2]',...
            [2.0,3.0,2.0;6.0,5.0,6.0;1.5,2.5,1.5;6.5,5.5,6.5]','k','Parent',hObject)
        line([3 7 NaN 3 7],[5 5.5 NaN 3 2.5],...
            'LineWidth',1,'LineStyle',':','Color',[0 0 0],'Parent',hObject);
        line([3.1 3.9],[4 4],linbDef,'Parent',hObject);
        line([6.1 6.9],[4 4],linrDef,'Parent',hObject);
        patch([3.5,4,3.5]',[3.75,4,4.25]','b','Parent',hObject)
        patch([6.5,7,6.5]',[3.75,4,4.25]','r','Parent',hObject)
        rectangle('pos',[4 3 2 2],'FaceColor',[1.0 1.0 0.0],'Parent',hObject);
        text(4.75,4,'$Q$',txtkDef,'Parent',hObject);
        text(0.2,4,'$w$',txtkDef,'Parent',hObject);
        text(9.5,4,'$v$',txtkDef,'Parent',hObject);
    end
    function lpsolver_selectionchangefcn(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'UserData');
        odqdata.solver=get(eventdata.NewValue,'str');
        set(odqnavi_window,'UserData',odqdata);
    end

%%%%% Callbacks for ResultPanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setdim_callback(hObject,eventdata,handles)
        dimchoice=get(hObject,'Value');
        customdim=size(get(hObject,'str'),1);
        if dimchoice==customdim
            set(setdimcustom,'Visible','on');
        else
            set(setdimcustom,'Visible','off');
        end
        if dimchoice==1
            set(buttonnext,'str','Next')
        else
            set(buttonnext,'str','Reduce');
        end
    end


%%%%% Callbacks for SavePanel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function save_q_callback(hObject,eventdata)
        odqdata=get(odqnavi_window,'UserData');
        callmode=get(hObject,'str');
        
        DQpos=get(odqnavi_window,'pos');
        datasel=figure('units','pixels','pos',[DQpos(1)+200 DQpos(2)+100 300 100],...
            'Visible','off','windowstyle','modal','Userdata','Qonly',...
            'MenuBar','none','ToolBar','figure','NumberTitle','off',...
            'Name','Which you want to save?');
        selpnl=uibuttongroup(datasel,'units','pixels','BorderType','none',...
            'pos',[10 40 280 50],'SelectionChangeFcn',@datasel_changefcn);
        uicontrol(selpnl,RbtnDef,'Tag','Qonly',...
            'pos',[5 30 100 20],'str','Quantizer only')
        uicontrol(selpnl,RbtnDef,'Tag','AllData',...
            'pos',[5 5 200 20],'str','All Data (stored in structure array)')
        uicontrol(datasel,PbtnDef,'str','OK','pos',[120 10 80 20],...
            'Callback',@savedata_OK_callback);
        uicontrol(datasel,PbtnDef,'str','Cancel','pos',[210 10 80 20],...
            'Callback',@savedata_NG_callback)
        
        set(datasel,'visible','on')
        
        function datasel_changefcn(hObject, eventdata)
            switch get(eventdata.NewValue,'Tag')
                case 'Qonly'
                    set(datasel,'UserData','Qonly');
                case 'AllData'
                    set(datasel,'UserData','AllData');
            end
        end
        
        function savedata_OK_callback(hObject, eventdata)
            save_flag=get(datasel,'UserData');
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
            close(datasel)
        end
        
        function savedata_NG_callback(hObject, eventdata)
            close(datasel)
        end
    end

    function numsim_callback(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'Userdata');
        set(savepanel,'Visible','off');
        set(setsimpanel,'Visible','on');
        process=8;
        set(workflow,'UserData',process);
        switch odqdata.connection
            case 'ff'
                create_ff_block(simblock);
                set(steditR,'pos',[125 225 100 20]);
                set(editR  ,'pos',[150 205 50 20]);
                set(steditxP0,'pos',[340 265 100 20]);
                set(editxP0  ,'pos',[365 245 50 20]);
                set(steditxK0,'Visible','off');
                set(editxK0  ,'Visible','off');
            case 'fbiq'
                create_fbiq_block(simblock);
            case 'fboq'
                create_fboq_block(simblock);
            case 'lft'
                create_GQ_block(simblock);
                set(steditxP0,'str','Initial value (G)','pos',[290 290 100 20]);
                set(editxP0,'pos',[315 270 50 20]);
                set(steditxK0,'Visible','off');
                set(editxK0  ,'Visible','off');
        end
        set(buttonnext,'Enable','on')
    end

    function exp_callback(hObject,eventdata,handles)
        odqdata=get(odqnavi_window,'Userdata');
        if ispc
            xpcexplr
            xpclib
        end
        switch odqdata.connection
            case 'ff'
                open odqexp_ff.mdl;
                for kQ=1:4
                    set_param('odqexp_ff/ODQ',upper(ParaP{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                save_system('odqexp_ff',[currentfolder '/odqexp_ff'],'BreakAllLinks','true');
            case 'fbiq'
                open odqexp_fbiq.mdl;
                for kQ=1:4
                    set_param('odqexp_fbiq/ODQ',upper(ParaP{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqexp_fbiq/K',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                save_system('odqexp_fbiq',[currentfolder '/odqexp_fbiq'],'BreakAllLinks','true');
            case 'fboq'
                open odqexp_fboq.mdl;
                for kQ=1:4
                    set_param('odqexp_fboq/ODQ',upper(ParaP{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                for kK=1:6
                    set_param('odqexp_fboq/K',upper(ParaK{kK}),mat2str(odqdata.K.(ParaK{kK})));
                end
                save_system('odqexp_fboq',[currentfolder '/odqexp_fboq'],'BreakAllLinks','true');
            case 'lft'
                open odqexp_lft.mdl;
                for kQ=1:4
                    set_param('odqexp_lft/ODQ',upper(ParaP{kQ}),mat2str(odqdata.Q.(ParaQ{kQ})));
                end
                save_system('odqexp_lft',[currentfolder '/odqexp_lft'],'BreakAllLinks','true');
        end
    end

%%%%% Other functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function block=create_ff_block(parent)
        block.u=line([ 4 11],[11 11],linbDef,'Parent',parent);
        block.v=line([20 27],[11 11],linrDef,'Parent',parent);
        block.z=line([36 43],[11 11],linkDef,'Parent',parent);
        block.P=rectangle('pos',[28 8 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',parent);
        block.Q=rectangle('pos',[12 8 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',parent);
        block.txP=text(30.4,11,'$P$',txtwDef,'Parent',parent);
        block.txQ=text(14.4,11,'$Q$',txtkDef,'Parent',parent);
        block.aru=patch([10,12,10],[12,11,10],'b','Parent',parent);
        block.arv=patch([26,28,26],[12,11,10],'r','Parent',parent);
        block.arz=patch([42,44,42],[12,11,10],'k','Parent',parent);
    end
    function block=create_fbiq_block(parent)
        block.r=line([ 0  7],[16 16],linkDef,'Parent',parent);
        block.u=line([16 19],[15 15],linbDef,'Parent',parent);
        block.v=line([28 31],[15 15],linrDef,'Parent',parent);
        block.z=line([40 47],[16 16],linkDef,'Parent',parent);
        block.y=line([40 42 42 5 5 7],[14 14 8 8 14 14],linkDef,'Parent',parent);
        block.P=rectangle('pos',[32 12 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',parent);
        block.K=rectangle('pos',[ 8 12 8 6],'FaceColor',[1.0 0.7 0.0],'Parent',parent);
        block.Q=rectangle('pos',[20 12 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',parent);
        block.txP=text(34.4,15,'$P$',txtwDef,'Parent',parent);
        block.txK=text(10.4,15,'$K$',txtwDef,'Parent',parent);
        block.txQ=text(22.4,15,'$Q$',txtkDef,'Parent',parent);
        block.arr=patch([ 6, 8, 6],[17,16,15],'k','Parent',parent);
        block.aru=patch([18,20,18],[16,15,14],'b','Parent',parent);
        block.arv=patch([30,32,30],[16,15,14],'r','Parent',parent);
        block.arz=patch([46,48,46],[17,16,15],'k','Parent',parent);
        block.ary=patch([ 6, 8, 6],[15,14,13],'k','Parent',parent);
    end
    function block=create_fboq_block(parent)
        block.r=line([ 0  7],[16 16],linkDef,'Parent',parent);
        block.u=line([40 42 42 29],[14 14  8  8],linbDef,'Parent',parent);
        block.v=line([20  5  5  7],[ 8  8 14 14],linrDef,'Parent',parent);
        block.z=line([40 47],[16 16],linkDef,'Parent',parent);
        block.w=line([16 31],[15 15],linkDef,'Parent',parent);
        block.P=rectangle('pos',[32 12 8 6],'FaceColor',[0.7 0.3 1.0],'Parent',parent);
        block.K=rectangle('pos',[ 8 12 8 6],'FaceColor',[1.0 0.7 0.0],'Parent',parent);
        block.Q=rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',parent);
        block.txP=text(34.4,15,'$P$',txtwDef,'Parent',parent);
        block.txK=text(10.4,15,'$K$',txtwDef,'Parent',parent);
        block.txQ=text(22.4, 8,'$Q$',txtkDef,'Parent',parent);
        block.arr=patch([ 6, 8, 6],[17,16,15],'k','Parent',parent);
        block.aru=patch([30,28,30],[ 9, 8, 7],'b','Parent',parent);
        block.arv=patch([ 6, 8, 6],[15,14,13],'r','Parent',parent);
        block.arz=patch([46,48,46],[17,16,15],'k','Parent',parent);
        block.arw=patch([30,32,30],[16,15,14],'k','Parent',parent);
    end
    function block=create_GQ_block(parent)
        block.r=line([ 4 19],[16 16],linkDef,'Parent',parent);
        block.z=line([28 43],[16 16],linkDef,'Parent',parent);
        block.u=line([28 36 36 29],[14 14  8  8],linbDef,'Parent',parent);
        block.v=line([20 12 12 19],[ 8  8 14 14],linrDef,'Parent',parent);
        block.G=rectangle('pos',[20 12 8 6],'FaceColor',[0.0 0.7 0.3],'Parent',parent);
        block.Q=rectangle('pos',[20  5 8 6],'FaceColor',[1.0 1.0 0.0],'Parent',parent);
        block.txG=text(22.4,15,'$G$',txtwDef,'Parent',parent);
        block.txQ=text(22.4, 8,'$Q$',txtkDef,'Parent',parent);
        block.aru=patch([30,28,30],[ 9, 8, 7],'b','Parent',parent);
        block.arv=patch([18,20,18],[15,14,13],'r','Parent',parent);
        block.arr=patch([18,20,18],[17,16,15],'k','Parent',parent);
        block.arz=patch([42,44,42],[17,16,15],'k','Parent',parent);
    end


    function setsummary
        odqdata=get(odqnavi_window,'UserData');
        if strcmp(odqdata.connection,'lft')
            Gtype=odqdata.Gtype;
            Gtmp=odqdata.G;
            switch Gtype
                case 'tf'
                    Gstnum='';
                    for k=1:length(Gtmp.num)
                        if Gtmp.num(k)~=0
                            if Gtmp.num(k)==1 && k~=length(Gtmp.num)
                                Gsttmp='';
                            elseif Gtmp.num(k)==-1 && k~=length(Gtmp.num)
                                Gsttmp='-';
                            else
                                Gsttmp=num2str(Gtmp.num(k));
                            end
                            if k~=1 && Gtmp.num(k)>=0
                                Gstnum=strcat(Gstnum,sprintf('%s','+'));
                            end
                            if (length(Gtmp.num)-k)==0
                                Gstnum=strcat(Gstnum,sprintf('%s',Gsttmp));
                            elseif (length(Gtmp.num)-k)==1
                                Gstnum=strcat(Gstnum,sprintf('%s%s',Gsttmp,'s'));
                            else
                                Gstnum=strcat(Gstnum,sprintf('%s%s%d',Gsttmp,'s^',length(Gtmp.num)-k));
                            end
                        end
                    end
                    Gstden='';
                    for k=1:length(Gtmp.den)
                        if Gtmp.den(k)~=0
                            if Gtmp.den(k)==1 && k~=length(Gtmp.den)
                                Gsttmp='';
                            elseif Gtmp.den(k)==-1 && k~=length(Gtmp.den)
                                Gsttmp='-';
                            else
                                Gsttmp=num2str(Gtmp.den(k));
                            end
                            if k~=1 && Gtmp.den(k)>=0
                                Gstden=strcat(Gstden,sprintf('%s','+'));
                            end
                            if (length(Gtmp.den)-k)==0
                                Gstden=strcat(Gstden,sprintf('%s',Gsttmp));
                            elseif (length(Gtmp.den)-k)==1
                                Gstden=strcat(Gstden,sprintf('%s%s',Gsttmp,'s'));
                            else
                                Gstden=strcat(Gstden,sprintf('%s%s%d',Gsttmp,'s^',length(Gtmp.den)-k));
                            end
                        end
                    end
                    
                    Gstbar=char('-'*ones(max(size(Gstnum),size(Gstden))));
                    set(summaryPtype,'str','G: Transfer function');
                    set(summaryPdata,'str',{Gstnum,Gstbar,Gstden});
                case 'ss'
                    Gsta =sprintf('%s%d%s%d%s','A: ' ,size(Gtmp.a,1) ,'x',size(Gtmp.a,2) ,' matrix');
                    Gstb1=sprintf('%s%d%s%d%s','B1: ',size(Gtmp.b1,1),'x',size(Gtmp.b1,2),' matrix');
                    Gstb2=sprintf('%s%d%s%d%s','B1: ',size(Gtmp.b2,1),'x',size(Gtmp.b2,2),' matrix');
                    Gstc1=sprintf('%s%d%s%d%s','C1: ',size(Gtmp.c1,1),'x',size(Gtmp.c1,2),' matrix');
                    Gstc2=sprintf('%s%d%s%d%s','C2: ',size(Gtmp.c2,1),'x',size(Gtmp.c2,2),' matrix');
                    Gstd1=sprintf('%s%d%s%d%s','C1: ',size(Gtmp.d1,1),'x',size(Gtmp.d1,2),' matrix');
                    Gstd2=sprintf('%s%d%s%d%s','C2: ',size(Gtmp.d2,1),'x',size(Gtmp.d2,2),' matrix');
                    set(summaryPtype,'str','G: State space');
                    set(summaryPdata,'str',{Gsta,Gstb1,Gstb2,Gstc1,Gstc2,Gstd1,Gstd2});
                    set(summaryKtype,'Visible','off');
                    set(summaryKdata,'Visible','off');
            end
        else
            Ptype=odqdata.Ptype;
            Ptmp=odqdata.P;
            switch Ptype
                case 'tf'
                    Pstnum='';
                    for k=1:length(Ptmp.num)
                        if Ptmp.num(k)~=0
                            if Ptmp.num(k)==1 && k~=length(Ptmp.num)
                                Psttmp='';
                            elseif Ptmp.num(k)==-1 && k~=length(Ptmp.num)
                                Psttmp='-';
                            else
                                Psttmp=num2str(Ptmp.num(k));
                            end
                            if k~=1 && Ptmp.num(k)>=0
                                Pstnum=strcat(Pstnum,sprintf('%s','+'));
                            end
                            if (length(Ptmp.num)-k)==0
                                Pstnum=strcat(Pstnum,sprintf('%s',Psttmp));
                            elseif (length(Ptmp.num)-k)==1
                                Pstnum=strcat(Pstnum,sprintf('%s%s',Psttmp,'s'));
                            else
                                Pstnum=strcat(Pstnum,sprintf('%s%s%d',Psttmp,'s^',length(Ptmp.num)-k));
                            end
                        end
                    end
                    Pstden='';
                    for k=1:length(Ptmp.den)
                        if Ptmp.den(k)~=0
                            if Ptmp.den(k)==1 && k~=length(Ptmp.den)
                                Psttmp='';
                            elseif Ptmp.den(k)==-1 && k~=length(Ptmp.den)
                                Psttmp='-';
                            else
                                Psttmp=num2str(Ptmp.den(k));
                            end
                            if k~=1 && Ptmp.den(k)>=0
                                Pstden=strcat(Pstden,sprintf('%s','+'));
                            end
                            if (length(Ptmp.den)-k)==0
                                Pstden=strcat(Pstden,sprintf('%s',Psttmp));
                            elseif (length(Ptmp.den)-k)==1
                                Pstden=strcat(Pstden,sprintf('%s%s',Psttmp,'s'));
                            else
                                Pstden=strcat(Pstden,sprintf('%s%s%d',Psttmp,'s^',length(Ptmp.den)-k));
                            end
                        end
                    end
                    
                    Pstbar=char('-'*ones(max(size(Pstnum),size(Pstden))));
                    set(summaryPtype,'str','P: Transfer function');
                    set(summaryPdata,'str',{Pstnum,Pstbar,Pstden});
                case 'ss'
                    Psta =sprintf('%s%d%s%d%s','A: ' ,size(Ptmp.a,1) ,'x',size(Ptmp.a,2) ,' matrix');
                    Pstb =sprintf('%s%d%s%d%s','B: ' ,size(Ptmp.b,1) ,'x',size(Ptmp.b,2) ,' matrix');
                    Pstc1=sprintf('%s%d%s%d%s','C1: ',size(Ptmp.c1,1),'x',size(Ptmp.c1,2),' matrix');
                    Pstc2=sprintf('%s%d%s%d%s','C2: ',size(Ptmp.c2,1),'x',size(Ptmp.c2,2),' matrix');
                    set(summaryPtype,'str','P: State space');
                    set(summaryPdata,'str',{Psta,Pstb,Pstc1,Pstc2});
            end
            if strncmp(odqdata.connection,'fb',2)
                Ktype=odqdata.Ktype;
                Ktmp=odqdata.K;
                switch Ktype
                    case 'tf'
                        Kstnum='';
                        for k=1:length(Ktmp.num)
                            if Ktmp.num(k)~=0
                                if Ktmp.num(k)==1 && k~=length(Ktmp.num)
                                    Ksttmp='';
                                elseif Ktmp.num(k)==-1 && k~=length(Ktmp.num)
                                    Ksttmp='-';
                                else
                                    Ksttmp=num2str(Ktmp.num(k));
                                end
                                if k~=1 && Ktmp.num(k)>=0
                                    Kstnum=strcat(Kstnum,sprintf('%s','+'));
                                end
                                if (length(Ktmp.num)-k)==0
                                    Kstnum=strcat(Kstnum,sprintf('%s',Ksttmp));
                                elseif (length(Ktmp.num)-k)==1
                                    Kstnum=strcat(Kstnum,sprintf('%s%s',Ksttmp,'z'));
                                else
                                    Kstnum=strcat(Kstnum,sprintf('%s%s%d',Ksttmp,'z^',length(Ktmp.num)-k));
                                end
                            end
                        end
                        Kstden='';
                        for k=1:length(Ktmp.den)
                            if Ktmp.den(k)~=0
                                if Ktmp.den(k)==1 && k~=length(Ktmp.den)
                                    Ksttmp='';
                                elseif Ktmp.den(k)==-1 && k~=length(Ktmp.den)
                                    Ksttmp='-';
                                else
                                    Ksttmp=num2str(Ktmp.den(k));
                                end
                                if k~=1 && Ktmp.den(k)>=0
                                    Kstden=strcat(Kstden,sprintf('%s','+'));
                                end
                                if (length(Ktmp.den)-k)==0
                                    Kstden=strcat(Kstden,sprintf('%s',Ksttmp));
                                elseif (length(Ktmp.den)-k)==1
                                    Kstden=strcat(Kstden,sprintf('%s%s',Ksttmp,'z'));
                                else
                                    Kstden=strcat(Kstden,sprintf('%s%s%d',Ksttmp,'z^',length(Ktmp.den)-k));
                                end
                            end
                        end
                        
                        Kstbar=char('-'*ones(max(size(Kstnum),size(Kstden))));
                        set(summaryKtype,'str','K: Transfer function');
                        set(summaryKdata,'str',{Kstnum,Kstbar,Kstden});
                    case 'ss'
                        Ksta =sprintf('%s%d%s%d%s','A: ' ,size(Ktmp.a,1) ,'x',size(Ktmp.a,2) ,' matrix');
                        Kstb1=sprintf('%s%d%s%d%s','B1: ',size(Ktmp.b1,1),'x',size(Ktmp.b1,2),' matrix');
                        Kstb2=sprintf('%s%d%s%d%s','B2: ',size(Ktmp.b2,1),'x',size(Ktmp.b2,2),' matrix');
                        Kstc =sprintf('%s%d%s%d%s','C: ' ,size(Ktmp.c,1) ,'x',size(Ktmp.c,2) ,' matrix');
                        Kstd1=sprintf('%s%d%s%d%s','D1: ',size(Ktmp.d1,1),'x',size(Ktmp.d1,2),' matrix');
                        Kstd2=sprintf('%s%d%s%d%s','D2: ',size(Ktmp.d2,1),'x',size(Ktmp.d2,2),' matrix');
                        set(summaryKtype,'str','K: State space');
                        set(summaryKdata,'str',{Ksta,Kstb1,Kstb2,Kstc,Kstd1,Kstd2});
                end
            end
        end
        d =get(editd ,'str');
        T =get(editT ,'str');
        uv=get(edituv,'str');
        wv=get(editwv,'str');
        lp=odqdata.solver;
        set(summaryddata,'str',d)
        set(summaryTdata,'str',T)
        set(summaryuvdata,'str',uv)
        set(summarywvdata,'str',wv)
        set(summarylpdata,'str',lp)
    end


    function setresult
        odqdata=get(odqnavi_window,'UserData');
        G    = odqdata.G;
        Q    = odqdata.Q;
        d    = odqdata.d;
        gain = odqdata.gain;
        E    = odqdata.E;
        Hk   = odqdata.Hk;
        
        if size(Q.a,1)>1000
            Einf='skipped';
        else
            Einf = odqcost(G,Q,d,inf);
        end
        staticQ.a  = 0;
        staticQ.b1 = zeros(1,size(G.c2,1));
        staticQ.b2 = zeros(1,size(G.c2,1));
        staticQ.c  = zeros(size(G.c2,1),1);
        E_upper = odqcost(G,staticQ,d,inf);
        E_low   = norm(G.c1*G.b2,inf)*d/2;
        
        
        set(resultwv   ,'str',gain.wv)
        set(resultuv   ,'str',1)
        set(resultdim  ,'str',size(Q.a,1));
        set(resultET   ,'str',E);
        set(resultEinf ,'str',Einf);
        set(resultLEinf,'str',E_low);
        set(resultUEinf,'str',E_upper)
        singular_xrange=0:size(Hk.S,1)-1;
        stairs(axeshnkl,singular_xrange,diag(Hk.S),'LineWidth',2);
        set(axeshnkl,'YScale','log','YGrid','on');
        redline=zeros(1,size(Hk.S,1));
        for k=1:size(Hk.S,1)-1
            if Hk.S(k+1,k+1)/Hk.S(k,k)<0.1
                redline(k)=1;
            end
        end
        if max(redline)==1
            singular_yrange=get(axeshnkl,'YLim');
            xredline=find(redline);
            for k=1:length(xredline)
                line([xredline(k) xredline(k)],singular_yrange,'Color',[1 0 0],...
                    'Parent',axeshnkl);
            end
            set(axeshnkl,'XTick',xredline,'XTickLabel',xredline);
            set(setdim,'str',['None',num2cell(xredline),'Other']);
        end
        odqdata.E_inf=Einf;
        odqdata.E_lower=E_low;
        odqdata.E_upper=E_upper;
        set(odqnavi_window,'UserData',odqdata)
    end
    function startsim
        odqdata = get(odqnavi_window,'UserData');
        G = odqdata.G;
        Q = odqdata.Q;
        d = odqdata.d;
        
        Rt=get(editR,'str');
        x0_P=get(editxP0,'str');
        x0_K=get(editxK0,'str');
        kFinal=str2double(get(editfinaltime,'str'));
        x  = zeros( size(G.a ,1) , kFinal+1 );
        xQ = zeros( size(G.a ,1) , kFinal+1 );
        z  = zeros( size(G.c1,1) , kFinal+1 );
        zQ = zeros( size(G.c1,1) , kFinal+1 );
        u  = zeros( size(G.c2,1) , kFinal+1 );
        uQ = zeros( size(G.c2,1) , kFinal+1 );
        xi = zeros( size(Q.a ,1) , kFinal+1 );
        v  = zeros( size(Q.c ,1) , kFinal+1 );
        
        k = 0:kFinal;
        flg.r_work  = 0;
        flg.x0_P_work = 0;
        flg.x0_K_work = 0;
        work_val = evalin('base','who');
        for i = 1:size(work_val)
            if strcmp(work_val(i,:),Rt)==1
                r=evalin('base',Rt);
                flg.r_work=1;
            end
            if strcmp(work_val(i,:),x0_P)==1
                x0_P=evalin('base',x0_K);
                flg.x0_P_work=1;
            end
            if strcmp(work_val(i,:),x0_K)==1
                x0_K=evalin('base',x0_K);
                flg.x0_K_work=1;
            end
        end
        if flg.r_work==0
            r = eval(Rt);
        end
        if isscalar(r)==1
            r = r*ones(1,kFinal+1);
        end
        if flg.x0_P_work==1
            x0_P2 = x0_P;
        else
            x0_P2 = eval(x0_P);
        end
        if flg.x0_K_work==1
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
        stairs(axesu   ,k,uQ'    );
        %axis(axes_u,[0 kFinal min(u) max(u)])
        stairs(axesv   ,k,v'    );
        stairs(axesz   ,k,zQ'   );
        stairs(axesdiff,k,zQ'-z');
        ylabel(axesu   ,'Quantizer input'  ,'FontSize',10)
        ylabel(axesv   ,'Quantizer output' ,'FontSize',10)
        ylabel(axesz   ,'Output'           ,'FontSize',10)
        ylabel(axesdiff,'Output difference','FontSize',10)
        set(axesu   ,'XGrid','on','YGrid','on')
        set(axesv   ,'XGrid','on','YGrid','on')
        set(axesz   ,'XGrid','on','YGrid','on')
        set(axesdiff,'XGrid','on','YGrid','on')
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
        odqdata_ex.E_lower    = odqdata.E_lower;
        odqdata_ex.E_upper    = odqdata.E_upper;
    end

end

%#ok<*INUSD>
%#ok<*INUSL>
