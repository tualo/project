Ext.define('Tualo.cmp.project.commands.CreateSubProject', {
  statics: {
    glyph: 'asterisk',
    title: 'Teilprojekt anlegen',
    tooltip: 'Teilprojekt anlegen'
  },
  extend: 'Ext.panel.Panel',
  alias: 'widget.projectmanagement_createsubproject',
  layout: 'fit',
  items: [
    {
      xtype: 'form',
      itemId: 'ds_newkst_commandform',
      bodyPadding: '25px',
      items: [
        {
          xtype: 'label',
          text: 'Durch Klicken auf *Anlegen*, wird ein neues Teilprojekt angelegt',
        }
      ]
    }
  ],
  loadRecord: function (record, records, selectedrecords, view) {
    this.record = record;
    this.records = records;
    this.selectedrecords = selectedrecords;
    this.view = view;
    console.log('loadRecord', arguments);
  },
  getNextText: function () {
    return 'Anlegen';
  },
  passName: async function(record){
    let parent = Ext.getCmp(this.calleeId),
        tn=parent.getViewModel().get('record'),
        localstore = Ext.create( 
          Ext.ClassManager.getName(
            Ext.ClassManager.getByAlias('store.' + record.__table_name + '_store')
          ), {
              autoLoad: false,
              autoSync: false,
              pageSize: 100000,
              type: record.__table_name + '_store'
            }
        );
    return new Promise((resolve, reject) => {

        localstore.setFilters({
          property:  'project_folder',
          operator: 'eq',
          value: record.project_folder
        });
        localstore.load({
          scope: this,
          callback: function () {
            var r = localstore.getRange();
            record.name = this.record.get('name') +'-'+ ( (r.length+1)+'').padStart(2, '0');
            resolve(record);
          }
        });
      });
  },
  run: async function () {
    let parent = Ext.getCmp(this.calleeId),
        dsstore = parent.getViewModel().get('record').store,
        newObject = {...parent.getViewModel().get('record').data},
        tablenamecase = newObject.__table_name.toLocaleUpperCase().substring(0, 1) + newObject.__table_name.toLowerCase().slice(1);

        newObject.project_folder = newObject.project_id;
        newObject.__id = Ext.id();
        delete newObject.project_id;
        delete newObject.createdate;
        delete newObject.__id;



        let data = await this.passName(newObject);
        setTimeout(()=>{

          let record = Ext.create('Tualo.DataSets.model.'+tablenamecase,data);
          parent.getController().appendRecord(record);
          parent.getViewModel().set('isModified',true);
          parent.getViewModel().set('isNew',true);
          parent.getController().forcedSave();
          console.log('-');

        },1000)


    return null;
  }
});
