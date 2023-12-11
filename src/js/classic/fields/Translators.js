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
        this.callParent();

        if (fld.column){ 
            console.log('initComponent','tualo_projectmanagement_translators','column',fld.column);
            if (fld.column.view){ console.log('initComponent','tualo_projectmanagement_translators','view',fld.column.view);
                if (fld.column.view.grid) console.log('initComponent','tualo_projectmanagement_translators','grid',fld.column.view.grid)
            };
        }
        setTimeout(()=>{
            //#endregion
            if (fld.column){ 
                console.log('initComponent','tualo_projectmanagement_translators','column',fld.column);
                if (fld.column.view){ 
                    console.log('initComponent','tualo_projectmanagement_translators','view',fld.column.view);
                    if (fld.column.view.grid) {
                        console.log('initComponent','tualo_projectmanagement_translators','grid',fld.column.view.grid);
                        fld.column.view.grid.on('edit',function(editor, e){
                            console.log('edit',editor,e);
                            // fld.view.grid.getStore().sync();
                        });
                    }
                };
            }
    
        }, 5000);
        window.tualo_projectmanagement_translators = fld;
    }
})