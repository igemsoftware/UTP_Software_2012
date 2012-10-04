function varargout = Biosinergy(varargin)
% BIOSINERGY MATLAB code for Biosinergy.fig
%      BIOSINERGY, by itself, creates a new BIOSINERGY or raises the existing
%      singleton*.
%
%      H = BIOSINERGY returns the handle to a new BIOSINERGY or the handle to
%      the existing singleton*.
%
%      BIOSINERGY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIOSINERGY.M with the given input arguments.
%
%      BIOSINERGY('Property','Value',...) creates a new BIOSINERGY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Biosinergy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Biosinergy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Biosinergy

% Last Modified by GUIDE v2.5 04-Oct-2012 15:30:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Biosinergy_OpeningFcn, ...
                   'gui_OutputFcn',  @Biosinergy_OutputFcn, ...
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


% --- Executes just before Biosinergy is made visible.
function Biosinergy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Biosinergy (see VARARGIN)

% Basic database
handles.biobricks = [398011, 590032, 590031, 590054, 348000, 778001, 778007, 558001, 558007, 273012, 273016];
handles.routes = {'under research', 'under research', 'under research', 'under research', 'Glycolisys', 'under research', ...
    'under research', 'Pyruvate Decarboxylase', 'fatty acid synthesis cycle', 'glycolysis', 'under research'};
handles.mapbbroutes = containers.Map(handles.biobricks, handles.routes);
handles.bioenergylist = {'Alkane', 'Fatty Aldehydes', 'Alkane Biodiesel', 'Alkane', 'Hidrogen', 'Hidrogen', 'Hidrogen', 'Ethanol', 'Fatty Acids', ...
    'Butanol', 'Ethanol'}
handles.substrateslist = {'Alkanes', 'Sugars', 'Fatty Aldehydes', 'Sugars', 'Glucose', 'Glucose', 'Glucose', 'Glucose', 'Glucose', ...
    'Glucose', 'Glucose'};

% Choose default command line output for Biosinergy
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Biosinergy wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Biosinergy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in search.
function search_Callback(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx_subst = find(ismember(handles.substrateslist, get(handles.substrates,'String')) == 1);
idx_energy = find(ismember(handles.substrateslist, get(handles.bioenergies, 'String')) == 1);
saveidx = 0;
for i = 1:length(idx_energy)
    equalidx = find(idx_subst == idx_energy(i));
    if ~isempty(equalidx)
        saveidx = [saveidx, idx_energy(i)];
    end
end
saveidx = saveidx(2:end);
biotext = '';
route = '';
for i = 1:length(saveidx)
    var1 = num2str( handles.biobricks(saveidx(i)));
    var2 = num2str( handles.mapbbroutes(handles.biobricks(saveidx(i))));
    biotext  = strcat(biotext, ' BBa_K', var1, ',');
    route  = strcat(route, ' BBa_K', var2, ',');
end

set(handles.biobricks, 'string', biotext);
set(handles.pathways, 'String', route);

function biobricks_Callback(hObject, eventdata, handles)
% hObject    handle to biobricks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of biobricks as text
%        str2double(get(hObject,'String')) returns contents of biobricks as a double


% --- Executes during object creation, after setting all properties.
function biobricks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to biobricks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pathways_Callback(hObject, eventdata, handles)
% hObject    handle to pathways (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathways as text
%        str2double(get(hObject,'String')) returns contents of pathways as a double


% --- Executes during object creation, after setting all properties.
function pathways_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathways (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bioenergies.
function bioenergies_Callback(hObject, eventdata, handles)
% hObject    handle to bioenergies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bioenergies contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bioenergies


% --- Executes during object creation, after setting all properties.
function bioenergies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bioenergies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in substrates.
function substrates_Callback(hObject, eventdata, handles)
% hObject    handle to substrates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns substrates contents as cell array
%        contents{get(hObject,'Value')} returns selected item from substrates


% --- Executes during object creation, after setting all properties.
function substrates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to substrates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
