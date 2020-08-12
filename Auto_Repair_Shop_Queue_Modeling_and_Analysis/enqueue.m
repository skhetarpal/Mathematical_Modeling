function [q] = enqueue(reorder, q, t, oc, req, tol, noc)
%This function enqueues the customer.  If 'reorder' is called, oil change
%customers are put at the front behind prequeued oil change customers.

if reorder == 1 && oc == 1 %If reorder, put oc customers just behind other oc customers
    qlen = size(q,1);
    if noc == 0
        q = [[t,oc,req,tol];q];
    elseif noc == qlen
        q = [q;[t,oc,req,tol]];
    elseif noc >= 1 && noc < qlen
        q = [q(1:(noc),:);[t,oc,req,tol];q((noc+1):qlen,:)];
    else error('noc has exceeded qlen');
    end
else
    q = [q;[t,oc,req,tol]];  %Put customer at end of queue.
end