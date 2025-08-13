Ext.define('Tualo.project.lazy.models.SelectiveProjectPreviewUebersetzer', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.selective_project_preview_uebersetzer',
    data: {
        message: 'OK',

        state: 1,
        devicetoken_message: -1,
        devicetoken_expires_in: -1,
        devicetoken_interval: 1000,
        devicetoken_user_code: -1,
        devicetoken_verification_uri: '',

        displayName: '',
        email: ''
    },
    formulas: {
        ftitle: function (get) {
            let txt = 'MS Login';
            return txt;
        },

    },
    stores: {

        subprojects: {
            type: 'view_selective_project_preview_uebersetzer_store',
            autoLoad: false,
            listeners: {
                load: 'onSubprojectsLoad',
                datachanged: 'onDataChanged',
            }
        },
        tasks: {
            model: 'Tualo.DataSets.model.Projectmanagement_tasks',
            type: 'store',
            autoLoad: false
        },
    }
});
