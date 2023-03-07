function ids_JND_savefcn

global def
global work

%str=[def.result_path def.expname '_' work.vpname work.userstr '_' work.condition];	% name of save file
str=[def.result_path work.filename];

%%%%%%%%% build headerline %%%%%%%%
%if def.interleaved > 0
   headerl = '% run#   track#';
%else
%   headerl = '% run#';
%end
for i = 1:def.expparnum
   eval(['parunit = def.exppar' num2str(i) 'unit;']);
   headerl = [headerl '   exppar' num2str(i) '[' parunit ']'];
end
headerl = [headerl '   expvar[' def.expvarunit ']   n.pres   n.correct'];
%%%%%%%% end headerline %%%%%%%%%

%%%%%%%% get data %%%%%%%%%%%%%%%
tmpinterleavenum = 1;								% fixme: remove this in future versions
if def.interleaved > 0
   tmpinterleavenum = def.interleavenum;
end

for i = 1:tmpinterleavenum
   endstepsizeindex = sum(def.practicenum{i});%0;%min(find(abs(diff(work.expvar{i})) == def.varstep{i}(end)));	% reached final stepsize
	restmp = work.expvar{i}(endstepsizeindex + 1 : end);										% get expvars in measurement phase
   correcttmp = work.correct{i}(endstepsizeindex + 1 : end);

   res.range{i} = sort(def.expvar{i});%[min(restmp):def.varstep{i}(end):max(restmp)]';							% determine expvar range
   res.n_pres{i} = res.range{i} * 0;
   res.n_correct{i} = res.range{i} * 0;
   
   for k = 1:length(restmp)																			% gathering statistics
      tmpindex = find(res.range{i} == restmp(k));
      res.n_pres{i}(tmpindex) = res.n_pres{i}(tmpindex) + 1;
      res.n_correct{i}(tmpindex) = res.n_correct{i}(tmpindex) + correcttmp(k);
   end
end
%%%%%%%% end get data %%%%%%%%%%%%%
% 
% r='   %.8f   %i   %i';
% 
% ex = exist([str '.dat'],'file');
% 
% if ex == 0
%    %dat=['% exppar[' def.exppar1unit ']   expvar[' def.expvarunit ']'];
%    fid=fopen([str '.dat'],'w');
%    fprintf(fid,['%s\n'],headerl);
%    for k=1:tmpinterleavenum    
%       for l = 1:length(res.range{k})
% 	      fprintf(fid,'%i',work.numrun);			% current run number
%    	   %if def.interleaved > 0
%       	   fprintf(fid,'   %i',k);					% track number if interleaved
%       	%end
%        	for i=1:def.expparnum
%       		eval(['tmp = work.int_exppar' num2str(i) '{' num2str(k) '};']);
%       		if def.exppartype(i) == 0
%          		fprintf(fid,['   %.8f'],tmp);
%       		else
%          		fprintf(fid,['   %s'],tmp);
%       		end
%       	end
%          fprintf(fid,[r '\n'],[ res.range{k}(l) res.n_pres{k}(l) res.n_correct{k}(l) ] );
%       end
%    end
% 	fclose(fid);
% else
%    fid=fopen([str '.dat'],'a');
%    for k=1:tmpinterleavenum    
%       for l = 1:length(res.range{k})
% 	      fprintf(fid,'%i',work.numrun);			% current run number
%    	   %if def.interleaved > 0
%       	   fprintf(fid,'   %i',k);					% track number if interleaved
%       	%end
%        	for i=1:def.expparnum
%       		eval(['tmp = work.int_exppar' num2str(i) '{' num2str(k) '};']);
%       		if def.exppartype(i) == 0
%          		fprintf(fid,['   %.8f'],tmp);
%       		else
%          		fprintf(fid,['   %s'],tmp);
%       		end
%       	end
%          fprintf(fid,[r '\n'],[ res.range{k}(l) res.n_pres{k}(l) res.n_correct{k}(l) ] );
%       end
%    end
% 	fclose(fid);
% end



if  ~exist([str '.mat'],'file')
    ids_out = build_ids_struckt(tmpinterleavenum,def,work);
else
    load([str '.mat'],'ids_out');
    ids_new = build_ids_struckt(tmpinterleavenum,def,work);
    ids_out = spar_concatenate(ids_out,ids_new);
end
save([str '.mat'],'ids_out');
work = rmfield(work,'timestamp');

if def.debug == 1
save([str '.mat'], 'work'); 
end

end


function ids_out = build_ids_struckt(tmpinterleavenum,def,work)
ids_out = [];

    for i = 1:tmpinterleavenum
        endstepsizeindex = sum(def.practicenum{i});
        expvar = work.expvar{i}(endstepsizeindex + 1 : end);
        correcttmp = work.correct{i}(endstepsizeindex + 1 : end);

         ids_out = add_spar(ids_out, expvar ,def.expvardescription,'unit',def.expvarunit);
         ids_out = add_spar(ids_out, work.answer{:} ,'answer');
         ids_out = add_spar(ids_out, work.position{:}, 'target_interval');         
         ids_out = add_spar(ids_out, work.reversal{:}, 'reversal');         
         ids_out = add_spar(ids_out, work.numrun ,'n_run');          
         ids_out = add_spar(ids_out, work.timestamp, 'timestamp');        
         
            for i_n = 1:def.expparnum
                tmp = work.(['int_exppar' num2str(i_n)]){1} ;
                par = def.(['exppar',num2str(i_n),'description']);
                parunit = def.(['exppar', num2str(i_n),'unit']);

                ids_out = add_spar(ids_out, tmp ,par,'unit',parunit);

            end
             
            ids_out.data = correcttmp;
            ids_out.data_info.ndim = 0;
            ids_out = add_mpar(ids_out,work.vpname,'vp_name');

    end
end