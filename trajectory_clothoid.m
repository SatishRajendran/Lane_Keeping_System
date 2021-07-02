% Datei:              clothoid.m
% Funktionsparameter: alpha: Abkuerzung: alpha = s^2 /( 2 * a^2 )
%                            mit s: Bogenlaenge
%                                a: Klothoidenparameter
%                     a:     Klothoidenparameter
% letzte Aenderung:   30. November 2011
% Beschreibung:       Berechnet die Trajektorienpunkte einer Klothoide
%                     Formel entnommen aus:
%                     Klemens Burg, Herbert Haf, Friedrich Wille:
%                     Vektoranalysis, Hoehere Mathematik fuer 
%                     Ingenieure, Naturwissenschaftler und Mathematiker
%                     Kapitel 1: Kurven
%                     ISBN-10 3-8351-0115-3
%                     ISBN-13 978-3-8351-0115-9

function result = clothoid(alpha, a)
    
    summe_x = 0;
    summe_y = 0;
    
    for count = 0:40
        summe_x = summe_x + ...
            (((-1)^count * alpha^(2*count))/((4*count+1) * factorial(2*count)));
        
        summe_y = summe_y + ...
            (((-1)^count * alpha^(2*count+1))/((4*count+3) * factorial(2*count+1)));
    end
    
    x = a * sqrt(2 * alpha) * summe_x;
    y = a * sqrt(2 * alpha) * summe_y;
    
    result = [x; y;];
    
% end of function clothoid
