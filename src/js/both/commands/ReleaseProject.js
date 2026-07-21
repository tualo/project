Ext.define('Tualo.cmp.project.commands.ReleaseProject', {
  statics: {
    glyph: 'cogs',
    title: 'Freistellen',
    tooltip: 'Freistellen'
  },
  extend: 'Ext.panel.Panel',
  alias: ['widget.release_project_command'],
  layout: 'fit',
  items: [
    {
      xtype: 'form',
      itemId: 'releaseProject_commandform',
      bodyPadding: '25px',
      items: [
        {
          xtype: 'label',
          text: 'Durch klicken auf *Freistellen*, wird Das Projekt freigestellt',
        }
      ]
    }
  ],
  getNextText: function () {
    return 'Freistellen';
  },
  run: async function () {
    let result = await Tualo.Fetch.post('./dsrun/releaseProject', {
      list: Ext.JSON.encode([this.record.get('project_id')])
    });
    if (!result.success) {
      Ext.toast({
        html: result.msg,
        title: 'Fehler',
        align: 't',
        iconCls: 'fa fa-warning'
      });
    }
    this.record.store.load();
    return result;
  },
  loadRecord: function (record, records, selectedrecords) {
    this.record = record;
    this.records = records;
    this.selectedrecords = selectedrecords;
    console.log('loadRecord', arguments);
  }
});