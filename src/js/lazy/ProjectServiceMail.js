Ext.define('Tualo.project.lazy.ProjectServiceMail', {
    extend: 'Ext.panel.Panel',
    requires: [
        'Tualo.project.lazy.models.ProjectServiceMail',
        'Tualo.project.lazy.controller.ProjectServiceMail'
    ],
    alias: 'widget.project_service_mail',
    controller: 'project_service_mail',

    viewModel: {
        type: 'project_service_mail'
    },
    listeners: {
        boxReady: 'onBoxReady'
    },

    layout: 'fit',
    config: {
        project_id: null
    },
    applyProject_id: function (project_id) {
        console.log('applyProject_id', project_id);
        this.getViewModel().set('project_id', project_id);
        this.getController().loadProject();
        return project_id;
    },
    updateProject_id: function (project_id) {
        console.log('updateProject_id', project_id);
        this.getViewModel().set('project_id', project_id);
        this.getController().loadProject();
    },
    items: [

        {
            hidden: false,
            xtype: 'panel',
            itemId: 'startpanel',
            layout: {
                type: 'vbox',
                align: 'center'
            },
            items: [
                {
                    xtype: 'component',
                    cls: 'lds-container-compact',
                    html: '<div class=" "><div class="blobs-container"><div class="blob gray"></div></div></div>'
                        + '<div><h3>Projektmails</h3>'
                        + '<span>Einen Moment, die Daten werden geprüft.</span></div>'
                }
            ]
        },
        {
            hidden: true,
            itemId: 'mailpanel',
            layout: {
                // layout-specific configs go here
                type: 'accordion',
                titleCollapse: true,
                animate: false,
                activeOnTop: false
            },
            items: [
            ]
        }
    ],
    dockedItems: [{
        xtype: 'toolbar',
        dock: 'bottom',
        items: [
            { xtype: 'button', text: 'Abbrechen', handler: 'onCancel' },
            '->',
            { xtype: 'button', text: 'Alle senden', handler: 'onSendAll' }
        ]
    }]


});
