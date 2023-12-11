Ext.define('Tualo.project.form.field.Translators', {
    extend: 'Ext.form.field.Text',
    alias: ['widget.tualo_projectmanagement_translators'],
    // store: {type:'array'},
    valueField: 'id',
    displayField: 'id',
    anchor: '100%',
    queryMode: 'local',
  
    initComponent: function() {
        var fld = this;
        console.log('initComponent','tualo_projectmanagement_translators',fld);
        setTimeout(()=>{
            fld.view.grid.on('edit',function(editor, e){
                console.log('edit',editor,e);
                // fld.view.grid.getStore().sync();
            });
    
        }, 5000);
        window.tualo_projectmanagement_translators = fld;
    }
})