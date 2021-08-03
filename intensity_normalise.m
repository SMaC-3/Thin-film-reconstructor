function [norm_int, I_dimp, I_min, I_max] =...
    intensity_normalise(radial_data, int_data, I_min, I_max)

I_sp = sort([I_min; I_max]);
sp = int_data(I_sp);

maxx = max(sp);
minn = min(sp);
%--------------------------------------------------------------------------
% Identify dimple index
%--------------------------------------------------------------------------

figure(3)
plot(radial_data, int_data, 'black', 'LineWidth', 2)
hold on
scatter(radial_data(I_sp), int_data(I_sp), 200, 'black', 'filled')

for k = 1:length(I_sp)
   
    text(radial_data(I_sp(k)), mean(int_data) ,num2str(k))
    
end
hold off
disp([radial_data(I_sp).' ; 1:length(I_sp)])

dimp_prompt = 'Identify index of dimple (enter 0 to manually add a sp or -1 to manually remove a sp): ';
I_dimp = input(dimp_prompt);
while isempty(I_dimp)
    I_dimp = input(dimp_prompt);
end

while I_dimp == 0 | I_dimp == -1
    
    if I_dimp == 0
        man_ID_prompt = 'please select pixel value for SP: ';
        man_ID = input(man_ID_prompt);
        while isempty(man_ID)
            man_ID = input(man_ID_prompt);
        end
        [~, mvI] = min(abs(radial_data - man_ID));
        
        man_ID_prompt_2 = 'Is this a max or min [enter 1 or 0]: ';
        man_ID_2 = input(man_ID_prompt_2);
        while isempty(man_ID_2)
            man_ID_2 = input(man_ID_prompt_2);
        end
        
        
        if man_ID_2 == 1
            I_max = [I_max;mvI];
        elseif man_ID_2 == 0
            I_min = [I_min;mvI];
        end
        
        I_sp = [I_sp; mvI];
        [I_sp, I_sp_sorted] = sort(I_sp);
        
        sp = [sp; int_data(mvI)];
        sp = sp(I_sp_sorted);
        
    
    elseif I_dimp == -1
         
        man_ID_prompt = 'please select pixel value for SP: ';
        man_ID = input(man_ID_prompt);
        while isempty(man_ID)
            man_ID = input(man_ID_prompt);
        end
        
        [~, mvI] = min(abs(radial_data - man_ID));
        [~,find_I] = min(abs(I_sp-mvI));
        
        I_sp(find_I) = [];
        sp(find_I) = [];
        
        is_max = ismember(I_max, find_I);
        I_max(is_max) = [];
        is_min = ismember(I_min, find_I);
        I_min(is_min) = [];
    
    end
    
    figure(3)
    plot(radial_data, int_data, 'black', 'LineWidth', 2)
    hold on
    scatter(radial_data(I_sp), int_data(I_sp), 200, 'black', 'filled')
    for k = 1:length(I_sp)
    text(radial_data(I_sp(k)), mean(int_data) ,num2str(k))  
    end
    hold off
    disp([radial_data(I_sp).' ; 1:length(I_sp)])
    
    dimp_prompt = 'Identify index of dimple (enter 0 to manually add a sp or -1 to manually remove a sp): ';
    I_dimp = input(dimp_prompt);
    while isempty(I_dimp)
        I_dimp = input(dimp_prompt);
    end

end

if ismember(I_sp(I_dimp),I_min)
    dimp_max_min = -1;
elseif ismember(I_sp(I_dimp),I_max)
    dimp_max_min = 1;
end
    

dimp_in = I_dimp-1;

norm_int = zeros(length(int_data),1);

%--------------------------------------------------------------------------

for i = 1:length(sp)-1
    if i == 1 % Dimple center not true stationary point, use global max/min? 

        norm_int(1:I_sp(i+1)) =... 
            (2*int_data(1:I_sp(i+1)) - (min(sp(i:i+1)) + max(sp(i:i+1))) )...
            ./(max(sp(i:i+1)) - min(sp(i:i+1)));
        
    elseif i~= 1 && i< dimp_in
    
        norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (min(sp(i:i+1)) + max(sp(i:i+1))) )...
            ./(max(sp(i:i+1)) - min(sp(i:i+1)));
    
    elseif i == dimp_in || i == dimp_in + 1
        
%         if dimp_max_min == -1
%             norm_int(I_sp(i):I_sp(i+1)) = ...
%                 (2*int_data(I_sp(i):I_sp(i+1)) - (max(sp(i:i+1))+minn))./(max(sp(i:i+1))-minn);
%         elseif dimp_max_min == 1
%             norm_int(I_sp(i):I_sp(i+1)) = ...
%                 (2*int_data(I_sp(i):I_sp(i+1)) - (maxx+min(sp(i:i+1))))./(maxx-min(sp(i:i+1)));
%         end

        norm_int(I_sp(i):I_sp(i+1)) = ...
            (2*int_data(I_sp(i):I_sp(i+1)) - (maxx+minn))./(maxx-minn);

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

end
