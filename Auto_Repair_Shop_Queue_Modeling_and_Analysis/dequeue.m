function [tech_req, q, wait, profit, po, pr, fo] = dequeue(q, wait, t, debug, debug_len, profit, ...
    oc_rev, repair_rev_rate, special, tspecial, po, pr, fo)
%This function passes a customer to a technician, removes the person from
%   the queue, and updates the accumulated wait time.

qlen = size(q,1);
tech_req = q(1,3);  %put request to tech
wait = wait + (t-q(1,1));  %the time customer waited

%Update the profit
if q(1,2) == 1 %Oil Change
    if special
        %If the service is within the time limit, charge the customer
        if (t-q(1,1)+q(1,3)) <= tspecial
            profit = profit + oc_rev;
            po = po + 1; %Increment # paid oil changes
        else
            fo = fo + 1; %Increment # free oil changes
        end
    else
        profit = profit + oc_rev;
        po = po + 1; %Increment # paid oil changes
    end
else %Repair
    profit = profit + repair_rev_rate * tech_req;
    pr = pr + 1; %Increment # paid repair jobs
end

%Print snapshot of system for debugging
if debug && t<debug_len;fprintf('%d,', t-q(1,1));end;

%remove customer from queue
if qlen>1  %any one else there?
    q=q(2:qlen,:);
else
    q=[];  %no one left
end

end