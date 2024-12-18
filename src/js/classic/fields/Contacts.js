Ext.define('Tualo.project.form.field.Contacts', {
    extend: 'Ext.form.field.ComboBox',
    alias: ['widget.tualo_projectmanagement_contacts'],

    valueField: 'id',
    displayField: '__displayfield',
    anchor: '100%',
    maxLength: 255,

    minChars: 2,    

    onChange: function(newVal, oldVal) {
        var me = this,
            cur = me.getCurrentRecord();
        
        console.log(
            'tualo_projectmanagement_contacts',
            'onChange',
            newVal,
            oldVal
        )
        
        me.refreshFilterStore();
        window.tualo_projectmanagement_contacts = me;
        document.getElementById(me.id+'-trigger-makeacall').setAttribute("href","javascript: void(0)");
        me.triggers.makeacall.setTooltip('Es ist keine Telefonnummer hinterlegt.');

        me.callParent([newVal, oldVal]);
        me.setTriggerAttribute(newVal);
    },

    setTriggerAttribute: function(newVal){
        let me = this;
        if (newVal!=null){
            let r = me.getStore().findRecord( 'id', newVal, 0, false, true,true ) ;
            if (r==null){

            }
            if (!Ext.isEmpty(r) && !(Ext.isEmpty(r.get('telefon')))){
                me.triggers.makeacall.setTooltip( r.get('telefon')+' anrufen' );
                document.getElementById(me.id+'-trigger-makeacall').setAttribute("href","tel:"+r.get('telefon'));
            }
        }
    },

    triggers: {
        opends: {
            cls: 'x-fa fa-link',
            tooltip: "Den Datensatz öffnen",
            handler: function(btn) {
                let route = "#ds/ansprechpartner/id/"+btn.getValue();
                if (btn.getSelectedRecord()==null){
                    btn.getStore().load({
                        callback: function(){
                            window.open(route,'_blank');
                        }
                    })
                }else{
                    window.open(route,'_blank');
                }
            }
        },
        makeacall: {
            cls: 'fa-phone',
            tooltip: "Anrufen",
            renderTpl: [
                '<a href="javascript: void(0)" id="{triggerId}" class="{baseCls} {baseCls}-{ui} {cls} {cls}-{ui} {extraCls} ',
                        '{childElCls}" style="width: 32px;<tpl if="triggerStyle">{triggerStyle}</tpl>"',
                        '<tpl if="ariaRole"> role="{ariaRole}"<tpl else> role="presentation"</tpl>',
                    '>',
                    '{[values.$trigger.renderBody(values)]}',
                '</a>'
            ],
            
            handler: function(me) {
                
                
            }
        }
    },

    constructor: function(config) {
        this.store = Ext.create('Tualo.DataSets.store.Ansprechpartner', { pageSize: 100000,remoteFilter:false });
        this.callParent([config]);
        this.store.on('beforeload',this.onStoreBeforeLoad,this);
        this.getStore().load();
    },
    refreshFilterStore: function(){
        let me = this,
            r = me.getCurrentRecord(),
            s = me.getStore();
        s.clearFilter(true);
        s.setFilters([
            new Ext.util.Filter({
                property: 'kundennummer',
                value: r.get('kundennummer'),
                operator: '='
            })
        ])
    },
    onStoreBeforeLoad: function(store, operation, eOpts){
        let extraParams = store.getProxy().getExtraParams(),
            reference = {},
            r = this.getCurrentRecord();

            if (Ext.isEmpty(extraParams)){ extraParams = {}; };
        if (r){
            /*
            reference = {
                kundennummer: r.get('kundennummer'),
            }
            this.last_filter_kn = r.get('kundennummer');
            */
            extraParams.reference = Ext.JSON.encode(reference);
        }
        store.getProxy().setExtraParams(extraParams);
    },

    getCurrentRecord: function(){
        var fld = this;
        if (fld.column){ 
            if (fld.column.view){ 
                if (fld.column.view.grid) return fld.column.view.grid.getSelection()[0];
            }
        }else{
            if (fld.up('form')) return fld.up('form').getRecord();
        }
        
        return null;
    },  

    initComponent: function() {
        var fld = this;

        this.callParent();
        this.on('focus',function(){
            var r = fld.getCurrentRecord();
            if (r){
                var v = r.data;
            }
        });
    }
})