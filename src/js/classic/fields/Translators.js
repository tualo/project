Ext.define('Tualo.project.form.field.Translators', {
    extend: 'Ext.form.field.ComboBox',
    alias: ['widget.tualo_projectmanagement_translators'],
    // store: {type:'array'},
    valueField: 'kundennummer',
    displayField: 'name',
    anchor: '100%',
    maxLength: 255,
    // queryMode: 'local',
  
    constructor: function(config) {
        this.store = Ext.create('Tualo.DataSets.store.Translator_dd_view', { });
        this.callParent([config]);
        this.store.on('beforeload',this.onStoreBeforeLoad,this);
        this.getStore().load();
    },
    onStoreBeforeLoad: function(store, operation, eOpts){
        let extraParams = store.getProxy().getExtraParams(),
            reference = {},
            r = this.getCurrentRecord();

            if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (r){
            //( store, operation, eOpts ) 
            reference = {
                target_language: r.get('target_language'),
                source_language: r.get('source_language'),
                article: r.get('article'),
            }
            extraParams.reference = Ext.JSON.encode(reference);
        }
        store.getProxy().setExtraParams(extraParams);
        console.log('onStoreBeforeLoad','tualo_projectmanagement_translators',this.getCurrentRecord());
    },

    getCurrentRecord: function(){
        var fld = this;
        if (fld.column){ 
            console.log('initComponent','tualo_projectmanagement_translators','column',fld.column);
            if (fld.column.view){ console.log('initComponent','tualo_projectmanagement_translators','view',fld.column.view);
                if (fld.column.view.grid) return fld.column.view.grid.getSelection()[0];
            }
        }else{
            if (fld.up('form')) return fld.up('form').getRecord();
        }
        return null;
    },  

    initComponent: function() {
        var fld = this;

        console.log('initComponent','tualo_projectmanagement_translators',fld);
        this.callParent();
        this.on('focus',function(){
            console.log('focus','tualo_projectmanagement_translators',fld);
            var r = fld.getCurrentRecord();
            if (r){
                var v = r.data;
                console.log('focus','tualo_projectmanagement_translators',fld,v);
                /*
                if (!Ext.isEmpty(v['table_name'])){
                    fld.tablename = v['table_name'];
                    fld.store.load();
                }*/
            }
        });
        /*
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
        */
    }
})