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
  run: async function () {
    let parent = Ext.getCmp(this.calleeId),
        newrecord = parent.getController().cloneRecord();
    
    
        newrecord.set('project_folder', this.record.get('project_id'));

        var store = Ext.create(
            Ext.ClassManager.getName(Ext.ClassManager.getByAlias('store.' + newrecord.get('__table_name') + '_store')), 
            {
            autoLoad: false,
            autoSync: false,
            pageSize: 100000,
            type: newrecord.get('__table_name') + '_store'
        });
        store.setFilters({
          property:  'project_id',
          operator: 'eq',
          value: 'project_id'
        });
        store.load({

          callback: function () {
            var r = store.getRange();
            newrecord.set( 'name', this.record.get('name') + ( (r.length()+1)+'').padStart(2, '0') );
          }
        });
    return null;
  }
});
