

a = [];
a = add_spar(a,4,'lol');
a = add_spar(a,3,'freq','unit','Hz');

b = a;

a = add_spar(a,1,'side','index',1,'values',{'left'});
a = add_spar(a,'lol','type');
a = add_mpar(a,3,'thres','index',3,'values',{'lol'});

b = add_spar(b,1,'side','index',1,'values',{'right'});
b = add_spar(b,'le','type');
b = add_mpar(b,3,'thres','index',[1,3],'values',{'lol','e'});

[a,b] = z_check_indexed_values(a,b)