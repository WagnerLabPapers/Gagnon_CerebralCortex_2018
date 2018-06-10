function newStruct = subsetStruc(oldStruct, condition, fieldname)


fieldname_list = fieldnames(oldStruct);

for field = 1:length(fieldname_list)
    eval(['newStruct.',fieldname_list{field}, '= oldStruct.', ...
        fieldname_list{field}, '(strcmp(oldStruct.', fieldname, ', condition));']);
end

