% /*****************************************************************************
% * Description : Normalized legendre polynomial
% * Parameters  :
% *			INN: Degree     IMM: Order:
% *****************************************************************************/	
function result = ASLEFU(XLAT, XLON, INN, IMM)
    % variables
    NN = abs(INN);
    MM = abs(IMM);
    PMM = 1.0;
    FACT = 1.0;

    % Legendre calculation
    if INN >= 0
        XX = sin(XLAT);
    else
        XX = cos(XLAT);
    end
    if MM > 0
        SOMX2 = sqrt((1.0 - XX) .* (1.0 + XX));
        for II = 1:MM
            PMM = PMM .* FACT .* SOMX2;
            FACT = FACT + 2.0;
        end
    end

    if NN == MM
        COEF = PMM;
    else
        PMMP1 = XX .* (2 * MM + 1) .* PMM;
        if NN == MM + 1
            COEF = PMMP1;
        else
            for LL = MM + 2:NN
                PLL = (XX .* (2 * LL - 1) .* PMMP1 - (LL + MM - 1) .* PMM) / (LL - MM);
                PMM = PMMP1;
                PMMP1 = PLL;
            end
            COEF = PLL;
        end
    end

    % normalization
    if MM == 0
        KDELTA = 1.0;
    else
        KDELTA = 0;
    end
    FACTN = sqrt(2 .* (2 .* NN + 1) ./ (1 + KDELTA) .* factorial(NN - MM) ./ factorial(NN + MM));

    if IMM >= 0
        result = FACTN .* COEF .* cos(MM .* XLON);
    else
        result = FACTN .* COEF .* sin(MM .* XLON);
    end
end