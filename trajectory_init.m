% Datei:              trajectory_init.m
% Funktionsparameter: keine
% letzte Aenderung:   22. Mai 2019
% Beschreibung:       Anlegen und Initialisieren von globalen Variablen

%clear;                                  % MATLAB workspace loeschen

global S;                               % Streckenlaenge der Trajektorie gemessen
                                        %   ab dem Startpunkt der Trajektorie
global Kappa;                           % Kruemmung der Trajektorie, Kappa = Kappa(s)
global X_mitte;                         % X-Koordinate der Trajektorie,
                                        % Fahrbahnmitte, X = X(s)
global Y_mitte;                         % Y-Koordinate der Trajektorie,
                                        % Fahrbahnmitte, Y = Y(s)
global X_mitte_links;                   % Mitte linker Fahrstreifen, X(s)
global Y_mitte_links;                   % Mitte rechter Fahrstreifen, Y(s)
global X_links;                         % Linker Fahrbahnrand, X(s)
global Y_links;                         % Linker Fahrbahnrand, Y(s)
global X_mitte_rechts;                  % Mitte rechter Fahrstreifen, X(s)
global Y_mitte_rechts;                  % Mitte rechter Fahrstreifen, Y(s)
global X_rechts;                        % Rechter Fahrbahnrand, X(s)
global Y_rechts;                        % Rechter Fahrbahnrand, Y(s)
global strassendaten;                   % Datenquelle: Objektdaten, aus denen
                                        %   die Trajektorie generiert wird
global k_x;                             % Gewichtungsfaktoren fuer Laengs- (k_x) und 
global k_y;                             %   und Querbeschleunigung (k_y)

global speed_profile;               	% Geschwindigkeitsprofil als Funktion
										%   des Weges
global reference_value;					% Sollwert fuer die Geschwindigkeit zur
										%   Regelung der Fahrzuggeschwindigkeit
                            

strassendaten = struct('typ',               {''}, ...
                       'begin',             {},   ...
                       'end',               {},   ...
                       'sbegin',            {},   ...
                       'send',              {},   ...
                       'kappabegin',        {},   ...
                       'kappaend',          {},   ...
                       'alphalbegin',       {},   ...
                       'alphalend',         {},   ...
                       'alphalmaxbegin',    {},   ...
                       'alphalmaxend',      {},   ...
                       'alphaqbegin',       {},   ...
                       'alphaqend',         {},   ...
                       'A',                 {},   ...
                       'R',                 {},   ...
                       'sbegin_no_br',      {},   ...
                       'sbegin_no_acc',     {},   ...
                       'send_no_br',        {},   ...
                       'send_no_acc',       {},   ...
                       'vv_max',            {},   ...
                       'est_sbegin_no_br',  {},   ...
                       'est_sbegin_no_acc', {},   ...
                       'est_send_no_br',    {},   ...
                       'est_send_no_acc',   {},   ...
                       'est_radius',        {},   ...
                       'est_vv_max',        {},   ...
                       'est_adjust_speed',  {},   ...
                       'adjust_a_brems_ci', {},   ...
                       'adjust_a_brems_co', {},   ...
                       'adjust_a_accel_ci', {},   ...
                       'adjust_a_accel_co', {},   ...
                       'adjust_speed',      {},   ...
                       'vorherige_kurve',   {},   ...
                       'naechste_kurve',    {},   ...
                       'profilnummer',      {},   ...
                       'profil_hauptindex', {},   ...
                       'profil_indexbegin', {},   ...
                       'profil_indexend',   {},   ...
                       'profil_sbegin',     {},   ...
                       'profil_send',       {});
                  
% strassendaten ist ein Array von Typ struct mit den Feldern
% - typ               -> Zeichenkette, Typ des Streckenabschnitts:
%                        Ge = Gerade, Kl = Klothoide, Ku = Kurve
% - begin             -> Index: Beginn des Streckenabschnitts
% - end               -> Index: Ende des Streckenabschnitts
% - sbegin            -> Streckenparameter S: Beginn des Streckenabschnitts
% - send              -> Streckenparameter S: Ende des Streckenabschnitts
% - kappabegin        -> Parameter Kappa fuer sbegin
% - kappaend          -> Parameter Kappa fuer send
% - alphalbegin       -> Parameter Alpha_L fuer sbegin
% - alphalend         -> Parameter Alpha_L fuer send
% - alphalmaxbegin    -> Maximumwert fuer Alpha_L im Bremsbereich vor der Kurve
% - alphalmaxend      -> Maximumwert fuer Alpha_L im Beschleunigungsbereich
%                        nach der Kurve
% - alphaqbegin       -> Parameter Alpha_Q fuer sbegin
% - alphaqend         -> Parameter Alpha_Q fuer send
% - A                 -> Klothoidenparameter A fuer den Streckentyp 'Kl'
% - R                 -> Kurvenradius R fuer den Streckentyp 'Ku'
% - sbegin_no_br      -> Geschwindigkeitsprofil: Wegpunkt, ab dem
%                        nicht mehr gebremst werden darf
% - sbegin_no_acc     -> Geschwindigkeitsprofil: Wegpunkt, ab dem
%                        nicht mehr beschleunigt werden darf
% - send_no_br        -> Geschwindigkeitsprofil: Wegpunkt, ab dem
%                        wieder gebremst werden darf
% - send_no_acc       -> Geschwindigkeitsprofil: Wegpunkt, ab dem
%                        wieder beschleunigt werden darf
% - vv_max            -> Quadrat der maximalen Geschwindigkeit in der Kurve,
%                        mit der die maximale Beschleunigung eingehalten wird.
%                        KEINE Beschleunigung / Verzoegerung
% - est_sbegin_no_br  -> Naeherungswert fuer sbegin_no_br (ebener Fall)
% - est_sbegin_no_acc -> Naeherungswert fuer sbegin_no_acc (ebener Fall)
% - est_send_no_br    -> Naeherungswert fuer send_no_br (ebener Fall)
% - est_send_no_acc   -> Naeherungswert fuer send_no_acc (ebener Fall)
% - est_radius        -> Naeherungswert fuer den Radius (ebener Fall)
% - est_vv_max        -> Naeherungswert fuer vv_max (ebener Fall)
% - est_adjust_speed  -> Naeherungswert reduzierte Geschwindigkeit
% - adjust_a_brems_ci -> Angepasste Beschleunigung beim Bremsen
%                        Kurveneinfahrt
% - adjust_a_brems_co -> Angepasste Beschleunigung beim Bremsen
%                        Kurvenausfahrt
% - adjust_a_accel_ci -> Angepasste Beschleunigung beim Beschleunigen
%                        Kurveneinfahrt
% - adjust_a_accel_co -> Angepasste Beschleunigung beim Beschleunigen
%                        Kurvenausfahrt
% - adjust_speed      -> Auf diese Geschwindigkeit muss reduziert werden, 
%                        damit die folgende Kurve problemlos durchfahren
%                        werden kann.
% - vorherige_kurve   -> Geschwindigkeitsbeeinflussung der aktuellen Kurve auf
%                        die vorherige Kurve ueberprueft ja(1)/nein(0)
% - naechste_kurve    -> Geschwindigkeitsbeeinflussung der aktuellen Kurve auf
%                        die naechste Kurve ueberprueft ja(1)/nein(0)                                        
% - profilnummer      -> Nummer des Profils, zu dem die jeweilige Geometrie
%                        gehoert. 
% - profil_hauptindex -> In diesem Struct sind alle fuer das Profil benoetigten
%                        Daten gespeichert
% - profil_indexbegin -> Ab diesem Datensatz gehoeren alle Datensaetze
%                        dieses Struct zum aktuellen Profil
% - profil_indexend   -> Bis zu diesem Datensatz gehoeren alle Datensaetze
%                        dieses Struct zum aktuellen Profil
% - profil_sbegin     -> Wegpunkt, ab dem die Strecke fuer das aktuelle Profil
%                        betrachtet werden muss
% - profil_send       -> Wegpunkt, bis zu dem die Strecke fuer das aktuelle Profil
%                        betrachtet werden muss

S = 0;
Kappa = 0;
X = 0;
Y = 0;
X_links = 0;
Y_links = 0;
X_rechts = 0;
Y_rechts = 0;

k_x = 1;
k_y = 1;

speed_profile = 0;
reference_value = 0;

