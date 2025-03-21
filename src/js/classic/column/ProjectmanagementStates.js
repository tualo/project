Ext.define('Tualo.project.grid.column.ProjectmanagementStates', {
    extend: 'Tualo.cmp.cmp_ds.column.DS',
    alias: 'widget.projectmanagement_states_column',
    align: 'left',
    tablename: 'projectmanagement_states',
    configStore: {
        type: 'ds_projectmanagement_states',
        storeId: 'ds_projectmanagement_states_columnstore',
        pageSize: 1000000
    },
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
                renderRecord = store.findRecord( 'id' , value,0,false,false,true);

                value = '<i class="'+renderRecord.get('icon')+'" style="color:'+renderRecord.get('color')+'; text-shadow: 0 0 5px black;margin-right: 12px;"> '+'</i> '+renderRecord.get('name');
            }

            let useStyles = [];

            // 'record.target_date < 2387 && ( state==a  || state==b || ) ' 
            if (
                record.get('target_date')<(new Date()) && 
                value!=null &&
                [20009,30005,20011].indexOf(record.get('state'))>=0
            ){
                useStyles.push("background-color: rgba(200,30,30,0.2)");
            }
            
            if (
                record.get('invoice_id')!=0
            ){
                useStyles.push("font-weight: lighter;");
            }else{
                useStyles.push("font-weight: normal;");
            }

            metaData.tdStyle = useStyles.join(';');
            
            

        }catch(e){
            console.debug(e)
        }
        return value;
    }
});