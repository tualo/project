Ext.define('Tualo.project.lazy.controller.SelectiveProjectPreview', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.selective_project_preview',



    onBoxReady: function () {
        let me = this;
        me.token = Ext.util.History.getToken();
        /*
        let me = this,
            vm = me.getViewModel(),
            st = me.getStore('subprojects'),
            newFilter = new Ext.util.Filter({
                property: 'parent_project',
                operator: 'eq',
                value: vm.get('project_id')
            });

        st.clearFilter();
        st.addFilter(newFilter);
        st.load();
        // setTimeout(me.queryUser.bind(me), 1000)
        */


    },
    loadProject: async function () {
        let me = this,
            vm = me.getViewModel(),
            st = me.getStore('subprojects'),
            newFilter = new Ext.util.Filter({
                property: 'sel',
                operator: 'eq',
                value: vm.get('project_id')
            });
        console.log('loadProject', vm.get('project_id'), st, newFilter);
        st.clearFilter();
        st.addFilter(newFilter);
        st.addFilter(new Ext.util.Filter({
            property: 'invoice_id',
            operator: 'eq',
            value: 0
        }));

        st.load();
    },

    onSubprojectsLoad: async function (store, records, successful, operation, node, eOpts) {
        let me = this,
            vm = me.getViewModel();


        let res = await (await fetch('./ds/projectmanagement/read/' + vm.get('project_id'), {})).json();

        let project = res.data[0];
        vm.set('project', project);


        store.add({
            ...project,
            parent_project: vm.get('project_id')
        })

        console.log('onSubprojectsLoad', res, store.getRange());
        me.fillTasks();
    },

    fillTasks: async function () {
        let me = this,
            vm = me.getViewModel(),
            su = me.getStore('subprojects'),
            rs = su.getRange(),
            ts = me.getStore('tasks');

        /*
        for (let i = 0; i < rs.length; i++) {
        
        
        let res = await (await fetch('./ds/projectmanagement_tasks/read', {
            method: 'post',
            body: JSON.stringify({
                limit: 10000,
                filter: [
                    { property: 'project_id', operator: 'eq', value: rs[i].get('project_id') },
                    { property: 'current_translator', operator: 'is not null', value: null },
                    { property: 'current_translator', operator: 'neq', value: '' },
                    { property: 'article', operator: 'in', value: ['Dolmetschen', 'Übersetzung', 'Dokumentübersetzung'] }
                ]
            })
        })).json();
        if (res.success) {
            res.data.forEach(r => {
                ts.add(r);
            });
        }
        }
        
        me.___mails = [];
        ts.getRange().forEach(r => {
        let cmp = Ext.create('Tualo.cmp.mail.commands.SendPUGMail', {
            records: [r],
            record: r,
            selectedrecords: [r],
        });
        cmp.on('mailformLoaded', function (v) {
            cmp.setTitle('Mail an ' + v.mailto + ' (' + v.mailsubject + ')');
            console.log('mailformLoaded', v);
        });
        mailpanel.add(cmp);
        me.___mails.push(cmp);
        cmp.loadRecord(r, [r], [r]);
        });
        mailpanel.show();
        startpanel.hide();
        console.log('fillTasks', ts.getRange());
        */
    },
    onCancel: function () {
        /*
        console.log('onCancel#*', this.token, Ext.util.History.getToken());
        while (Ext.util.History.getToken() !== this.token) {
            Ext.History.back();
            console.log('onCancel#*', this.token, Ext.util.History.getToken());
        }
            */
        Ext.History.back();

    },

    getSelectedIds: function () {

        let me = this,
            vm = me.getViewModel(),
            st = me.getStore('subprojects'),
            rn = st.getRange(),
            mn = null,
            ids = [];
        rn.forEach((r) => {
            if (r.get('toinvoice') === true) {
                console.log('toinvoice', r.get('name'), r.get('project_id'));
                ids.push(r.get('project_id'));
            }
        });
        return ids;
    },
    onDataChanged: async function (btn) {
        let me = this,
            vm = me.getViewModel(),
            st = me.getStore('subprojects'),
            rn = st.getRange(),
            mn = null,
            ids = this.getSelectedIds();


        /*
    me.getView().getComponent('layoutPanel').getComponent('iframe').load(
        './pugreporthtml/view_blg_listrechnung/report_2025_content/' + vm.get('project_id') + '?ids=[\'' + ids.join("','") + '\']',
    );
    */

        let res = await fetch('./pugreporthtml/view_blg_listrechnung/report_2025_content/' + vm.get('project_id') + '?ids=[\'' + ids.join("','") + '\']', {
            method: 'GET'
        });
        res = await res.text();
        console.log('onDataChanged', res);
        window.frame = me.getView().getComponent('layoutPanel').getComponent('iframe');
        me.getView().getComponent('layoutPanel').getComponent('iframe').getEl().el.dom.firstChild.innerHTML = (res);
        console.log('onDataChanged', '---');
    },

    onDo: async function (btn) {
        let me = this;

        let res = await fetch('./project/convert2bill', {
            method: 'PUT',
            body: JSON.stringify({
                project_id: me.getViewModel().get('project_id'),
                ids: me.getSelectedIds()
            })
        });
        res = await res.json();


        if (res.success !== true) {
            Ext.toast({
                html: res.msg,
                title: 'Fehler',
                align: 't',
                iconCls: 'fa fa-warning'
            });
        } else {
            window.open('./remote/pdf/view_blg_list_rechnung/report_template/' + res.data.id, '_blank');

        }
        return res;

    }
});
