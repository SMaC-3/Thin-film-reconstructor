% Code written by Joshua P. King, SMaCLab, Monash University, Australia
% Last updated: August, 2022

%   ________  ___      ___       __       ______   ___            __       _______   
%  /"       )|"  \    /"  |     /""\     /" _  "\ |"  |          /""\     |   _  "\  
% (:   \___/  \   \  //   |    /    \   (: ( \___)||  |         /    \    (. |_)  :) 
%  \___  \    /\\  \/.    |   /' /\  \   \/ \     |:  |        /' /\  \   |:     \/  
%   __/  \\  |: \.        |  //  __'  \  //  \ _   \  |___    //  __'  \  (|  _  \\  
%  /" \   :) |.  \    /:  | /   /  \\  \(:   _) \ ( \_|:  \  /   /  \\  \ |: |_)  :) 
% (_______/  |___|\__/|___|(___/    \___)\_______) \_______)(___/    \___)(_______/  
                                                                                   

% SMaCLab website can be found here:
% https://sites.google.com/view/smaclab

%--------------------------------------------------------------

function [norm_int, I_dimp] =...
    intensity_normalise(radial_data, int_data, I_min, I_max, dimple_radius,...
    int_min, int_max)

%--------------------------------------------------------------
% Prepare stationary point information and global intensity max/min for
% normalisation
%--------------------------------------------------------------

I_sp = sort([I_min; I_max]);
sp = int_data(I_sp);

maxx = int_max;
minn = int_min;

%--------------------------------------------------------------
% Identify dimple index
%--------------------------------------------------------------

[~, I_radius_dimp] = min(abs(radial_data - dimple_radius));

I_dimp = find(I_sp == I_radius_dimp);
if ismember(I_sp(I_dimp),I_min)
    dimp_max_min = -1;
elseif ismember(I_sp(I_dimp),I_max)
    dimp_max_min = 1;
end
    
dimp_in = I_dimp-1;

if dimp_in > 0
    factor = sp(dimp_in+2)/sp(dimp_in);
else 
    factor =1;
end

int_data(I_sp(I_dimp+1):end)=int_data(I_sp(I_dimp+1):end)/factor;
sp(I_dimp+1:end) = int_data(I_sp(I_dimp+1:end));

if min(I_min) < min(I_max)
    sp_first = -1;
else
    sp_first = 1;
end 

norm_int = zeros(length(int_data),1);

I_sp_max_min = (ismember(I_sp, I_min)*-1)+ismember(I_sp, I_max);


%--------------------------------------------------------------
% Normalise data branch-wise, unless dimple centre or rim then use global
% intensity max &/or min because these regions are not true stationary
% points
%--------------------------------------------------------------

for i = 0:length(sp)-1

    % Film is flat and same height as dimple rim, no other SP observed
    if i==0 && dimp_in == 0 || i==1 && dimp_in == 0 
        if dimp_max_min == -1
            norm_int(1:I_sp(i+2)) = ...
                (2*int_data(1:I_sp(i+2)) - (maxx+minn))./(maxx-minn);

        elseif dimp_max_min == 1
            norm_int(1:I_sp(i+2)) = ...
                (2*int_data(1:I_sp(i+2)) - (maxx+minn))./(maxx-minn);
        end
        
    % Dimple center not true stationary point, use global max/min
    elseif i == 0 && dimp_in ~= 0         
        if sp_first == -1            
            
            norm_int(1:I_sp(i+1)) =...
                (2*int_data(1:I_sp(i+1)) - (sp(1) + maxx) )...
                ./(maxx - sp(1));
            
        elseif sp_first == 1
            
            if min(int_data(1:I_sp(I_dimp))) < minn
                min_first = min(int_data(1:I_sp(I_dimp)));
            else
                min_first = minn;
            end
            
            norm_int(1:I_sp(i+1)) =...
                (2*int_data(1:I_sp(i+1)) - (sp(1) + minn) )...
                ./(sp(1) - minn);
        end

    % Normalise branch-wise using max and min values at end of each branch
    elseif i~= 0 && i< dimp_in
        if I_sp_max_min(i) ~= I_sp_max_min(i+1)
        
            norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (min(sp(i:i+1)) + max(sp(i:i+1))) )...
            ./(max(sp(i:i+1)) - min(sp(i:i+1)));

        elseif I_sp_max_min(i) == I_sp_max_min(i+1) && I_sp_max_min(i) == 1        
            
            norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (minn + max(sp(i:i+1))) )...
            ./(max(sp(i:i+1)) - minn);

        elseif I_sp_max_min(i) == I_sp_max_min(i+1) && I_sp_max_min(i) == -1

            norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (min(sp(i:i+1)) + maxx ))...
            ./(maxx - min(sp(i:i+1)));

        end
    
    % For branch containing dimple rim, use local SP for end of branch but
    % global value for dimple rim 
    elseif i == dimp_in || i == dimp_in + 1 && dimp_in ~=0
       
        if dimp_max_min == -1
            norm_int(I_sp(i):I_sp(i+1)) = ...
                (2*int_data(I_sp(i):I_sp(i+1)) - (max(sp(i:i+1))+minn))./(max(sp(i:i+1))-minn);
        elseif dimp_max_min == 1
            norm_int(I_sp(i):I_sp(i+1)) = ...
                (2*int_data(I_sp(i):I_sp(i+1)) - (maxx+min(sp(i:i+1))))./(maxx-min(sp(i:i+1)));
        end
    
    % Normalise branch-wise using max and min values at end of each branch
    elseif i>dimp_in+1 && i<length(sp)
        norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (min(sp(i:i+1)) + max(sp(i:i+1))) )...
            ./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    else
        norm_int(I_sp(i):end) =...
            (2*int_data(I_sp(i):end) -...
            (min(int_data(I_sp(i):end)) +max(int_data(I_sp(i):end))) )...
            ./(max(int_data(I_sp(i):end)) - min(int_data(I_sp(i):end)));
        
    end
end

figure(3)
plot(radial_data, norm_int, 'black', 'LineWidth', 2)
hold on
scatter(radial_data(I_sp), norm_int(I_sp), 200, 'black', 'filled')
hold off

end
