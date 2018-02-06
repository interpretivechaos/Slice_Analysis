%LoadAllSliceData

%% x=lpAnalysis([70, 1, 1], 'Chronos-nonflexed', 'All', true);

x=lpAnalysis([47, 16, 1], 'Chronos-flexed', 1:2:5, false);
lpExportStructToCSV(x)

lpShortcut(84, 1,1, "cn");

%% 
lpShortcut(3, 1, 1, "mf");
lpShortcut(3, 5, 1, "mf");
lpShortcut(3, 13, 2, "mf");
lpShortcut(3, 15, 3, "mf");
lpShortcut(3, 18, 3, "mf");
lpShortcut(4, 1, 1, "mf");
lpShortcut(4, 3, 1, "mf");


%%
lpShortcut(84, 8,1, "cn");
lpShortcut(83, 1,1, "cn");
lpShortcut(83,12,2, "cn");
lpShortcut(83,20,2, "cn");
lpShortcut(81, 3,1, "cn");
lpShortcut(75, 4,1, "cn");
lpShortcut(74, 1,1, "cn");
lpShortcut(74, 7,1, "cn");

lpShortcut(72, 1,1, "cn");
lpShortcut(70, 1,1, "cn");
lpShortcut(70, 7,1, "cn");
lpShortcut(70,15,2, "cn");
lpShortcut(70,27,2, "cn");
lpShortcut(67, 3,1, "cn");
lpShortcut(67,12,1, "cn");
lpShortcut(65, 1,1, "cn");
lpShortcut(65, 7,1, "cn");


function lpShortcut(mouse, filenumber, cellnumber, virus)
switch virus
    case "cn"
        virusname='Chronos-nonflexed';
    case "cf"
        virusname='Chronos-flexed';
    case "mf"
        virusname='mCherry-flexed';
end

x=lpAnalysis([mouse, filenumber, cellnumber], virusname, 'All', false);
lpExportStructToCSV(x);
end