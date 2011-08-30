function D=Dpiringer(polymer,M,T)
% Dpiringer returns the Piringer's overestimate of diffusion coefficients
%   syntax: D=Dpiringer(polymer,M,T)
%       polymer = 'LDPE'    'LLDPE'    'HDPE'    'PP'    'PPrubber'    'PS'    'HIPS'    'PET'    'PBT'    'PEN'    'PA'    'PVC'
%       M = molecular mass
%       T = temperature in �C (default = 40�C)

% Migration 2.0 - 07/05/2011 - INRA\Olivier Vitrac - rev. 22/08/11

%Revision history
%25/07/11 add recursion
%22/08/11 remove upper(polymer), add Migresives data
%30/08/11 chnage names for cardbox


% definitions
data = struct(...
'LDPE'              , struct('App',11.5,'tau',0),...
'LLDPE'             , struct('App',11.5,'tau',0),...
'HDPE'              , struct('App',14.5,'tau',1577),...
'PP'                , struct('App',13.1,'tau',1577),...
'PPrubber'          , struct('App',11.5,'tau',0),...
'PS'                , struct('App',0   ,'tau',0),...
'HIPS'              , struct('App',1   ,'tau',0),...
'PET'               , struct('App',6   ,'tau',1577),...
'PBT'               , struct('App',6.5 ,'tau',1577),...
'PEN'               , struct('App',5   ,'tau',1577),...
'PA'                , struct('App',2   ,'tau',0),...
'PVC'               , struct('App',0   ,'tau',0),...
'AdhesiveNaturalRubber'  , struct('App',11.3,'tau',-421),...
'AdhesiveSyntheticRubber', struct('App',11.3,'tau',-421),...
'AdhesiveEVA'            , struct('App',6.6 ,'tau',-1270),...
'AdhesiveVAE'            , struct('App',6.6 ,'tau',-1270),...
'AdhesivePVAC'           , struct('App',6.6 ,'tau',-1270),...
'AdhesiveAcrylate'       , struct('App',4.5 ,'tau',83),...
'AdhesivePU'            , struct('App',4   ,'tau',250),...
'Paper'          , struct('App',6.6 ,'tau',-1900),...
'Cardboard_polarmigrant'      , struct('App',4   ,'tau',-1511),... polar substances
'Cardboard_apolarmigrant'   , struct('App',7.4 ,'tau',-1511) ... hydrophobic substances
    );

% arg check
if nargin<1, error('one argument is at least required'); end
if nargin<2, M = 100; end
if nargin<3, T = 40; end

% recursion
if iscell(polymer)
    D = [];
    for ip = 1:numel(polymer)
        Dtmp = Dpiringer(polymer{ip},M,T);
        D = [D;Dtmp(:)]; %#ok<AGROW>
    end
    return
end

% type control
if ischar(M), tmp = M; M=polymer; polymer = tmp; end
if ~ischar(polymer), error('polymer must a string or cell array of strings'), end

%polymer = upper(polymer); % removed  22/08/11
TK      = T+273.25;
Ap      = data.(polymer).App - data.(polymer).tau./TK;
D       = exp(Ap-0.135*M.^(2/3)+0.003*M-10454./TK); % m2.s-1
