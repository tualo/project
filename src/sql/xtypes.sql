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
        "Tualo.project.form.field.Translators",
        "Tualo.project.form.field.Translators",
        
        "widget.tualo_projectmanagement_translators",
        "Ext.form.field.ComboBox",
        "widget.tualo_projectmanagement_translators",

        "Tualo.project.form.field.Translators",
        "Tualo Column for ProjectmanagementStates",
        0,
        1
    )
;
