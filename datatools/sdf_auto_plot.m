function sdf_auto_plot(sdf_in,func,varargin)
% sdf_auto_plot(SDF,FUNC,VARARGIN) is a powerful automatic plot function,
%to use @ multi dim sdf - struct.
%
%Parameters:
%    SDF_IN: data in sdf. ndim should be 0 or 1
%
%    FUNC:   use 'plot' or 'errorbar' or give a handle to your own plot-fct.
%
%    VARARGIN:    name up to 5 par by {name,'s'/'m'} where s/m denotes s- or mpar.
%                 sdf_auto_plot will run a split along all given par, after
%                 this there should be *not* multi par left!
%
%Example:
%::
%  %JUST FOR UNDERSTANDING
%  %(not working, since mymodel doesn't return result-data-format)
%  spar.ipd = [0:,1:1] * pi;
%  spar.bw = [200, 400];
%  spar.lvl = 70;
%  sdf = run_exp(spar,@mymodel,[]);
%  sdf_auto_plot(sdf,'plot',{'ipd','s'},{'vp_name','m'});
%
%see also sdf_info spar_split_by_name


n_par = length(varargin);
if n_par < 1
    error('spar needed as input')
end

if strcmp(func,'plot')
    func = @auto_plot;
elseif strcmp(func,'errorbar')
    func = @auto_errorbar;
end


if n_par == 5
    [split5,val5,num5] = z_par_split_by_name(sdf_in,varargin{5}{1},varargin{5}{2});
else
    split5 = sdf_in;
    val5 =1;
    num5 = 1;
    varargin{5}{1} = 'fig';
end


%get highest figure number
hfs = get(0,'children');
if isempty(hfs)
    h_number = 0;
else
    h_number = max([hfs.Number]);
end

for i_s5 = num5
    
    hf = figure(h_number+i_s5);
    set(hf,'numbertitle','off','name',[varargin{5}{1},' = ',num2str(val5(i_s5))]);
    
    if isempty(varargin{4})
        split4 = split5(i_s5);
        val4 =[];
        num4 = 1;
        show_title=0;
    elseif n_par >= 4
        [split4,val4,num4] = z_par_split_by_name(split5(i_s5),varargin{4}{1},varargin{4}{2});
        show_title=1;
    else
        split4 = sdf_in;
        val4 =1;
        num4 = 1;
        show_title=0;
    end
    
    for i_s4 = num4
        
        selvev = 1:6;
        subpos = (selvev) .* (selvev)';
        [a,b] = find(subpos == (num4(end)+(num4(end)>4)*isprime(num4(end))));
        selvev(a)+selvev(b);
        [~,parindex] = min(selvev(a)+selvev(b));
        
        hs(i_s4) = subplot(b(parindex),a(parindex),i_s4);
        if isempty(varargin{3})
            split3 = split4(i_s4);
            val3 =[];
            num3 = 1;
        elseif n_par >= 3
            [split3,val3,num3] = z_par_split_by_name(split4(i_s4),varargin{3}{1},varargin{3}{2});
        else
            split3 = sdf_in;
            val3 =[];
            num3 = 1;
        end
        
        linestyles ={'-','--',':','-.','-','--',':','-.','-','--',':','-.'};
        for i_s3 = num3
            
            
            if isempty(varargin{2})
                split2 = split3(i_s3);
                val2 =[];
                num2 = 1;
                ldg1_title_string ='';
            elseif n_par >= 2
                [split2,val2,num2] = z_par_split_by_name(split3(i_s3),varargin{2}{1},varargin{2}{2});
                ldg1_title_string = varargin{2}{1};
            else
                split2 = sdf_in;
                val2 =1;
                num2 = 1;
            end
            
            for i_s2 = num2
                
                markers ={'o','v','d','^','s','>','h','<','p','*','+','x','.'};
                colors = lines(length(markers));
                
               % If an array of color indices is put in, multiple line plots have different colors (not active now); 
               % same for different linestyles (active now)
                hndl1_t = func(split2(i_s2),varargin{1},markers{i_s3},colors(i_s2,:),linestyles(1:size(split2(i_s2).data,1)));                
                hndl1_a{i_s3,i_s2} = {hndl1_t};
                if show_title
                    title([varargin{4}{1},' = ',num2str(val4(i_s4))])
                end
                               
            end
            
            
        end
        
        ax1 = gca;
        hndl1 = hndl1_a{1,:};
        hndl1 = hndl1{:};
        if length(num3) > 1
            for i_s2 = num2
                hndl1(i_s2) = plot(nan,nan,'color',colors(i_s2,:),'linestyle',linestyles{1});
            end
            
            ax2 = copyobj(gca,gcf);
            delete(get(ax2,'children'))
            hold on
            
            for i_s3 = num3
                hndl2(i_s3) = plot(nan,nan,['k',markers{i_s3}]);
            end
            hold off
            set(ax2, 'Color', 'none', 'XTick', [], 'YAxisLocation', 'right', 'Box', 'Off', 'Visible', 'off');
            parindex = z_get_par_index(varargin{3}{2},split2(1),varargin{3}{1});
            if isfield(split2(i_s2).([varargin{3}{2},'par_info'])(parindex),'values')
            if ~isempty(split2(i_s2).([varargin{3}{2},'par_info'])(parindex).values)
                ldg2_strings = split2(i_s2).([varargin{3}{2},'par_info'])(parindex).values;
            else
                ldg2_strings = num2str(val3');
            end
             else
                ldg2_strings = num2str(val3');
            end
            lgd2 = legend(ax2,hndl2,ldg2_strings,'location','best');  % only select first two data lines, as there's only two different colours
                       
            
            title(lgd2,varargin{3}{1})
            set(lgd2,'color','none')
        end
        
        if ~strcmp(ldg1_title_string,'')
            parindex = z_get_par_index(varargin{2}{2},split2(1),varargin{2}{1});
            if isfield(split2(i_s2).([varargin{2}{2},'par_info'])(parindex),'values')
                if ~isempty(split2(i_s2).([varargin{2}{2},'par_info'])(parindex).values)
                    ldg1_strings = split2(i_s2).([varargin{2}{2},'par_info'])(parindex).values;
                else
                    ldg1_strings = num2str(val2');
                end
            else
                ldg1_strings = num2str(val2');
            end
            lgd1 = legend(ax1, hndl1',ldg1_strings,'location','best');  % only select first two data lines, as there's only two different colours
            title(lgd1,ldg1_title_string) % add legend title
        end
    end
    
    linkaxes(hs,'y')
end

end

function h = auto_plot(sdf,par,marker,color,linestyle)

[split1,xval,num1] = z_par_split_by_name(sdf,par{1},par{2});

for i_s1 = num1
    data(:,i_s1) = split1(i_s1).data;
end

multcolor = num2cell(color,2);

h = plot(xval,data',marker);
set(h, {'color'},multcolor,{'linestyle'},linestyle');
hold all
xlabel(par{1})
ylabel(sdf.data_info.name);
end


function h = auto_errorbar(sdf,par,marker,color,linestyle)

[split1,xval,num1] = z_par_split_by_name(sdf,par{1},par{2});

for i_s1 = num1
    data(:,i_s1) = split1(i_s1).data;
end

h = errorbar(xval,median(data),quantile(data,0.25), quantile(data,0.75),'Marker',marker,'LineStyle',linestyle{:},'color',color,'LineWidth',2);
hold all
xlabel(par{1})
ylabel(sdf.data_info.name);
end
