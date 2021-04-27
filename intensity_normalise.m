function [norm_int] = intensity_normalise(sp, sp_ind, int_data, dimp_in, dimp_out)

%--------------------------------------------------------------------------
% sp is intensity value at max/min
% sp_ind is corresponding index
% int_data is complete intensity data
%--------------------------------------------------------------------------

% norm_int = zeros(length(int_data),1);
% for i = 1:length(sp)-1
%     if i == 1
%         norm_int(1:sp_ind(i+1)) =... 
%             (int_data(1:sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
%         
%     elseif i~= 1 && i~= length(sp)-1
%         norm_int(sp_ind(i):sp_ind(i+1)) = ...
%             (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
%         
%     else
%         norm_int(sp_ind(i):end) =...
%              (int_data(sp_ind(i):end) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
%         
%     end
% end


norm_int = zeros(length(int_data),1);
for i = 1:length(sp)-1
    if i == 1
        norm_int(1:sp_ind(i+1)) =... 
            (int_data(1:sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    elseif i~= 1 && i<= dimp_in+1
        norm_int(sp_ind(i):sp_ind(i+1)) = ...
            (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
    
%     elseif i == dimp_in
%         norm_int(sp_ind(i):sp_ind(i+1)) = ...
%             (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i-1:i)))./(max(sp(i-1:i)) - min(sp(i-1:i)));
%     
%     elseif i == dimp_in +1
%         norm_int(sp_ind(i):sp_ind(i+1)) = ...
%             (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i-2:i-1)))./(max(sp(i-2:i-1)) - min(sp(i-2:i-1)));

    elseif i>dimp_in+1 && i<length(sp)-1
        norm_int(sp_ind(i):sp_ind(i+1)) = ...
            (int_data(sp_ind(i):sp_ind(i+1)) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    else
        norm_int(sp_ind(i):end) =...
             (int_data(sp_ind(i):end) - min(sp(i:i+1)))./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    end
end
end
