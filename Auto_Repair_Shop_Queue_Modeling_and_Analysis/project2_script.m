%This script takes us through the generation of project figures
%It calls the stochastic queueing model in simulation.m

%Do not debug
debug = 0;
debug_len = 40;

%Set Baseline Parameters
shop_size = 1; %The size of the shop determines the number of technicians. '1' represents an average shop.
ntechs = shop_size*2; %Number of technicians.  An average shop has 2 technicians.
time_step = 15; %Time step in minutes
mu_arr = 13*shop_size/12/60*time_step; %Arrival rate. For an average shop, it is 13 per day
p_oc = 3/13; %Probability that a customer is getting an oil change
tm = 2; %The customer tolerance multiplier.  Queue wait tolerance is (tolerance multiplier) X (service request time).
tms = 4; %The customer tolerance multiplier during a special.
oc_req = 15/time_step; %The number of time units an oil change takes, converted from 15 minutes.
mu_repair_req = 2.5*60/time_step; %The number of time units a repair takes, converted from 2.5 hours.
tspecial = 30/time_step; %The time limit for the oil change when the special is running, converted from 30 minutes.
oc_rev = 30; %The $ revenue per oil change
repair_rev_rate = 120/60*time_step; %The revenue per hour minus the cost of parts, equivalent to $120/hr.
labor_rate = 100/60*time_step; %The cost of labor per time step, equivalent to $100/hr.
days = 30;
tmax = days*12*60/time_step; %The total number of time steps in the experiment, converted from days.
t_inc = 12*60/time_step; %The time increment for making time plots on the scale of days.
% Model Type Parameters
exp_wait_on = 1;
limit_wait_on = 1;


%% Part 1  FIFO vs. Oil Changes First

%Show how wait time growth changes if oil changes are done first
reorder = 0;
special = 0;
track_wait = 1;
track_lost = 0;
track_profit = 0;
N = 10;
wait_vec1 = zeros(tmax,N);
for n = 1:N
[arrivals,wait,lost,idle,profit,wait_vec1(:,n),lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
    reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
    ntechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
end
wait_vec1 = mean(wait_vec1,2);
reorder = 1;
wait_vec2 = zeros(tmax,N);
for n = 1:N
    [arrivals,wait,lost,idle,profit,wait_vec2(:,n),lost_vec2,profit_vec2,ao,ar,po,pr,fo,lo,lr] = simulation(...
    reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
    ntechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
end
wait_vec2 = mean(wait_vec2,2);
plot((1:tmax)/(t_inc),(wait_vec1/t_inc),(1:tmax)/(t_inc),(wait_vec2/t_inc));
title('Wait Time Accumulation Over 100 Days'); xlabel('Time (Days)'); ylabel('Total Wait (Days)');
legend('FIFO System','Oil Changes First');
saveas(gcf, 'Wait_Accumulation_Ave_Shop.png'); 
close all;


%Show how lost customers growth changes if oil changes are done first
reorder = 0;
special = 0;
track_wait = 0;
track_lost = 1;
track_profit = 0;
N = 10;
lost_vec1 = zeros(tmax,N);
for n = 1:N
[arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1(:,n),profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
    reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
    ntechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
end
lost_vec1 = mean(lost_vec1,2);
reorder = 1;
lost_vec2 = zeros(tmax,N);
for n = 1:N
    [arrivals,wait,lost,idle,profit,wait_vec2,lost_vec2(:,n),profit_vec2,ao,ar,po,pr,fo,lo,lr] = simulation(...
    reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
    ntechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
end
lost_vec2 = mean(lost_vec2,2);
plot((1:tmax)/(t_inc),(lost_vec1/t_inc),(1:tmax)/(t_inc),(lost_vec2/t_inc));
title('Lost Customer Accumulation Over 100 Days'); xlabel('Time (Days)'); ylabel('Total Wait (Days)');
legend('FIFO System','Oil Changes First');
saveas(gcf, 'Wait_Accumulation_Ave_Shop.png'); 
close all;

track_wait = 0;
track_lost = 0;
track_profit = 0;

%Show wait time vs. number of technicians for average arrival rate (not scaled). Do FIFO vs. Oil Changes First.
special = 0;
shop_sizes = [0.5, 1, 1.5, 2]';
N = 100;
wait_means1 = zeros(length(shop_sizes),1);
wait_stds1 = zeros(length(shop_sizes),1);
wait_means2 = zeros(length(shop_sizes),1);
wait_stds2 = zeros(length(shop_sizes),1);
for i = 1:length(shop_sizes)
    ishop_size = shop_sizes(i);
    intechs = ishop_size*2;
    %First do FIFO
    reorder = 0;
    w = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        w(n) = wait;
    end
    wait_means1(i) = mean(w);
    wait_stds1(i) = std(w);
    %Then do reorder
    reorder = 1;
    w = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        w(n) = wait;
    end
    wait_means2(i) = mean(w);
    wait_stds2(i) = std(w);
end
errorbar([[shop_sizes*2-.03],[shop_sizes*2+.03]],[[wait_means1*time_step/60],[wait_means2*time_step/60]],[[wait_stds1*time_step/60],[wait_stds2*time_step/60]],'bx');
title(sprintf('Wait Times when Customer Tolerance is Limited\nRIGHT = FIFO        LEFT = Oil Changes First')); xlabel('# Technicians (arrivals rates NOT scaled)'); ylabel('Wait time (hrs)');
saveas(gcf, 'Wait_Times_by_ntechs_NOT_SCALED_with_CL.png'); 
close all;


%Show wait time vs. number of technicians for FIFO vs. Oil Changes First.
special = 0;
shop_sizes = [1:5]';
N = 100;
wait_means1 = zeros(length(shop_sizes),1);
wait_stds1 = zeros(length(shop_sizes),1);
wait_means2 = zeros(length(shop_sizes),1);
wait_stds2 = zeros(length(shop_sizes),1);
for i = 1:length(shop_sizes)
    ishop_size = shop_sizes(i);
    intechs = ishop_size*2;
    imu_arr = 13*ishop_size/12/60*time_step;
    %First do FIFO
    reorder = 0;
    w = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        w(n) = wait;
    end
    wait_means1(i) = mean(w);
    wait_stds1(i) = std(w);
    %Then do reorder
    reorder = 1;
    w = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        w(n) = wait;
    end
    wait_means2(i) = mean(w);
    wait_stds2(i) = std(w);
end
errorbar([[shop_sizes*2-.075],[shop_sizes*2+.075]],[[wait_means1*time_step/60],[wait_means2*time_step/60]],[[wait_stds1*time_step/60],[wait_stds2*time_step/60]],'bx');
title(sprintf('Wait Times vs. Number of Technicians\nRIGHT = FIFO        LEFT = Oil Changes First')); xlabel('# Technicians (with scaled arrivals rates)'); ylabel('Wait time (hrs)');
saveas(gcf, 'Wait_Times_by_ntechs.png'); 
close all;

Show customer retention vs. number of technicians for FIFO vs. Oil Changes First.
special = 0;
shop_sizes = [1:5]';
N = 100;
cr_means1 = zeros(length(shop_sizes),1);
cr_stds1 = zeros(length(shop_sizes),1);
cr_means2 = zeros(length(shop_sizes),1);
cr_stds2 = zeros(length(shop_sizes),1);
tm = 4;
for i = 1:length(shop_sizes)
    ishop_size = shop_sizes(i);
    intechs = ishop_size*2;
    imu_arr = 13*ishop_size/12/60*time_step;
    First do FIFO
    reorder = 0;
    cr = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        cr(n) = (arrivals - lost)/arrivals;
    end
    cr_means1(i) = mean(cr);
    cr_stds1(i) = std(cr);
    Then do reorder
    reorder = 1;
    cr = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            intechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        cr(n) = (arrivals - lost)/arrivals;
    end
    cr_means2(i) = mean(cr);
    cr_stds2(i) = std(cr);
end
errorbar([[shop_sizes*2-.075],[shop_sizes*2+.075]],[[cr_means1*100],[cr_means2*100]],[[cr_stds1*100],[cr_stds2*100]],'bx');
title(sprintf('Customer Retention vs. # Technicians when Customer Tolerance Multiplier = 4\nRIGHT = FIFO        LEFT = Oil Changes First')); xlabel('# Technicians (with scaled arrivals rates)'); ylabel('% Customer Retension');
saveas(gcf, 'Customer_Retention_by_ntechs_tm_4.png'); 
close all;

%Show customer retention (Overall, just OC, or just Repair) vs. tolerance for FIFO vs. Oil Changes First.
special = 0;
tmvec = [1:5]';
N = 100;
means1 = zeros(length(tmvec),1);
stds1 = zeros(length(tmvec),1);
means2 = zeros(length(tmvec),1);
stds2 = zeros(length(tmvec),1);
for i = 1:length(tmvec)
    itm = tmvec(i);
    %First do FIFO
    reorder = 0;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, mu_arr, p_oc, itm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = (ar - lr)/ar;
    end
    means1(i) = mean(nvec);
    stds1(i) = std(nvec);
    %Then do reorder
    reorder = 1;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, mu_arr, p_oc, itm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = (ar - lr)/ar;
    end
    means2(i) = mean(nvec);
    stds2(i) = std(nvec);
end
errorbar([tmvec-.05,tmvec+.05],[means1*100,means2*100],[stds1*100,stds2*100],'bx');
title(sprintf('Repair Customer Retention vs. Patience\nRIGHT = FIFO        LEFT = Oil Changes First')); 
xlabel('Tolerance Multiplier'); ylabel('% Customer Retension');
saveas(gcf, 'Repair_Customer_Retention_by_tolerance.png'); 
close all;


%Show customer retention vs. the arrival rate for FIFO vs. Oil Changes First.
special = 0;
mu_arr_vec = [0.5,1,2,3,4]'*13*shop_size/12/60*time_step;
N = 100;
means1 = zeros(length(mu_arr_vec),1);
stds1 = zeros(length(mu_arr_vec),1);
means2 = zeros(length(mu_arr_vec),1);
stds2 = zeros(length(mu_arr_vec),1);
tm = 4;
for i = 1:length(mu_arr_vec)
    imu_arr = mu_arr_vec(i);
    %First do FIFO
    reorder = 0;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = (arrivals - lost)/arrivals;
    end
    means1(i) = mean(nvec);
    stds1(i) = std(nvec);
    %Then do reorder
    reorder = 1;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = (arrivals - lost)/arrivals;
    end
    means2(i) = mean(nvec);
    stds2(i) = std(nvec);
end
errorbar([[[0.5,1,2,3,4]'*13-.5],[[0.5,1,2,3,4]'*13+.5]],[[means1*100],[means2*100]],[[stds1*100],[stds2*100]],'bx');
title(sprintf('Customer Retention vs. Arrival Rate at Tolerance Multiplier = 4\nRIGHT = FIFO        LEFT = Oil Changes First'));
xlabel('Arrival Rate (Customers per day)'); ylabel('% Customer Retension');
saveas(gcf, 'Customer_Retention_by_Arrival_Rate_tm_4.png'); 
close all;

%% Part 2  Special 30 minute Oil Change Offer

%Show Profit vs. the arrival rate for special vs. no special
reorder = 1;
mu_arr_vec = [0.5,1,2,3,4]'*13*shop_size/12/60*time_step;
N = 100;
means1 = zeros(length(mu_arr_vec),1);
stds1 = zeros(length(mu_arr_vec),1);
means2 = zeros(length(mu_arr_vec),1);
stds2 = zeros(length(mu_arr_vec),1);
for i = 1:length(mu_arr_vec)
    imu_arr = mu_arr_vec(i);
    %First do No Special
    special = 0;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = profit;
    end
    means1(i) = mean(nvec);
    stds1(i) = std(nvec);
    %Then do Special
    special = 1;
    nvec = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, imu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec(n) = profit;
    end
    means2(i) = mean(nvec);
    stds2(i) = std(nvec);
end
errorbar([[[0.5,1,2,3,4]'*13-.5],[[0.5,1,2,3,4]'*13+.5]],[[means1],[means2]],[[stds1],[stds2]],'bx');
title(sprintf('Profit with Oil Changes First\nRIGHT = Special 30 Minute Oil Change        LEFT = No Special Offer'));
xlabel('Arrival Rate (Customers per day)'); ylabel('Profit $');
saveas(gcf, 'Profit_OCF_S_NP_by_Arrival_Rate.png'); 
close all;


%Show customer retention vs. the tolerance multiplier for special vs. no special
reorder = 1;
tms_vec = [1,1.5,2,2.5,3,3.5,4]';
N = 100;
means1 = zeros(length(tms_vec),1);
stds1 = zeros(length(tms_vec),1);
means2 = zeros(length(tms_vec),1);
stds2 = zeros(length(tms_vec),1);
for i = 1:length(tms_vec)
    itms = tms_vec(i)*tm;
    special = 1; %At itms = 1, customer retention is identical to if there was no special.
    nvec1 = zeros(N,1);
    nvec2 = zeros(N,1);
    for n = 1:N
        [arrivals,wait,lost,idle,profit,wait_vec1,lost_vec1,profit_vec1,ao,ar,po,pr,fo,lo,lr] = simulation(...
            reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
            ntechs, mu_arr, p_oc, tm, itms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len);
        nvec1(n) = (ar-lr)/ar;
        nvec2(n) = (ao-lo)/ao;
    end
    means1(i) = mean(nvec1);
    stds1(i) = std(nvec1);
    means2(i) = mean(nvec2);
    stds2(i) = std(nvec2);
end
errorbar([[tms_vec],[tms_vec]],[[means1*100],[means2*100]],[[stds1*100],[stds2*100]],'b');
title(sprintf('Customer Retention during Special'));
xlabel('Special Tolerance Multiplier Relative to Standard Tolerance Multiplier'); ylabel('% Customer Retention');
legend(sprintf('UPPER: Repair Customers \n LOWER: Oil Change Customers'), 'Location', 'best');
saveas(gcf, 'Customer_Retention_by_tm2.png'); 
close all;