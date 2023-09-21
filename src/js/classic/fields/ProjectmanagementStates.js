Ext.define('Tualo.project.form.field.ProjectmenagementStates', {
    alias: ['widget.projectmenagementstates'],
    extend: 'Ext.form.field.ComboBox',
    store: {type:'array'},
    constructor: function(config) {
      this.store = Ext.create('Tualo.DataSets.store.Projectmanagement_states', {
      });
      this.callParent([config]);
    },
    typeAhead: true,
    triggerAction: 'all',
    lazyRender:true,
    mode: 'local',
    tpl: '<tpl for="."><div class="x-boundlist-item"><i class="{icon}" style="color:{color};"></i>{name}</div></tpl>',
    displayField: 'name',
    valueField: 'code'
})
  