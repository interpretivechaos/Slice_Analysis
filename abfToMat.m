function emf=abfToMat(fn)
[d, si, h]=abfload(fn);
emf=struct([]);
emf(1).xlabel='';
emf(1).xunits='s';
emf(1).start=0;
emf(1).interval=si*10^-6;
emf(1).points=length(d(:,1,1));
emf(1).chans=length(d(1,:,1));
emf(1).frames=length(d(1,1,:));
emf(1).chaninfo=struct([]);

for i=1:emf.chans
    emf.chaninfo(i).number=i;
    emf.chaninfo(i).title=h.recChNames{i};
    emf.chaninfo(i).units=h.recChUnits{i};
end

%Note Frame info is unused and currently blank
emf(1).frameinfo=struct([]); 
emf(1).values=d;
% help='The first file is just a dummy to match the two files from signal';
fn(end-3:end)='.mat';
fn=string(fn);
disp(fn)

save(fn, 'emf');

end