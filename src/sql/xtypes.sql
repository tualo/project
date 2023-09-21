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
        "Tualo.project.grid.column.ProjectmenagementStates",
        "Tualo.project.grid.column.ProjectmenagementStates",
        
        "widget.projectmenagement_states_column",
        "Tualo.cmp.cmp_ds.column.DS",
        "widget.projectmenagement_states_column",

        "Tualo.project.grid.column.ProjectmenagementStates",
        "Tualo Column for ProjectmenagementStates",
        1,
        0
    )
;