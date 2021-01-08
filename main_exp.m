% stability=main_function_PID(qi, ui, Kp, Kd, plt, sv, ani)
%qi =[0 11 0.8 0.8 1.05];
%ui =[0 0 0 0 0];
if 0
    for th_0 = 1.135:0.005:1.15
        fprintf("\ntheta0 = %.4f  \n", th_0);
        for Kp = 600
            for Kd = 0:0.005:0.05
                qi =[0 11 0.8 0.8 th_0];
                main_function_PID(qi, ui, Kp, Kd, 0, 0, 0);
            end
        end
    end
end

if 0
    for th_0 = 0:0.1:1.2
        fprintf("\ntheta0 = %.4f  \n", th_0);
        qi =[0 11 0.8 0.8 th_0];
        main_function_PID(qi, ui, Kp, Kd, 0, 0, 0);
    end
end

if 0
    Kp_test = 100:100:10000;
    stab = zeros(size(Kp_test));
    for i = 1:length(Kp_test) %#ok<*UNRCH>
        Kp = Kp_test(i);
        for th_0 = 0:0.1:1.57
            fprintf("%.2f   ", th_0);
            qi =[0 11 0.8 0.8 th_0];
            ui =[0 0 0 0 0];
            stab(i) = stab(i) +  main_function_PID(qi, ui, Kp, 0, 0, 0, 0);
        end
    end
    [~, m] = max(stab);
    Kp_test(m)
    plot(Kp_test, stab);
end

if 1
    Kp = 1000;
    Kd_test = 0:0.01:1;
    % Kd : around
    stab_Kd = zeros(size(Kd_test));
    for i = 1:length(Kd_test)
        Kd = Kd_test(i);
        for th_0 = 0:0.1:1.57
            fprintf("%.2f   ", th_0);
            qi =[0 11 0.8 0.8 th_0];
            ui =[0 0 0 0 0];
            stab_Kd(i) = stab_Kd(i) + main_function_PID(qi, ui, Kp, Kd, 0, 0, 0); 
        end
        
    end
    figure;
    plot(Kd_test, stab_Kd);
    figure;
    stem(Kd_test, stab_Kd);
end

%{

theta0 = 1.20
Kp = 600 Kd = 0.0000 unstable
Kp = 600 Kd = 0.0050 unstable
Kp = 600 Kd = 0.0100 unstable
Kp = 600 Kd = 0.0150 unstable
Kp = 600 Kd = 0.0200 unstable
Kp = 600 Kd = 0.0250 unstable
Kp = 600 Kd = 0.0300 unstable
Kp = 600 Kd = 0.0350 stable
Kp = 600 Kd = 0.0400 stable
Kp = 600 Kd = 0.0450 stable
Kp = 600 Kd = 0.0500 unstable

theta0 = 1.25
Kp = 600 Kd = 0.0000 unstable
Operation terminated by user during main_function_PID (line 244)
for th_0 = 1.1:0.05:1.5
    fprintf("theta0 = %.1f  \n", th_0);
    for K = 600
        for z = [0,1]
            for p = [0,10]
                qi =[0 11 0.8 0.8 th_0];
                
                main_function_lead(qi, ui, K, z, p, 0, 0);
            end
        end
    end
end
%}