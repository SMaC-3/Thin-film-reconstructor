function [norm_int] = intensity_normalise(sp, sp_ind, int_data)

norm_int = zeros(length(int_data),1);
for i = 1:length(sp)-1
    if i == 1
        norm_int(1:sp_ind(i+1)) =... 
            (int_data(1:sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    elseif i~= 1 && i~= length(sp)-1
        norm_int(sp_ind(i):sp_ind(i+1)) = ...
            (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    else
        norm_int(sp_ind(i):end) =...
             (int_data(sp_ind(i):end) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    end
end
end

