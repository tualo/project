Ext.define('Tualo.project.lazy.controller.ProjectServiceMail', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.project_service_mail',



    onBoxReady: function () {
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
                property: 'parent_project',
                operator: 'eq',
                value: vm.get('project_id')
            });

        st.clearFilter();
        st.addFilter(newFilter);
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
            ts = me.getStore('tasks'),
            startpanel = me.getView().getComponent('startpanel'),
            mailpanel = me.getView().getComponent('mailpanel');

        for (let i = 0; i < rs.length; i++) {


            let res = await (await fetch('./ds/projectmanagement_tasks/read', {
                method: 'post',
                body: JSON.stringify({
                    limit: 10000,
                    filter: [
                        { property: 'project_id', operator: 'eq', value: rs[i].get('project_id') },
                        { property: 'current_translator', operator: 'is not null', value: null }
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
    },
    onCancel: function () {
        Ext.History.back();
    },
    onSendAll: async function (btn) {
        this.send(btn);
    },
    send: async function (btn) {
        let me = this,
            mails = me.___mails,
            vm = me.getViewModel(),
            su = me.getStore('subprojects'),
            rs = su.getRange(),
            ts = me.getStore('tasks');
        btn.disable();

        let p = Ext.create('Ext.ProgressBar', {
            text: 'Mails versenden ...',
        });
        // me.getView().disable();

        let m = new Ext.LoadMask({
            msg: 'Please wait...',
            target: me.getView()
        });
        m.show();

        let t = Ext.toast({
            items: p,
            width: 300,
            layout: 'fit',
            alignment: 'tc-tc',
            hideDuration: 3000000,
            //timeout: 2000
        });
        t.show();
        console.log('send mails', mails, mails.length);
        for (let i = 0; i < mails.length; i++) {
            p.updateValue((i + 1) / mails.length);
            console.log('send', mails[i].getComponent('mailform').getValues());
            await mails[i].run();
        }
        t.destroy();
        // btn.enable();
        Ext.History.back();
    },

});
