function varargout = S2MT_G(varargin)
% S2MT_G MATLAB code for S2MT_G.fig
%      S2MT_G, by itself, creates a new S2MT_G or raises the existing
%      singleton*.
%
%      H = S2MT_G returns the handle to a new S2MT_G or the handle to
%      the existing singleton*.
%
%      S2MT_G('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in S2MT_G.M with the given input arguments.
%
%      S2MT_G('Property','Value',...) creates a new S2MT_G or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before S2MT_G_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to S2MT_G_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help S2MT_G

% Last Modified by GUIDE v2.5 24-Sep-2012 23:22:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @S2MT_G_OpeningFcn, ...
                   'gui_OutputFcn',  @S2MT_G_OutputFcn, ...
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


% --- Executes just before S2MT_G is made visible.
function S2MT_G_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to S2MT_G (see VARARGIN)

% Choose default command line output for S2MT_G
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes S2MT_G wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = S2MT_G_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function str_Callback(hObject, eventdata, handles)
% hObject    handle to str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of str as text
%        str2double(get(hObject,'String')) returns contents of str as a double


% --- Executes during object creation, after setting all properties.
function str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [Log, PrimerSequence] = S2MT(get(handles.str, 'String'), feval(@(x) x{1}{x{2}}, get(handles.std,{'String','Value'})));
    set(handles.Log, 'String', Log);
    set(handles.Primer, 'String', PrimerSequence);

% --- Executes on selection change in std.
function std_Callback(hObject, eventdata, handles)
% hObject    handle to std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns std contents as cell array
%        contents{get(hObject,'Value')} returns selected item from std


% --- Executes during object creation, after setting all properties.
function std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Primer_Callback(hObject, eventdata, handles)
% hObject    handle to Primer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Primer as text
%        str2double(get(hObject,'String')) returns contents of Primer as a double


% --- Executes during object creation, after setting all properties.
function Primer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Primer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
