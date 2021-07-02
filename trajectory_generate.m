% Datei:              trajectory_generate.m
% Beschreibung:       Funktion zur Generierung der Bogenlaenge und
%                     der zugehoerigen X- und Y-Koordinaten der
%                     Fahrbahntrajektorie.
%
%                     Die in dieser Datei verwendeten Werte sind auf
%                     den Versuch Laengs- und Querregelung angepasst.
%                     Sie erzeugen die Daten für "Strecke 1".
% letzte Aenderung:   22. Mai 2019
% Funktionsparameter: -

function result = trajectory_generate()
    
    global S;                           % Streckenlaenge der Trajektorie gemessen
                                        %   ab dem Startpunkt der Trajektorie
    global Kappa;                       % Kruemmung der Trajektorie, Kappa = Kappa(s)
    global X_mitte;                     % X-Koordinate der Trajektorie, X = X(s)
    global Y_mitte;                     % Y-Koordinate der Trajektorie, Y = Y(s)
    global X_links;                     % Linker Fahrbahnrand, X(s)
    global Y_links;                     % Linker Fahrbahnrand, Y(s)
    global X_mitte_links;               % Mitte linker Fahrstreifen, X(s)
    global Y_mitte_links;               % Mitte rechter Fahrstreifen, Y(s)
    global X_rechts;                    % Rechter Fahrbahnrand, X(s)
    global Y_rechts;                    % Rechter Fahrbahnrand, Y(s)
    global X_mitte_rechts;              % Mitte rechter Fahrstreifen, X(s)
    global Y_mitte_rechts;              % Mitte rechter Fahrstreifen, Y(s)
    global strassendaten;               % Datenquelle: Objektdaten, aus denen
                                        %   die Trajektorie generiert wird
    
    
    % strassendaten = struct('typ',               {''}, ...
    %                        'begin',             {},   ...
    %                        'end',               {},   ...
    %                        'sbegin',            {},   ...
    %                        'send',              {},   ...
    %                        'kappabegin',        {},   ...
    %                        'kappaend',          {},   ...
    %                        'alphalbegin',       {},   ...
    %                        'alphalend',         {},   ...
    %                        'alphalmaxbegin',    {},   ...
    %                        'alphalmaxend',      {},   ...
    %                        'alphaqbegin',       {},   ...
    %                        'alphaqend',         {},   ...
    %                        'A',                 {},   ...
    %                        'R',                 {},   ...
    %                        'sbegin_no_br',      {},   ...
    %                        'sbegin_no_acc',     {},   ...
    %                        'send_no_br',        {},   ...
    %                        'send_no_acc',       {},   ...
    %                        'vv_max',            {},   ...
    %                        'est_sbegin_no_br',  {},   ...
    %                        'est_sbegin_no_acc', {},   ...
    %                        'est_send_no_br',    {},   ...
    %                        'est_send_no_acc',   {},   ...
    %                        'est_radius',        {},   ...
    %                        'est_vv_max',        {},   ...
    %                        'est_adjust_speed',  {},   ...
    %                        'adjust_a_brems_ci', {},   ...
    %                        'adjust_a_brems_co', {},   ...
    %                        'adjust_a_accel_ci', {},   ...
    %                        'adjust_a_accel_co', {},   ...
    %                        'adjust_speed',      {},   ...
    %                        'vorherige_kurve',   {},   ...
    %                        'naechste_kurve',    {},   ...
    %                        'profilnummer',      {},   ...
    %                        'profil_hauptindex', {},   ...
    %                        'profil_indexbegin', {},   ...
    %                        'profil_indexend',   {},   ...
    %                        'profil_sbegin',     {},   ...
    %                        'profil_send',       {});
    %                  
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
    
    
    %if ((nargin < 1) || (dist1 < 0)) dist1 = 0;          end
    %if ((nargin < 2) || (dist2 < 0)) dist2 = 0;          end 
    
    % Abstaende zwischen der ersten und der zweiten Kurve
    % auf ganzzahlinge Werte abrunden.
    %fdist1 = floor(dist1);
    %fdist2 = floor(dist2);    
    
    % Variablen auf null setzten und Laenge auf eins
    S = 0;
    Kappa = 0;
    X_mitte = 0;
    Y_mitte = 0;
    X_links = 0;
    Y_links = 0;
    X_rechts = 0;
    Y_rechts = 0;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Festzulegende Parameter (Anfang)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Halbe Fahrbahnbreite
    b_halbe = 3;
    
    % Geometrie 1: Gerade,      Orientierung phi1a, Laenge l1,
    %                           Startpunkt (x1_start, y1_start)
    phi1a = 0/180*pi;
    l1 = 350; 
    x1_start = 0; 
    y1_start = 3; 
    
    % Geometrie 2: Klothoide,   Laenge l2
    l2 = 20;
    
    % Geometrie 3: Kreisbogen,  Laenge l3, Radius R3
    l3 = 250;
    R3 = 100;
    
    % Geometrie 4: Klothoide,   Laenge l4
    l4 = l2;
    
    % Geometrie 5: Gerade,      Laenge l5
    l5 = 100;
    
    % Geometrie 6: Klothoide,   Laenge l6
    l6 = 20;
    
    % Geometrie 7: Kreisbogen,  Laenge l7, Radius R7
    l7 = 120;
    R7 = 70;
    
    % Geometrie 8: Klothoide,   Laenge l8
    l8 = l6;
    
    % Geometrie 9: Gerade,      Laenge l9
    l9 = 100;
    
    % Geometrie 10: Klothoide,  Laenge l6
    l10 = 100;
    
    % Geometrie 11: Kreisbogen, Laenge l11, Radius R11
    l11 = 80;
    R11 = 80;
    
    % Geometrie 12: Klothoide,  Laenge l12
    l12 = l10;
    
    % Geometrie 13: Gerade,     Laenge l13
    l13 = 300;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Festzulegende Parameter (Ende)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 1. Teil der Trajekorie ist eine Gerade
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    indexcount = 1;
    strassendaten_indexcount = 1;
    
    strassendaten(strassendaten_indexcount).typ = 'Ge';
    strassendaten(strassendaten_indexcount).kappabegin = 0;
    strassendaten(strassendaten_indexcount).kappaend = 0;
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
    
    for s = 0:l1
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = 0;
        X_mitte(1,indexcount) = x1_start + s * cos(phi1a);
        Y_mitte(1,indexcount) = y1_start + s * sin(phi1a);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi1a+pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi1a+pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi1a+pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi1a+pi/2);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi1a-pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi1a-pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi1a-pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi1a-pi/2);
        indexcount = indexcount + 1;
    end % for s = 0:l1-1
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    x1_ende = X_mitte(1,indexcount - 1);
    y1_ende = Y_mitte(1,indexcount - 1);
    phi1e = phi1a;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 2. Teil der Trajektrie ist eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi2a = phi1e;
    x2_start = x1_ende;
    y2_start = y1_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
    
    A2 = sqrt(l2*R3);
    phi2 = l2^2/(2*A2^2);
    
    x2_start_klothoide = x2_start;
    y2_start_klothoide = y2_start;
    
    for s = 1:l2
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = s/(A2^2);
        xy = trajectory_clothoid(s^2/(2*A2^2), A2);
        X_mitte(1,indexcount) = x2_start_klothoide + xy(1,1) * cos(phi2a) - xy(2,1) * sin(phi2a);
        Y_mitte(1,indexcount) = y2_start_klothoide + xy(1,1) * sin(phi2a) + xy(2,1) * cos(phi2a);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi2a+s^2/(2*A2^2)+pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi2a+s^2/(2*A2^2)+pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi2a+s^2/(2*A2^2)+pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi2a+s^2/(2*A2^2)+pi/2);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi2a+s^2/(2*A2^2)-pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi2a+s^2/(2*A2^2)-pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi2a+s^2/(2*A2^2)-pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi2a+s^2/(2*A2^2)-pi/2);
        
        indexcount = indexcount + 1;        
    end % for s = 0:l2
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = 0;
    strassendaten(strassendaten_indexcount).kappaend = 1/R3;
    strassendaten(strassendaten_indexcount).A = A2;
    
    phi2e = phi2a + phi2;
    x2_ende = X_mitte(1,indexcount - 1);
    y2_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 3. Teil der Trajekorie ist ein Kreisbogen
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi3a = phi2e;
    x3_start = x2_ende;
    y3_start = y2_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Ku';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;    
    
    % Mittelpunkt des Kreisbogens berechnen
    M3x = x3_start + R3 * cos(phi3a + pi/2);
    M3y = y3_start + R3 * sin(phi3a + pi/2);
    
    for s = phi3a-pi/2+1/R3:1/R3:(phi3a-pi/2) + l3/R3
        S(1, indexcount) = indexcount - 1;
        Kappa(1,indexcount) = 1/R3;
        X_mitte(1,indexcount) = M3x + R3 * cos(s);
        Y_mitte(1,indexcount) = M3y + R3 * sin(s);
        X_links(1,indexcount)  = M3x + (R3-b_halbe) * cos(s);
        Y_links(1,indexcount)  = M3y + (R3-b_halbe) * sin(s);
        X_mitte_links(1,indexcount)  = M3x + (R3-b_halbe/2) * cos(s);
        Y_mitte_links(1,indexcount)  = M3y + (R3-b_halbe/2) * sin(s);
        X_rechts(1,indexcount) = M3x + (R3+b_halbe) * cos(s);
        Y_rechts(1,indexcount) = M3y + (R3+b_halbe) * sin(s);
        X_mitte_rechts(1,indexcount) = M3x + (R3+b_halbe/2) * cos(s);
        Y_mitte_rechts(1,indexcount) = M3y + (R3+b_halbe/2) * sin(s);
        indexcount = indexcount + 1;
    end % for s = phi3a-pi/2:1/R3:(phi3a-pi/2) + l3/R3
    
    strassendaten(strassendaten_indexcount).send = indexcount - 2;
    strassendaten(strassendaten_indexcount).kappabegin = 1/R3;
    strassendaten(strassendaten_indexcount).kappaend = 1/R3;
    strassendaten(strassendaten_indexcount).R = R3;
    
    % Tangentenvektor am Ende des ersten Kreisbogens
    phi3e = phi3a + l3/R3;
    x3_ende = X_mitte(1,indexcount - 1);
    y3_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 4. Teil der Trajektorie ist eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi4a = phi3e;
    x4_start = x3_ende;
    y4_start = y3_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 2;
    
    A4 = sqrt (l4*R3);
    phi4 = l4^2/(2*A4^2);
    
    xy = trajectory_clothoid(l4^2/(2*A4^2), A4);
    klothoide_size_x = xy(1,1);
    klothoide_size_y = xy(2,1);
    
    x4_start_klothoide = x4_start + klothoide_size_x * cos(phi4a+phi4) + klothoide_size_y * sin(phi4a+phi4);
    y4_start_klothoide = y4_start + klothoide_size_x * sin(phi4a+phi4) - klothoide_size_y * cos(phi4a+phi4);
    
    for s = l4-1:-1:0
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = s/(A4^2);
        xy = trajectory_clothoid(s^2/(2*A4^2), A4);
        X_mitte(1,indexcount) = x4_start_klothoide + xy(1,1) * cos(phi4a+phi4-pi) + xy(2,1) * sin(phi4a+phi4-pi);
        Y_mitte(1,indexcount) = y4_start_klothoide + xy(1,1) * sin(phi4a+phi4-pi) - xy(2,1) * cos(phi4a+phi4-pi);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi4a+phi4-pi-s^2/(2*A4^2)+pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi4a+phi4-pi-s^2/(2*A4^2)+pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi4a+phi4-pi-s^2/(2*A4^2)+pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi4a+phi4-pi-s^2/(2*A4^2)+pi/2);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi4a+phi4-pi-s^2/(2*A4^2)-pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi4a+phi4-pi-s^2/(2*A4^2)-pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi4a+phi4-pi-s^2/(2*A4^2)-pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi4a+phi4-pi-s^2/(2*A4^2)-pi/2);
        indexcount = indexcount + 1;        
    end % for s = l4-1:-1:0
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = 1/R3;
    strassendaten(strassendaten_indexcount).kappaend = 0;
    strassendaten(strassendaten_indexcount).A = A4;
    
    phi4e = phi4a + phi4;
    x4_ende = X_mitte(1,indexcount - 1);
    y4_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 5. Teil der Trajektorie ist eine Gerade
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi5a = phi4e;
    x5_start = x4_ende;
    y5_start = y4_ende;
    
    if (l5 > 0)
        strassendaten_indexcount = strassendaten_indexcount + 1;
        strassendaten(strassendaten_indexcount).typ = 'Ge';
        strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
        
        for s = 1:l5
            S(1,indexcount) = indexcount - 1;
            Kappa(1,indexcount) = 0;
            X_mitte(1,indexcount) = x5_start + s * cos(phi5a);
            Y_mitte(1,indexcount) = y5_start + s * sin(phi5a);
            X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi5a+pi/2);
            Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi5a+pi/2);
            X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi5a+pi/2);
            Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi5a+pi/2);
            X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi5a-pi/2);
            Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi5a-pi/2);
            X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi5a-pi/2);
            Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi5a-pi/2);
            indexcount = indexcount + 1;
        end % for s = 0:l5
        
        strassendaten(strassendaten_indexcount).send = indexcount - 2;
        strassendaten(strassendaten_indexcount).kappabegin = 0;
        strassendaten(strassendaten_indexcount).kappaend = 0;
    end % if (l5 > 0)
    
    phi5e = phi5a;
    x5_ende = X_mitte(1,indexcount - 1);
    y5_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 6. Teil der Trajektorie ist eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi6a = phi5e;
    x6_start = x5_ende;
    y6_start = y5_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 2;
    
    A6 = sqrt(l6*R7);
    phi6 = l6^2/(2*A6^2);
    
    x6_start_klothoide = x6_start;
    y6_start_klothoide = y6_start;
    
    for s = 1:l6
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = -1 * s/(A6^2);
        xy = trajectory_clothoid(s^2/(2*A6^2), A6);
        X_mitte(1,indexcount) = x6_start_klothoide + xy(1,1) * cos(phi6a) + xy(2,1) * sin(phi6a);
        Y_mitte(1,indexcount) = y6_start_klothoide + xy(1,1) * sin(phi6a) - xy(2,1) * cos(phi6a);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi6a-s^2/(2*A6^2)+pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi6a-s^2/(2*A6^2)+pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi6a-s^2/(2*A6^2)+pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi6a-s^2/(2*A6^2)+pi/2);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi6a-s^2/(2*A6^2)-pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi6a-s^2/(2*A6^2)-pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi6a-s^2/(2*A6^2)-pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi6a-s^2/(2*A6^2)-pi/2);
        indexcount = indexcount + 1;
    end % for s = 1:l6

    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = 0;
    strassendaten(strassendaten_indexcount).kappaend = -1/R7;
    strassendaten(strassendaten_indexcount).A = A6;    
    
    phi6e = phi6a - phi6;
    x6_ende = X_mitte(1,indexcount - 1);
    y6_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 7. Teil der Trajekorie ist ein Kreisbogen
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi7a = phi6e;
    x7_start = x6_ende;
    y7_start = y6_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Ku';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
    
    % Mittelpunkt des Kreisbogens berechnen
    M7x = x7_start + R7 * cos(phi7a - pi/2);
    M7y = y7_start + R7 * sin(phi7a - pi/2);
    
    for s = phi7a+pi/2-1/R7:-1/R7:(phi7a+pi/2-1/R7) - (l7-1)/R7
        S(1, indexcount) = indexcount - 1;
        Kappa(1,indexcount) = -1/R7;
        X_mitte(1,indexcount) = M7x + R7 * cos(s);
        Y_mitte(1,indexcount) = M7y + R7 * sin(s);
        X_links(1,indexcount)  = M7x + (R7+b_halbe) * cos(s);
        Y_links(1,indexcount)  = M7y + (R7+b_halbe) * sin(s);
        X_mitte_links(1,indexcount)  = M7x + (R7+b_halbe/2) * cos(s);
        Y_mitte_links(1,indexcount)  = M7y + (R7+b_halbe/2) * sin(s);
        X_rechts(1,indexcount) = M7x + (R7-b_halbe) * cos(s);
        Y_rechts(1,indexcount) = M7y + (R7-b_halbe) * sin(s);
        X_mitte_rechts(1,indexcount) = M7x + (R7-b_halbe/2) * cos(s);
        Y_mitte_rechts(1,indexcount) = M7y + (R7-b_halbe/2) * sin(s);
        indexcount = indexcount + 1;
    end % for s = phi7a+pi/2+1/R7:-1/R7:(phi7a+pi/2+1/R7) - l7/R7
    
    strassendaten(strassendaten_indexcount).send = indexcount - 2;
    strassendaten(strassendaten_indexcount).kappabegin = -1/R7;
    strassendaten(strassendaten_indexcount).kappaend = -1/R7;
    strassendaten(strassendaten_indexcount).R = -R7;
    
    phi7e = phi7a - l7/R7;
    x7_ende = X_mitte(1,indexcount - 1);
    y7_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 8. Teil der Trajektorie ist eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi8a = phi7e;
    x8_start = x7_ende;
    y8_start = y7_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 2;
    
    A8 = sqrt(l8*R7);
    phi8 = l8^2/(2*A8^2);
    
    xy = trajectory_clothoid(l8^2/(2*A8^2), A8);
    klothoide_size_x = xy(1,1);
    klothoide_size_y = xy(2,1);
    
    x8_start_klothoide = x8_start + klothoide_size_x * cos(phi8a-phi8) - klothoide_size_y * sin(phi8a-phi8);
    y8_start_klothoide = y8_start + klothoide_size_x * sin(phi8a-phi8) + klothoide_size_y * cos(phi8a-phi8);
    
    for s = l8-1:-1:0
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = -1 * s/(A8^2);
        xy = trajectory_clothoid(s^2/(2*A8^2), A8);
        X_mitte(1,indexcount) = x8_start_klothoide + xy(1,1) * cos(phi8a-phi8-pi) - xy(2,1) * sin(phi8a-phi8-pi);
        Y_mitte(1,indexcount) = y8_start_klothoide + xy(1,1) * sin(phi8a-phi8-pi) + xy(2,1) * cos(phi8a-phi8-pi);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi8a-phi8-pi+s^2/(2*A8^2)+pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi8a-phi8-pi+s^2/(2*A8^2)+pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi8a-phi8-pi+s^2/(2*A8^2)+pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi8a-phi8-pi+s^2/(2*A8^2)+pi/2);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi8a-phi8-pi+s^2/(2*A8^2)-pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi8a-phi8-pi+s^2/(2*A8^2)-pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi8a-phi8-pi+s^2/(2*A8^2)-pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi8a-phi8-pi+s^2/(2*A8^2)-pi/2);
        indexcount = indexcount + 1;        
    end % for s = l8-1:-1:0
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = -1/R7;
    strassendaten(strassendaten_indexcount).kappaend = 0;
    strassendaten(strassendaten_indexcount).A = A8;
    
    phi8e = phi8a - phi8;
    x8_ende = X_mitte(1,indexcount - 1);
    y8_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 9. Teil der Trajektorie ist eine Gerade
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi9a = phi8e;
    x9_start = x8_ende;
    y9_start = y8_ende;
    
    if (l9 > 0)
        strassendaten_indexcount = strassendaten_indexcount + 1;
        strassendaten(strassendaten_indexcount).typ = 'Ge';
        strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
        
        for s = 1:l9
            S(1,indexcount) = indexcount - 1;
            Kappa(1,indexcount) = 0;
            X_mitte(1,indexcount) = x9_start + s * cos(phi9a);
            Y_mitte(1,indexcount) = y9_start + s * sin(phi9a);
            X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi9a+pi/2);
            Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi9a+pi/2);
            X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi9a+pi/2);
            Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi9a+pi/2);
            X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi9a-pi/2);
            Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi9a-pi/2);
            X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi9a-pi/2);
            Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi9a-pi/2);
            indexcount = indexcount + 1;
        end % for s = 0:l9
        
        strassendaten(strassendaten_indexcount).send = indexcount - 2;
        strassendaten(strassendaten_indexcount).kappabegin = 0;
        strassendaten(strassendaten_indexcount).kappaend = 0;
    end % if (l9 > 0)
    
    phi9e = phi9a;
    x9_ende = X_mitte(1,indexcount - 1);
    y9_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Teil 10 der Trajektorie ist wieder eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi10a = phi9e;
    x10_start = x9_ende;
    y10_start = y9_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
    
    A10 = sqrt(l10*R11);
    phi10 = l10^2/(2*A10^2);
    
    x10_start_klothoide = x10_start;
    y10_start_klothoide = y10_start;
    
    for s = 1:l10
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = s/(A10^2);
        xy = trajectory_clothoid(s^2/(2*A10^2), A10);
        X_mitte(1,indexcount) = x10_start_klothoide + xy(1,1) * cos(phi10a) - xy(2,1) * sin(phi10a);
        Y_mitte(1,indexcount) = y10_start_klothoide + xy(1,1) * sin(phi10a) + xy(2,1) * cos(phi10a);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi10a+s^2/(2*A10^2)+pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi10a+s^2/(2*A10^2)+pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi10a+s^2/(2*A10^2)+pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi10a+s^2/(2*A10^2)+pi/2);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi10a+s^2/(2*A10^2)-pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi10a+s^2/(2*A10^2)-pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi10a+s^2/(2*A10^2)-pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi10a+s^2/(2*A10^2)-pi/2);
        indexcount = indexcount + 1;        
    end % for s = 0:l10
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = 0;
    strassendaten(strassendaten_indexcount).kappaend = 1/R11;
    strassendaten(strassendaten_indexcount).A = A10;
    
    phi10e = phi10a + phi10;
    x10_ende = X_mitte(1,indexcount - 1);
    y10_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 11. Teil der Trajekorie ist ein Kreisbogen
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi11a = phi10e;
    x11_start = x10_ende;
    y11_start = y10_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Ku';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;    
    
    % Mittelpunkt des Kreisbogens berechnen
    M11x = x11_start + R11 * cos(phi11a + pi/2);
    M11y = y11_start + R11 * sin(phi11a + pi/2);
    
    for s = phi11a-pi/2+1/R11:1/R11:(phi11a-pi/2) + l11/R11
        S(1, indexcount) = indexcount - 1;
        Kappa(1,indexcount) = 1/R11;
        X_mitte(1,indexcount) = M11x + R11 * cos(s);
        Y_mitte(1,indexcount) = M11y + R11 * sin(s);
        X_rechts(1,indexcount) = M11x + (R11+b_halbe) * cos(s);
        Y_rechts(1,indexcount) = M11y + (R11+b_halbe) * sin(s);
        X_mitte_rechts(1,indexcount) = M11x + (R11+b_halbe/2) * cos(s);
        Y_mitte_rechts(1,indexcount) = M11y + (R11+b_halbe/2) * sin(s);
        X_links(1,indexcount)  = M11x + (R11-b_halbe) * cos(s);
        Y_links(1,indexcount)  = M11y + (R11-b_halbe) * sin(s);
        X_mitte_links(1,indexcount)  = M11x + (R11-b_halbe/2) * cos(s);
        Y_mitte_links(1,indexcount)  = M11y + (R11-b_halbe/2) * sin(s);
        indexcount = indexcount + 1;
    end % for s = phi11a-pi/2+1/R11:1/R11:(phi11a-pi/2) + l11/R11
    
    strassendaten(strassendaten_indexcount).send = indexcount - 2;
    strassendaten(strassendaten_indexcount).kappabegin = 1/R11;
    strassendaten(strassendaten_indexcount).kappaend = 1/R11;
    strassendaten(strassendaten_indexcount).R = R11;
    
    % Tangentenvektor am Ende des ersten Kreisbogens
    phi11e = phi11a + l11/R11;
    x11_ende = X_mitte(1,indexcount - 1);
    y11_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 12. Teil der Trajektorie ist eine Klothoide
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi12a = phi11e;
    x12_start = x11_ende;
    y12_start = y11_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Kl';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 2;
    
    A12 = sqrt (l12*R11);
    phi12 = l12^2/(2*A12^2);
    
    xy = trajectory_clothoid(l12^2/(2*A12^2), A12);
    klothoide_size_x = xy(1,1);
    klothoide_size_y = xy(2,1);
    
    x12_start_klothoide = x12_start + klothoide_size_x * cos(phi12a+phi12) + klothoide_size_y * sin(phi12a+phi12);
    y12_start_klothoide = y12_start + klothoide_size_x * sin(phi12a+phi12) - klothoide_size_y * cos(phi12a+phi12);
    
    for s = l12-1:-1:0
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = s/(A12^2);
        xy = trajectory_clothoid(s^2/(2*A12^2), A12);
        X_mitte(1,indexcount) = x12_start_klothoide + xy(1,1) * cos(phi12a+phi12-pi) + xy(2,1) * sin(phi12a+phi12-pi);
        Y_mitte(1,indexcount) = y12_start_klothoide + xy(1,1) * sin(phi12a+phi12-pi) - xy(2,1) * cos(phi12a+phi12-pi);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi12a+phi12-pi-s^2/(2*A12^2)+pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi12a+phi12-pi-s^2/(2*A12^2)+pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi12a+phi12-pi-s^2/(2*A12^2)+pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi12a+phi12-pi-s^2/(2*A12^2)+pi/2);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi12a+phi12-pi-s^2/(2*A12^2)-pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi12a+phi12-pi-s^2/(2*A12^2)-pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi12a+phi12-pi-s^2/(2*A12^2)-pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi12a+phi12-pi-s^2/(2*A12^2)-pi/2);
        
        indexcount = indexcount + 1;
    end % for s = l12-1:-1:0
    
    strassendaten(strassendaten_indexcount).send = indexcount - 1;
    strassendaten(strassendaten_indexcount).kappabegin = 1/R11;
    strassendaten(strassendaten_indexcount).kappaend = 0;
    strassendaten(strassendaten_indexcount).A = A12;
    
    phi12e = phi12a + phi12;
    x12_ende = X_mitte(1,indexcount - 1);
    y12_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Der 13. Teil der Trajektorie ist eine Gerade
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi13a = phi12e;
    x13_start = x12_ende;
    y13_start = y12_ende;
    
    strassendaten_indexcount = strassendaten_indexcount + 1;
    strassendaten(strassendaten_indexcount).typ = 'Ge';
    strassendaten(strassendaten_indexcount).sbegin = indexcount - 1;
    
    for s = 1:l13
        S(1,indexcount) = indexcount - 1;
        Kappa(1,indexcount) = 0;
        X_mitte(1,indexcount) = x13_start + s * cos(phi13a);
        Y_mitte(1,indexcount) = y13_start + s * sin(phi13a);
        X_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe * cos(phi13a+pi/2);
        Y_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe * sin(phi13a+pi/2);
        X_mitte_links(1,indexcount)  = X_mitte(1,indexcount) + b_halbe/2 * cos(phi13a+pi/2);
        Y_mitte_links(1,indexcount)  = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi13a+pi/2);
        X_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe * cos(phi13a-pi/2);
        Y_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe * sin(phi13a-pi/2);
        X_mitte_rechts(1,indexcount) = X_mitte(1,indexcount) + b_halbe/2 * cos(phi13a-pi/2);
        Y_mitte_rechts(1,indexcount) = Y_mitte(1,indexcount) + b_halbe/2 * sin(phi13a-pi/2);
        indexcount = indexcount + 1;
    end % for s = 1:l13
    
    strassendaten(strassendaten_indexcount).send = indexcount - 2;
    strassendaten(strassendaten_indexcount).kappabegin = 0;
    strassendaten(strassendaten_indexcount).kappaend = 0;
    
    phi13e = phi13a;
    x9_ende = X_mitte(1,indexcount - 1);
    y9_ende = Y_mitte(1,indexcount - 1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Ende der Strecke
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %disp('Distanzen:'); 
    %disp(l1);
    %disp(l1+l2);
    %disp(l1+l2+l3);
    %disp(l1+l2+l3+l4);
    %disp(l1+l2+l3+l4+l5);
    %disp(l1+l2+l3+l4+l5+l6);
    %disp(l1+l2+l3+l4+l5+l6+l7);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8+l9);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8+l9+l10);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8+l9+l10+l11);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8+l9+l10+l11+l12);
    %disp(l1+l2+l3+l4+l5+l6+l7+l8+l9+l10+l11+l12+l13);
    
    
% end of function generate_trajectory



