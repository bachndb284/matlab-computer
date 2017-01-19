function varargout = MammoProcessing(varargin)
% MAMMOPROCESSING MATLAB code for MammoProcessing.fig
%      MAMMOPROCESSING, by itself, creates a new MAMMOPROCESSING or raises the existing
%      singleton*.
%
%      H = MAMMOPROCESSING returns the handle to a new MAMMOPROCESSING or the handle to
%      the existing singleton*.
%
%      MAMMOPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAMMOPROCESSING.M with the given input arguments.
%
%      MAMMOPROCESSING('Property','Value',...) creates a new MAMMOPROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MammoProcessing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MammoProcessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MammoProcessing

% Last Modified by GUIDE v2.5 07-Jan-2017 22:13:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MammoProcessing_OpeningFcn, ...
                   'gui_OutputFcn',  @MammoProcessing_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MammoProcessing is made visible.
function MammoProcessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MammoProcessing (see VARARGIN)

% Choose default command line output for MammoProcessing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MammoProcessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%==================================================================%
jScrollPane = findjobj(handles.edit1);

jViewPort = jScrollPane.getViewport;
jEditbox = jViewPort.getComponent(0);
jEditbox.setWrapping(false);  
set(jScrollPane,'HorizontalScrollBarPolicy',30);
set(jScrollPane,'VerticalScrollBarPolicy', 21);

cbStr = sprintf('set(gcbo,''HorizontalScrollBarPolicy'',%d),set(gcbo,''VerticalScrollBarPolicy'',%d)',30,21);
hjScrollPane = handle(jScrollPane,'CallbackProperties');
set(hjScrollPane,'ComponentResizedCallback',cbStr);

%==================================================================%
set(handles.slider1, 'Min', 0);
set(handles.slider1, 'Max', 95);
set(handles.slider1, 'SliderStep', [5/(95-0) , 10/(95-0)]);
set(handles.slider1, 'Value', 0);
slider_value=get(handles.slider1,'value');
addlistener(handles.slider1,'ContinuousValueChange',@(hObject, eventdata) slider1_Callback(hObject, eventdata, handles));
%==================================================================%
set(handles.edit2,'string',slider_value);
%==================================================================%

global content_list working_dir boundary_exist Pboundary_exist Blank 

Blank=imread('na.png');
boundary_exist=0; Pboundary_exist=0;
working_dir=cd;
[content_list.name,content_list.isdir]=Working_directory_Update(working_dir,handles);  
%==================================================================%
set(handles.edit1,'string',working_dir);    
%==================================================================%
%set(handles.Loading,'string',''); 


function [name_list,isdir_list]=Working_directory_Update(working_dir,handles)   
directory=dir(working_dir);
dir_index = [directory.isdir];
folder_list={directory(dir_index).name}';
folder_list(1)=[];
folder_list=sort(folder_list);
L1=length(folder_list);

file_list = {directory(~dir_index).name}';
L2=length(file_list);
if L2>0
    temp={L2,2};
    for i=1:L2
        [~,name,ext]=fileparts(file_list{i});
        temp{i,1}=name;
        temp{i,2}=ext;
    end
    temp=sortrows(temp,[2 1]);
    file_list=strcat(temp(:,1),temp(:,2));
end
name_list=[folder_list;file_list];
isdir_list=[ones(L1,1,'uint8');zeros(L2,1,'uint8')];

set(handles.listbox, 'Value', 1); 
set(handles.listbox, 'string', name_list);


% --- Outputs from this function are returned to the command line.
function varargout = MammoProcessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox
global content_list working_dir image_name image_cmt grey_image_org boundary_exist Pboundary_exist Blank 

if strcmp(get(handles.figure1,'SelectionType'),'open')
    boundary_exist=0;
    if boundary_exist ~= Pboundary_exist
       set(handles.Manualbutton,'Enable','off');
       set(handles.Savebutton,'Enable','off');
       set(handles.slider1,'Enable','off');
       set(handles.text5,'Enable','off');
       set(handles.edit2,'Enable','off'); 
       cla(handles.axes2);
       cla(handles.axes3);
       imshow(Blank,'Parent',handles.axes2);
       imshow(Blank,'Parent',handles.axes3);
       Pboundary_exist=boundary_exist;
    end
    
   index_selected = get(handles.listbox,'Value');
   temp_name=content_list.name(index_selected);
   temp_path=char(fullfile(working_dir,temp_name));

   if content_list.isdir(index_selected)==1
       if length(temp_path)<3
           temp_path=[temp_path,'\'];
       end
       working_dir=temp_path;
       [content_list.name,content_list.isdir]=Working_directory_Update(working_dir,handles);  
       set(handles.edit1,'string',working_dir); 
   else
        filename= temp_path;
        [~,~,ext]=fileparts( filename); 
        if strcmp(ext,'.png')
            drawnow;
        
            grey_image_org=imread(filename);
            imshow(grey_image_org,[],'Parent',handles.axes1);
            
            image_name=temp_name;
            set(handles.Flnedit,'string',image_name); 
            
            temp_cmt=imfinfo(filename);
            image_cmt=temp_cmt.Comment;
                    
        else
             d=errordlg('File Type Error','Error');
             uiwait(d);
        end
   end
end

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Openbutton.
function Openbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Openbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global content_list working_dir image_name grey_image_org boundary_exist Pboundary_exist Blank

[fname,pathname]=uigetfile('*.png','File selection',working_dir);

if (fname~=0)
   %set(handles.Loading,'string','Loading...');
   drawnow;
   
   if strcmp(working_dir,pathname)~=1
        if length(pathname)<4
            working_dir=pathname;
        else
            working_dir=pathname(1:end-1);
        end
        [content_list.name,content_list.isdir]=Working_directory_Update(working_dir,handles);  
        set(handles.edit1,'string',working_dir); 
   end
   filename=strcat(pathname,fname);
   grey_image_org=imread(filename);
   imshow(grey_image_org,[],'Parent',handles.axes1);
   
   image_name=fname;
   set(handles.Flnedit,'string',image_name); 
    
   boundary_exist=0;
   if boundary_exist ~= Pboundary_exist
       Pboundary_exist=boundary_exist;
       set(handles.Manualbutton,'Enable','off');
       set(handles.Savebutton,'Enable','off');
       set(handles.slider1,'Enable','off');
       set(handles.text5,'Enable','off');
       set(handles.edit2,'Enable','off');  
       cla(handles.axes2);
       cla(handles.axes3);
       imshow(Blank,'Parent',handles.axes2);
       imshow(Blank,'Parent',handles.axes3);
   end
   
end


% --- Executes on button press in Extractbutton.
function Extractbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Extractbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global working_dir image_name boundary_exist Pboundary_exist grey_image_org border 

temp_name=char(image_name);
dot_indices=regexp(temp_name,'\.');
backward_slashes_indices=regexp(working_dir,'\');
if (length(dot_indices)>2 && length(backward_slashes_indices)>2)
    link=fullfile('ftp://figment.csee.usf.edu/pub/DDSM/cases',working_dir(backward_slashes_indices(end-2)+1:end),[temp_name(1:dot_indices(2)) 'OVERLAY']);
    link = strrep(link, '\', '/');

    try
        if boundary_exist==0
            drawnow;
            txt=urlread(link);
            boundary_exist=1;
        end
    catch Exception

        if (strcmp(Exception.identifier,'MATLAB:urlread:UnknownHost'))
            d=errordlg('No internet connection','Error');
            uiwait(d);
        elseif(strcmp(Exception.identifier,'MATLAB:urlread:FileNotFound'))
            d=errordlg('Missing "Overlay" File','Error');
            uiwait(d);
        end
    end

    if boundary_exist ~= Pboundary_exist
       chaincode=Chaincode_Extract(txt);
       boundary=Boundary_Extract(chaincode);
       hold(handles.axes1,'on');
       plot(boundary(1,:),boundary(2,:),'b','LineWidth',2,'Parent',handles.axes1);
       hold(handles.axes1,'off');

       Pboundary_exist=boundary_exist;

       origin_size=size(grey_image_org);
       border=zeros(origin_size,'uint16');
       border(sub2ind(origin_size,boundary(2,:),boundary(1,:)))=65535;
       border=imfill(border);

        set(handles.Manualbutton,'Enable','on');
        set(handles.Manualbutton,'Value',1);
        Manualbutton_Callback(hObject, eventdata, handles);

    end

else
    d=errordlg('Error','Error');
    uiwait(d);
end

function chaincode=Chaincode_Extract(txt)
boundary_index= regexp(txt,'BOUNDARY');
sharp_index= regexp(txt,'#');
chaincode_string=regexp(txt(boundary_index(1)+9:sharp_index(1)-2),' ','split');
chaincode=cellfun(@str2num, chaincode_string(1:length(chaincode_string)));
chaincode=uint16(chaincode);
 
function boundary=Boundary_Extract(chaincode)
cc_x=chaincode(1);
cc_y=chaincode(2);

boundary=zeros(2,length(chaincode)-2);

position_x=cc_x;  
position_y=cc_y; 
for i=1:length(chaincode)-2
    switch chaincode(i+2)
        case 0 
            boundary(1,i)=position_x;
            boundary(2,i)=position_y-1;
        case 1 
            boundary(1,i)=position_x+1;
            boundary(2,i)=position_y-1;
        case 2 
            boundary(1,i)=position_x+1;
            boundary(2,i)=position_y;
        case 3 
            boundary(1,i)=position_x+1;
            boundary(2,i)=position_y+1;
        case 4
            boundary(1,i)=position_x;
            boundary(2,i)=position_y+1;
        case 5
            boundary(1,i)=position_x-1;
            boundary(2,i)=position_y+1;
        case 6 
            boundary(1,i)=position_x-1;
            boundary(2,i)=position_y;
        case 7 
            boundary(1,i)=position_x-1;
            boundary(2,i)=position_y-1;
    end
    position_x=boundary(1,i);
    position_y=boundary(2,i);
end


% --- Executes on button press in decreasebutton.
function Savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to decreasebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global content_list working_dir image_name resize grey_img_cut background

Image_Write(working_dir,image_name,resize,grey_img_cut,background);
[content_list.name,content_list.isdir]=Working_directory_Update(working_dir,handles); 

function Image_Write(working_dir,image_name,resize,grey_img_cut,background)
name = strcat('OD_',num2str(resize),'%_',image_name);
filename=char(fullfile(working_dir,name));
imwrite(grey_img_cut,filename,'Comment',num2str(background,'%.16e'));

% --- Executes on button press in Manualbutton.
function Manualbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Manualbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Manualbutton
global grey_image_org border resize grey_img_cut background

   set(handles.Savebutton,'Enable','on');
   set(handles.slider1,'Enable','on');
   set(handles.slider1, 'Value', 0);
   set(handles.text5,'Enable','on');
   set(handles.edit2,'Enable','inactive');
   slider_value=get(handles.slider1,'value');
   set(handles.edit2,'string',slider_value); 
   
   drawnow;
   
   resize=get(handles.slider1,'value');
   [background,grey_img_cut,OD_img_cut]=OD_Process(grey_image_org,border,resize);

   imshow(grey_img_cut,[],'Parent',handles.axes2);
   imshow(OD_img_cut,[],'Parent',handles.axes3);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global grey_image_org border resize grey_img_cut background

slider_value=get(handles.slider1,'value');
resize=5*(floor(slider_value/5)+ floor(mod(slider_value,5)/5+0.5));
set(handles.slider1,'Value',resize);
set(handles.edit2,'string',resize);

drawnow;

[background,grey_img_cut,OD_img_cut]=OD_Process(grey_image_org,border,resize);

imshow(grey_img_cut,[],'Parent',handles.axes2);
imshow(OD_img_cut,[],'Parent',handles.axes3);



function [background,grey_img_cut,OD_img_cut]=OD_Process(grey_image_org,border,resize)
ratio=(100-resize)/100;
grey_resized=imresize(grey_image_org,ratio,'bilinear');

border_resized=imresize(border,ratio,'bilinear');
border_resized=im2bw(border_resized,0.9);

C1_position=find(border_resized==1);

new_size=size(border_resized);
[row_indices,col_indices]=ind2sub(new_size,C1_position);
max_rows=max(row_indices);
min_rows=min(row_indices);
max_cols=max(col_indices);
min_cols=min(col_indices);
C_position=zeros((max_rows-min_rows+1)*(max_cols-min_cols+1),1);
k=1;
for i=min_rows:max_rows
    for j=min_cols:max_cols
       C_position(k)=(j-1)*new_size(1)+i;
       k=k+1;
    end
end

C0_position=setdiff(C_position,C1_position);

grey_img_cut=grey_resized(min_rows:max_rows,min_cols:max_cols);
background=mean(grey_resized(C0_position));
OD_img_cut=double(grey_img_cut)/background;
    
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Flnedit_Callback(hObject, eventdata, handles)
% hObject    handle to Flnedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Flnedit as text
%        str2double(get(hObject,'String')) returns contents of Flnedit as a double


% --- Executes during object creation, after setting all properties.
function Flnedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Flnedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Manualbutton.
function Manualbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Manualbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
