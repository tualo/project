Ext.define('Tualo.routes.SelectiveProjectPreview', {
    statics: {

        load: async function () {
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
    url: 'project/selectivepreview(\/:{project_id})',
    handler: {
        action: function (values) {

            let a = async function () {
                let res = await (await fetch('./ds/projectmanagement/read/' + values.project_id, {})).json();
                let project = res.data[0];

                let id = values.project_id;
                if (project.project_folder != '') {
                    id = project.project_folder;
                }
                console.log('project_id>>>>>>>>>>>>>>', id, values);
                let component = Ext.getApplication().addView('Tualo.project.lazy.SelectiveProjectPreview', {
                    project_id: id
                });

            }
            a();

        },
        before: function (values, action) {
            console.log('project_id before', id, values);
            values.lastroute = Ext.History.getToken();
            action.resume();
        }
    }
});


Ext.define('Tualo.routes.SelectiveProjectPreview2', {
    statics: {

        load: async function () {
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
    url: 'project/selectivepreview2(\/:{kundennummer})',
    handler: {
        action: function (values) {

            let a = async function () {
                /*
                let res = await (await fetch('./ds/projectmanagement/read/' + values.project_id, {})).json();
                let project = res.data[0];
*/
                let id = values.kundennummer;
                /*if (project.project_folder != '') {
                    id = project.project_folder;
                }*/
                console.log('project_id>>>>>>>>>>>>>>', id, values);
                let component = Ext.getApplication().addView('Tualo.project.lazy.SelectiveProjectPreview2', {
                    kundennummer: id
                });

            }
            a();

        },
        before: function (values, action) {
            values.lastroute = Ext.History.getToken();
            action.resume();
        }
    }
});




Ext.define('Tualo.routes.SelectiveProjectPreviewUebersetzer', {
    statics: {

        load: async function () {
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
    url: 'project/selectivepreview_uebersetzer(\/:{kundennummer})',
    handler: {
        action: function (values) {

            let a = async function () {
                /*
                let res = await (await fetch('./ds/projectmanagement/read/' + values.project_id, {})).json();
                let project = res.data[0];
*/
                let id = values.kundennummer;
                /*if (project.project_folder != '') {
                    id = project.project_folder;
                }*/
                console.log('project_id>>>>>>>>>>>>>>', id, values);
                let component = Ext.getApplication().addView('Tualo.project.lazy.SelectiveProjectPreviewUebersetzer', {
                    kundennummer: id
                });

            }
            a();

        },
        before: function (values, action) {
            values.lastroute = Ext.History.getToken();
            action.resume();
        }
    }
});
