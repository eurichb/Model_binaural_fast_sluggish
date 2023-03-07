function h = circle_plot(sdf,par,marker,color,linestyle)

[split1,xval,num1] = z_par_split_by_name(sdf,par{1},par{2});

for i_s1 = num1
    data(:,i_s1) = split1(i_s1).data;
end

multcolor = num2cell(color,2);

marker = 'o';

h = plot(xval,data',marker,'MarkerSize',5);
set(h, {'color'},multcolor);
hold all
xlabel(par{1})
ylabel(sdf.data_info.name);
end
