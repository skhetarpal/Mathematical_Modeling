function [arrivals,wait,lost,idle,profit,wait_vec,lost_vec,profit_vec,ao,ar,po,pr,fo,lo,lr] = simulation(...
    reorder, special, exp_wait_on, limit_wait_on, track_wait, track_lost, track_profit,...
    ntechs, mu_arr, p_oc, tm, tms, oc_req, mu_repair_req, tspecial, tmax, oc_rev, repair_rev_rate, labor_rate, debug, debug_len)
%Referenced multiserversingleq.m

%This function models an auto repair shop receives customers for either oil 
%   changes (short service), or repair work (longer service).
%Poisson arrivals each time step with mean 'mu_arr'.
%The service request for an oil change is 'oc_req', which is the time step equivalent of 15 minutes.
%The service request for repairs (a range of services) has a Poisson service request with mean mu_repair_req.
%If 'reorder' is '0', all customers are put at the end of the queue.
%If 'reorder' is '1', oil change customers are put at the front of the queue
%   behind any other oil change customers already waiting.
%The simulation proceeds for tmax time steps
%The #arrivals, average wait, and #arrivals lost are returned as observations of performance
%The data structure for arrivals is [arrival time, service type, service requested, tolerance].
%The data structure for a tech is a scalar, #time steps
%remaining to serve current customer, 0 means without customer.
%If exp_wait_on is '1', then arrivals turn away and are lost if
%   the expected queue wait time exceeds the customer tolerance.
%If wait_limit_on is '1', then when customers who wait longer than 'tolerance'
%   in the queue, they leave and are lost.
%The function includes a 'debug' option which will print out a snapshot of the system for the first 50
%   time steps.  It is to verify functionality.


%Initialize Variables
arrivals=0; %Number of customers that have arrived
lost=0; %Number of customers that are lost
idle=0; %Number of hours techs spent spent idle
if track_lost %Initialize a vector to track lost
    lost_vec = zeros(tmax,1);
else lost_vec = [];
end
wait=0; %Total queue wait time from all customers
if track_wait %Initialize a vector to track wait
    wait_vec = zeros(tmax,1);
else wait_vec = [];
end
profit = 0; %Initialize the profit
if track_profit %Initialize a vector to track wait
    profit_vec = zeros(tmax,1);
else profit_vec = [];
end
ao = 0; %# arrived oil change customers
ar = 0; %# arrived repair customers
po = 0; %# paid oil change customers
pr = 0; %# paid repair customers
fo = 0; %# free oil change customers
lo = 0; %# lost oil change customers
lr = 0; %# lost repair customers

techs=zeros(ntechs,1);  %Initialize all techs to be free to start
q = []; %Initialize the customer queue

%Run Simulation
for t=1:tmax
    
    %Customers arrive
    narrivals=Pvar(mu_arr); %Poisson arrivals
    arrivals=arrivals+narrivals; %Increment arrivals
    
    %Print snapshot of system for debugging
    if debug && t<debug_len;fprintf('techs: ');for n = 1:ntechs;fprintf('%d,', techs(n));end;fprintf('    t%d  Arrivals: %d',t,narrivals);end;
    
    %Loop through arrivals, put them into the queue
    for i=1:narrivals
        
        %Generate a random number to determine the service type (oil change vs. repair)
        service_type = rand;
        %Determine the service request length based on the service type
        if service_type < p_oc
            oc = 1; %It is an oil change customer
            req = oc_req; %oil change service request length
            ao = ao + 1;
        else
            oc = 0; %It is not an oil change customer
            req = Pvar(mu_repair_req); %repair service request length
            ar = ar + 1;
        end
        
        %Determine the customer's queue wait time tolerance
        if tm %If using the tolerance multiplier
            if ~special
                tol = req * tm; %Calculate tolerance using the standard service request multiplier
            else %A special is running!
                if oc
                    tol = req * tms; %During a special, oil change customers have a higher multiplier
                else
                    tol = req * tm;
                end
            end
        else
            tol = mu_repair_req * 1.5; %Else, set one limit for everyone
        end
        
        %Count the number of oil change customers in the queue.
        if oc == 1; noc = count_noc(q); else noc = []; end;
        
        %Assign customer to appropriate queue.  Method depends on whether
        %    the model includes expected queue wait times.
        if exp_wait_on %If the model features expected queue wait times, calculate wait and apply tolerance.
            exp_wait = calc_exp_wait(reorder, q, oc, noc, techs, ntechs, mu_repair_req);
            if exp_wait > tol
                lost=lost+1;  %If the expected queue wait time is too high, customer is lost
                if oc; lo = lo + 1; else lr = lr + 1; end; %Track what type of customer was lost.
            end
        end
        if ~exp_wait_on || exp_wait <= tol
            [q] = enqueue(reorder, q, t, oc, req, tol, noc); %Add customer to queue
        end
        
        %Print snapshot of system for debugging
        if debug && t<debug_len;fprintf('  Arr %d: oc%d',i,oc);if exp_wait_on;fprintf(', exp %.1f',exp_wait);end;end;
    end
    
    %Decrement the remaining service times for each technician
    for i=1:ntechs
        if techs(i)>0  %If the tech is busy, decriment time
            techs(i)=techs(i)-1;
        end
    end
    
    %Print snapshot of system for debugging
    if debug && t<debug_len
        fprintf('     Q: '); if size(q,1); for i = 1:size(q,1); fprintf('[%d,%d] ', q(i,1), q(i,3)); end; end;
        fprintf('\nWaits: '); %Prep for next debugging block
    end
    
    %Check if technicians can dequeue
    for i=1:ntechs
        if techs(i)==0  %Is the tech free?
            if size(q,1)>0  %If any one waiting, pass them to a tech, dequeue them, and update the wait and profit
                [techs(i), q, wait, profit, po, pr, fo] = dequeue(q, wait, t, debug, debug_len, profit, ...
                    oc_rev, repair_rev_rate, special, tspecial, po, pr, fo);
            else idle = idle + 1;
            end
        end
    end
    
    %If the wait limit is on, loop through queues and remove customers who have waited too long.
    if limit_wait_on
        [q, lost, lo, lr] = limit_wait(q, lost, t, lo, lr);
    end
    
    %Populate wait and lost vectors
    if track_lost
        lost_vec(t) = lost;
    end
    if track_wait
        wait_vec(t) = wait;
    end
    
%     if track_profit
%         profit = profit - labor_rate * ntechs; %Update the profit
%         profit_vec(t) = profit
%     end
end

wait = wait/(arrivals-lost);  %Determine the average wait of served customers

