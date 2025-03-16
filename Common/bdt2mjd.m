function mjd=bdt2mjd(week, sec)
[mjd0,~] = date2mjd([2006,1, 1,0,0,0]);
mjd(1)=mjd0(1)+week*7+floor((sec+mjd0(2))/86400);
mjd(2)=sec+mjd0(2)-floor((sec+mjd0(2))/86400)*86400;