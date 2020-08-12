function [q, lost, lo, lr] = limit_wait(q, lost, t, lo, lr)
%This function removes customers from the queue who have reached their wait
%   tolerance.  Removed customers are lost.

finished = 0;
while ~finished
    qlen = size(q,1);
    if ~qlen
        finished = 1; %queue is empty
    else
        for i = 1:qlen
            if (t-q(i,1)) >= q(i,4) %If customer has waited too long
                lost = lost + 1; %Lost customer
                if q(i,2); lo = lo + 1; else lr = lr + 1; end; %Track what type of customer was lost
                %Pop customer from queue
                if qlen == 1
                    q = [];
                        finished = 1;
                elseif i == 1
                    q = q(2:qlen,:,:);
                    break;
                elseif i == qlen
                    q = q(1:(qlen-1),:,:);
                elseif i > 1 && i < qlen
                    q = q([1:(i-1),(i+1):qlen],:,:);
                    break;
                else error('error in wait dequeue');
                end
            end
            if i == qlen
                finished = 1;
            end
        end
    end
end