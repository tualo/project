Ext.Loader.setPath('Tualo.project.lazy', './jsproject');

Ext.define('Tualo.routes.ProjectServiceMail', {
    statics: {

        load: async function () {
            let response = await Tualo.Fetch.post('ds/blg_config/read', { limit: 10000 });
            let list = [];
            if (response.success == true) {
                for (let i = 0; i < response.data.length; i++) {
                    if (!Ext.isEmpty(response.data[i].table_name))
                        list.push({
                            name: response.data[i].name + ' (' + '#project/servicemail/{project_id})',
                            path: '#project/servicemail/{project_id}'
                        });
                }
            }
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
    url: 'project/servicemail(\/:{project_id})',
    handler: {
        action: function (values) {
            component = Ext.getApplication().addView('Tualo.project.lazy.ProjectServiceMail', {
                project_id: values.project_id
            });
        },
        before: function (values, action) {
            action.resume();
        }
    }
});
