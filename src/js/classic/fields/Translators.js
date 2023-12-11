Ext.define('Tualo.project.form.field.Translators', {
    extend: 'Ext.form.field.Textfield',
    alias: ['widget.tualo_projectmanagement_translators'],
    valueField: 'id',
    displayField: 'id',
    anchor: '100%',
    queryMode: 'local',
  
    initComponent: function() {
        var fld = this;
        console.log('initComponent','tualo_projectmanagement_translators',fld);
        window.tualo_projectmanagement_translators = fld;
    }
})