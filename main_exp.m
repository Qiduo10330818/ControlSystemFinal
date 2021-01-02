qi =[0 11 0.8 0.8 1.1];
ui =[0 0 0 0 0];
for Kp = 10000
    for Kd = 0 
        main_function(qi, ui, Kp, Kd, 1);
    end
end