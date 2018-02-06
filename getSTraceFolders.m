% function tracePaths=getSTraceFolders(root)
root='/Users/ryan/Dropbox/Data_Slice/Traces/';
files=dir(root);
matfiles=struct([]);
matfilesindex=1;
% matfilenames=struct('Mouse',[],'ExperimentNumber' ,[]);
matfilenames=struct([]);

for i=1:length(files)
    if files(i).name(1)=='S'
        disp(files(i).name)        
        getmatfilename=getMatFiles(strcat(root,files(i).name,'/'),files(i).name);
        
        if ~isempty(getmatfilename(1).ExperimentNumber)
            disp(size(getmatfilename(1).ExperimentNumber))
            matfilenames=[matfilenames, getmatfilename];
        end
        
    end
end
