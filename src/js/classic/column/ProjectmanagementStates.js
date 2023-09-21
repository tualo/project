Ext.define('Tualo.project.grid.column.ProjectmenagementStates', {
    extend: 'Tualo.cmp.cmp_ds.column.DS',
    alias: 'widget.projectmenagement_states_column',
    align: 'left',
    tablename: 'projectmenagement_states',
    renderer: function(value, metaData, record, rowIndex, colIndex, store, view ){
        try{
            let me = this,
                column = me.getColumns()[colIndex],
                configStore = column.configStore,
                storeId = configStore.storeId,
                store = Ext.data.StoreManager.lookup(storeId),
                renderRecord = null;
            if (store){
                if (store.loadCount==0 && !store.loading){ 
                    store.pageSize = 1000000;
                    store.load({
                        callback: function(){
                           me.getView().refresh();
                        }
                    });
                }
                renderRecord = store.findRecord( column.idField , value,0,false,false,true);
                value = '<i class="'+renderRecord.get('icon')+'" style="color:'+renderRecord.get('color')+'">'+'</i>'+value;
                /*if (renderRecord){
                    value =  renderRecord.get(column.displayField);
                }else{
                    metaData.tdStyle = "color: rgb(200,30,30)";
                }*/
            }
        }catch(e){
            console.debug(e)
        }
        return value;
    }
});