function FAK = FAKULT(N)
    % N!
    if N <= 1
        FAK = 1.0;
    else
        FAK = prod(1:N);
    end
end