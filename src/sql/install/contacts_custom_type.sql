delimiter ;
insert ignore into custom_types (
        vendor,
        name,
        id,
        xtype_long_classic,
        extendsxtype_classic,
        xtype_long_modern,
        extendsxtype_modern
    )
values (
        "Tualo",
        "Tualo.project.form.field.Contacts",
        "Tualo.project.form.field.Contacts",
        "widget.tualo_projectmanagement_contacts",
        "Ext.form.field.ComboBox",
        "widget.textarea",
        "Ext.field.Text"
    ) on duplicate key
update id =
values(id),
    xtype_long_classic =
values(xtype_long_classic),
    extendsxtype_classic =
values(extendsxtype_classic),
    name =
values(name),
    vendor =
values(vendor);