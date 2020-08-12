function noc = count_noc(q)
%Count the number of oil change customers at the front of the queue

noc = 0; %Initialize the count
qlen = size(q,1);
i = 1; %Index for location in queue
stop = 0; %Tracks whether or not we have gone beyond the oil change customers
if qlen
    while ~stop && i <= qlen
        if q(i,2) == 1
            noc = noc + 1;
        else
            stop = 1;
        end
        i = i+1;
    end
end