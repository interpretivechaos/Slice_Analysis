function folderpath=lsd(sliceExperiment, filenum)
%lookup slice data (lsd) is a shortcut for loading slice data.
slicefolder=char(strcat('/Users/ryan/Dropbox/Data_Slice/Traces/S', string(sliceExperiment)', '/'));


allfiles=dir(slicefolder);
% allfiles.name




pickfirst=true;
if sliceExperiment==4
    if filenum>5
        filenum=filenum-5
        pickfirst=false;
    end
end

filenumstr=char(strcat('0', string(filenum), '.mat'));
disp(filenumstr);

twodays=false;
for i=1:length(allfiles)
    
    %     disp(length(filenumstr));
    if length(allfiles(i).name)>length(filenumstr)
        %         disp(filepath(i).name);
        %         filepath(i).name(end-length(filenumstr)+1:end)
        %     disp(filenumstr);
        
        if strcmp(allfiles(i).name(end-length(filenumstr)+1:end), filenumstr)
            %             folderpath=strcat(slicefolder, allfiles(i).name);
            
            if pickfirst && twodays 
                folderpath=strcat(slicefolder, allfiles(i).name);
                disp(allfiles(i).name);
                disp('Option1')
            elseif twodays
                folderpath=strcat(slicefolder, allfiles(i).name);
                disp(allfiles(i).name);
                disp('Option2')
            end
            
            if twodays
                disp('Warning, multiple files matching filenum')
            else
                twodays=true;
            end
                
        end
    end
end

if ~exist('folderpath')
    if isempty(allfiles)
        error(['Could not find ', slicefolder],'. Are you sure this was a data-bearing experiment?');
    else
        n=(length(allfiles)-1)/2;
        %       allfiles.name
        error(['Could not find ',filenumstr, '. There last file in the folder is ', allfiles(end).name]);
    end
end

% pickfirst
% twodays



end