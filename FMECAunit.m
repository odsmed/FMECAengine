function num=FMECAunit(quantity,str,quantitychecked)
%FMECAUNIT converts a user string (to be used along with FMECAengine and OpenOffice/Calc) including number and unit into a number in SI units
%   syntax: num=FMECAunit(quantity,str)
%      quantity: type of quantity chosen among (note shorthands are possible, they are case sensitive)
%                'time' or 't'
%                'length' or 'l'
%                'area' or 'a'
%                'volume' or 'v' or 'vol'
%                'mass' or 'm'
%                'weightconcentration' or 'w' or 'weight'
%                'concentraion' or 'c' or 'conc'
%                'density' or 'd'
%                'Ctemperature' or 'C' or 'Ctemp' (attention: absolute scale temperature)
%                'Ktemperature' or 'K' or 'Ktemp' (attention: absolute scale temperature)
%       str: string or cell string array collecting a number and its unit
%           examples: '1 g/cm3', '1 d' (note that "^" symbol is not required)
%           Many units are recognized including 'day', 'month', 'd', 'jour', 'semaine', 'ppb', 'ppm'
%
%   See also: convertunit
%
%   EXAMPLES:
%{
      % time
        FMECAunit('t','10 mois')
        FMECAunit('t',{'10 mois' '1 we' '2 ans' '4 sem' '5 h' '10 min' '3s' '9 hours', '9 heures' '10 j o u r s'})
      % volume calculated from heterogenous
        FMECAunit('l','10 cm')*FMECAunit('l','8 mm')*FMECAunit('l','50 um')
      % length calculated from volume to surface area ratio
        FMECAunit('v','1.3 L')/FMECAunit('a','10 cm2')
      % mass
        FMECAunit('m','300 g')/FMECAunit('m','200 mg')
      % mass concentration
        FMECAunit('w',{'5e3 ppm' '0.15 ppb'})
      % volume concentration from mass concentration and density
        FMECAunit('w','500 ppm')*FMECAunit('d','1.4 g/cm3')
      % temperature scale
        FMECAunit('C','40�C')
        FMECAunit('K','40�C')
%}


% INRA\FMECAengine v 0.6 - 02/04/2015 - Olivier Vitrac - rev. 03/04/2015

% Revision history
% 03/04/2015 release candidate with examples
% 04/04/2015 add temperature and pressure, additional conversion of crazy notations from users



% Definition
anynumber = '[-+]?[0-9]*\.?[0-9]+([eEdD][-+]?[0-9]+)?';
unit2SI = struct(... % add concentration
    'time','s',...
    'length','m',...
    'area','m^2',...
    'volume','m^3',...
    'mass','kg',...
    'weightconcentration','kg/kg',...
    'concentration','kg/m^3',...
    'density','kg/m^3',...
    'Ctemperature','C',...
    'Ktemperature','K',...
    'Pressure','Pa' ...
);

% arg check
if nargin<2, error('two arguments are required'), end
if nargin<3, quantitychecked = false; end
if ~ischar(quantity), error('quantity must be a char'), end

% Quantity recognition
if quantitychecked
    q = quantity;
else
    nq = length(quantity);
    listofquantities = fieldnames(unit2SI);
    iq = cellfun(@(u) ~isempty(regexp(quantity,sprintf('^%s',u(1:min(length(u),nq))), 'once')),listofquantities);
    if ~any(iq), error('unable to recognize the quantity [type] ''%s'' for number ''%s''',quantity,str), end
    q = listofquantities{iq};
end
istemperature = ~isempty(regexp(q,'.temperature$','once'));

% Recursion if needed
if iscellstr(str)
    nstr = numel(str); num = zeros(size(str));
    for i=1:nstr
        num(i) = FMECAunit(quantity,str{i});
    end
    return
elseif ~ischar(str)
    error('str must be a char');
end

% Additional definitions (defined only after recursion)
% ==> to enable many notations used by end users even if they are not not standard
synonyms = struct(...
    'time',{{ 
             '^an\w*'    ,'year'
             '^y\w*'      ,'year'
              '^m\w*'     ,'month'
              '^sem\w*'   ,'week'
              '^w\w*'     ,'week'              
              '^d$'       ,'day'
              '^j$'       ,'day'
              '^jour\w*'  ,'day'
              '^h$'       ,'hour'
              '^ho$'      ,'hour'
              '^heu\w*$'  ,'hour'
              '^m$'       ,'min'
              '^mn$'      ,'min'
              '^sec$'     ,'s'}},...
    'length',{{'�' 'u'
               'K' 'k'}},...
    'area',{{ 'm2'      ,'m^2'}},...
    'volume',{{ 'm3'    ,'m^3'
                'l'     ,'L'}},...,...
    'mass',{{'^t\w*' 'T'
              '�'    'u'
              'K'    'k'}},...
    'weightconcentration',{{'�'   'u'
                            'ppm' 'mg/kg'
                            'ppb' 'ug/kg'  }},...
    'concentration',{{ 'm3'    ,'m^3'
                       'l'     ,'L'
                       '�'     ,'u'}},...
    'density',{{ 'm3'    ,'m^3'
                 'l'     ,'L'
                 '�'     ,'u'}}, ...
    'Ctemperature',{{ 'c'    , 'C'
                      'k'    , 'K'
                      'degC' , 'C'
                      'degK' , 'K'
                      '�'    ,''
                      'Celsius' 'C'
                      'Kelvin'  'K'
                      }},...
    'Ktemperature',{{ 'k'    , 'K'
                      'c'    , 'C'
                      'degK'   'K'
                      'degC' , 'C'
                      '�'    ,''
                      'Kelvin' 'K'
                      'Celsius' 'C'
                      }}, ...
    'Pressure',{cell(0,2)} ...
);

% string interpretation
uSI = unit2SI.(q);
tmp = uncell(regexp(strtrim(str),sprintf('^(%s)(.*)$',anynumber),'tokens'));
n   = strtrim(tmp{1}); % literal number
u   = regexprep(tmp{2},'\s',''); % literal unit
if isempty(n), error('no number recognized in ''%s''',str), end
if isempty(u)
    dispf('WARNING: no unit provided for number ''%s'', the SI unit of ''%s'' is used (''%s'') instead',n,quantity,uSI)
    num = str2double(n);
else
    if length(u)>1, u = regexprep(u,'s$',''); end % to add d, h,
    if ~isempty(synonyms.(q))
        u = regexprep(u,synonyms.(q)(:,1),synonyms.(q)(:,2));
    end
    try
        if istemperature 
            num = convertunit(u,uSI,str2double(n),'abstemp');
        else
            num = convertunit(u,uSI,str2double(n));
        end
    catch cunit
        dispf('ERROR in ''%s/%s'' at line %d',cunit.stack(2).name,cunit.stack(1).name,cunit.stack(1).line)
        dispf('ERROR FEMCAunit\n\tunable to interpret the string ''%s'' as ''%s'' quantity\n\ttranslated as number=''%s'', unit=''%s'' (SI=''%s'')\n',str,q,n,u,uSI)
        error('please check the input ''%s: %s''',q,str)
    end
end