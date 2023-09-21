insert
    ignore into extjs_base_types (
        vendor,
        id,
        classname,

        xtype_long_classic,
        baseclass,
        xtype_long_modern,
        name,
        description,
        iscolumn,
        isformfield
    )
values
    (
        "Tualo",
        "Tualo.project.grid.column.ProjectmanagementStates",
        "Tualo.project.grid.column.ProjectmanagementStates",
        
        "widget.projectmanagement_states_column",
        "Tualo.cmp.cmp_ds.column.DS",
        "widget.projectmanagement_states_column",

        "Tualo.project.grid.column.ProjectmanagementStates",
        "Tualo Column for ProjectmanagementStates",
        1,
        0
    )
;