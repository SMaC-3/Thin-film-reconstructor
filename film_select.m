function film_select(T_film)

        radius = T_film.radius;
        red_film = T_film.red_film;
        blue_film = T_film.blue_film;
        
        figure()
        scatter([-radius; radius], [blue_film;blue_film], 50,'blue')
        hold on
        scatter([-radius; radius], [red_film;red_film], 50,'red')
        hold off
        
        col_prompt = 'Red or blue [1/2]: ';
        col = input(col_prompt);
        while isempty(col)
            col = input(col_prompt);
        end
        
        if col == 1
            radius_plot{i} = radius;
            film_plot{i} = red_film;
            col_choice{i} = {'red'};
            
        elseif col == 2
            radius_plot{i} = rad_blue;
            film_plot{i} = blue_int;
            col_choice{i} = {'blue'};
        end

end