function exp_wait = calc_exp_wait(reorder, q, oc, noc, techs, ntechs, mu_repair_req)
%This function calculates the expected wait time.

%Determine how many people are ahead of the customer in the queue
if reorder == 1 && oc
    qlen = noc;
else
    qlen = size(q,1);
end

if (qlen - sum(techs==0)) < 0 %If there is an open tech, no wait
    exp_wait = 0;
else %Else, sum of all preceding work and divide by # of techs.
    if qlen
        exp_wait = (sum(techs)+sum(q(1:qlen,3)))/ntechs;
    else
        exp_wait = sum(techs)/ntechs;
    end
end