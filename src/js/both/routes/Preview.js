Ext.define('Tualo.routes.ProjectPreview', {
    statics: {

        load: async function () {
            let response = await Tualo.Fetch.post('ds/blg_config/read', { limit: 10000 });
            let list = [];

            return list;
        },

        sha1: async function (str) {
            const enc = new TextEncoder();
            if (crypto.subtle) {
                const hash = await crypto.subtle.digest('SHA-1', enc.encode(str));
                return Array.from(new Uint8Array(hash))
                    .map(v => v.toString(16).padStart(2, '0'))
                    .join('');
            } else {
                return btoa(str).replace(/[^A-Za-z0-9]/g, '');
            }
        }
    },
    url: 'project/preview(\/:{tabellenzusatz}\/:{template}\/:{project_id})',
    handler: {
        action: function (values) {
            ///server/pugreporthtml/view_blg_list_angebot/report_2025_content/edf2043f-b791-11ef-9f90-002590c46e14?test=12356

            window.open('./pugreporthtml/view_blg_list' + values.tabellenzusatz + '/' + values.template + '/' + values.project_id, '_blank');
            Ext.util.History.back();

        },
        before: function (values, action) {
            action.resume();

        }
    }
});


