Ext.define('Tualo.project.lazy.SelectiveProjectPreview2', {
    extend: 'Ext.panel.Panel',
    requires: [
        'Tualo.project.lazy.models.SelectiveProjectPreview2',
        'Tualo.project.lazy.controller.SelectiveProjectPreview2'
    ],
    alias: 'widget.selective_project_preview2',
    controller: 'selective_project_preview2',

    viewModel: {
        type: 'selective_project_preview2'
    },
    listeners: {
        boxReady: 'onBoxReady'
    },

    layout: 'fit',
    config: {
        project_id: null
    },
    applyProject_id: function (project_id) {
        this.getViewModel().set('project_id', project_id);
        this.getController().loadProject();
        return project_id;
    },
    updateProject_id: function (project_id) {
        this.getViewModel().set('project_id', project_id);
        this.getController().loadProject();
    },
    items: [
        {
            xtype: 'panel',
            itemId: 'layoutPanel',

            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [{
                flex: 1,
                xtype: 'grid',
                features: [{
                    ftype: 'rowbody',
                    getAdditionalData: function (data, idx, record, orig) {
                        // Usually you would style the my-body-class in a CSS file
                        return {
                            rowBody: '<div style="padding: 1em">' + record.get("description") + '</div>',
                            rowBodyCls: "my-body-class"
                        };
                    }
                }],
                bind: {
                    store: '{subprojects}'
                },
                columns: [
                    { text: 'ST', dataIndex: 'state', xtype: 'projectmanagement_states_column', width: 32 },
                    { text: 'RN', dataIndex: 'toinvoice', xtype: 'checkcolumn', width: 32 },
                    { text: 'ID', dataIndex: 'id', width: 50, hidden: true },
                    { text: 'Name', dataIndex: 'name', flex: 1 },
                    { text: 'Status', dataIndex: 'state', width: 150, hidden: true },
                    { text: 'Zieldatum', dataIndex: 'target_date', width: 120, xtype: 'datecolumn', format: 'd.m.Y' },
                ],
                listeners: {
                    load: 'onSubprojectsLoad'
                },
                split: true,
            },

            {
                flex: 3,
                itemId: 'iframe',
                xtype: 'panel',
                html: '<div style="margin: 24px; all: initial; max-width: 21cm;">Bitte wählen Sie links die Projekte aus, die in Rechnung gestellt werden sollen.</div>',

            }
            ]
        }
    ],
    dockedItems: [{
        xtype: 'toolbar',
        dock: 'bottom',
        items: [
            { xtype: 'button', text: 'Abbrechen', handler: 'onCancel' },
            '->',
            { xtype: 'button', text: 'Abrechnen', handler: 'onDo' }
        ]
    }]


});
