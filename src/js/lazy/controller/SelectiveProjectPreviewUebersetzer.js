Ext.define('Tualo.project.lazy.controller.SelectiveProjectPreviewUebersetzer', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.selective_project_preview_uebersetzer',



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
                value: vm.get('kundennummer')
            });

        st.clearFilter();
        st.addFilter(newFilter);
        /*st.addFilter(new Ext.util.Filter({
            property: 'invoice_id',
            operator: 'eq',
            value: 0
        }));
        */

        st.load();
    },

    onSubprojectsLoad: async function (store, records, successful, operation, node, eOpts) {
        let me = this,
            vm = me.getViewModel();

        if (records.length === 0) {
            Ext.toast({
                html: 'Keine Unterprojekte gefunden',
                title: 'Info',
                align: 't',
                iconCls: 'fa fa-info'
            });
            return;
        }
        vm.set('project_id', records[0].get('project_id'));
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


    },
    onCancel: function () {

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

        let res = await fetch('./pugreporthtml/view_blg_list_gs/report_2025_content/' + ids[0] + '?dlids=[\'' + ids.join("','") + '\']', {
            method: 'GET'
        });
        res = await res.text();

        extractStyles = me.extractStyles(res);
        if (extractStyles) {
            let styleNode = document.createElement('style');
            styleNode.innerHTML = extractStyles;
            document.head.appendChild(styleNode);
        }

        let html = me.splitInnerBodyTagHtml(res);
        let node = document.createElement('div');
        node.innerHTML = html;
        if (node.querySelector('table > tbody > tr > td') === null) {
            Ext.toast({
                html: 'Keine Daten gefunden',
                title: 'Info',
                align: 't',
                iconCls: 'fa fa-info'
            });
            return;
        }
        html = node.querySelector('table > tbody > tr > td').innerHTML;
        // let head = node.querySelector('head');
        // window.frame = me.getView().getComponent('layoutPanel').getComponent('iframe');
        me.getView().getComponent('layoutPanel').getComponent('iframe').getEl().el.dom.firstChild.style.padding = '1cm';
        me.getView().getComponent('layoutPanel').getComponent('iframe').getEl().el.dom.firstChild.innerHTML = html;

    },

    extractStyles: function (html) {
        // Extrahiere alle <style>-Tags aus dem HTML
        const styleTags = html.match(/<style[^>]*>([\s\S]*?)<\/style>/gi) || [];
        let styles = '';
        styleTags.forEach(tag => {
            // Extrahiere den Inhalt des <style>-Tags
            const styleContent = tag.replace(/<style[^>]*>/i, '').replace(/<\/style>/i, '');
            styles += styleContent + '\n';
        });
        return styles;
    },

    splitInnerBodyTagHtml: function (html) {
        // Verschiedene Body-Tag Patterns (von spezifisch zu allgemein)
        const patterns = [
            /<body(?:\s+[^>]*)?>/i,           // Standard Pattern
            /<body\s*[^>]*>/i,               // Mit optionalen Whitespaces
            /<body[^>]*>/i,                  // Einfacheres Pattern
            /<body>/i                        // Fallback ohne Attribute
        ];

        for (let pattern of patterns) {
            try {
                let bodyStartMatch = html.match(pattern);
                let bodyEndMatch = html.match(/<\/body>/i);

                if (bodyStartMatch && bodyEndMatch) {
                    let bodyStart = bodyStartMatch.index + bodyStartMatch[0].length;
                    let bodyEnd = bodyEndMatch.index;

                    if (bodyStart < bodyEnd) {
                        return html.substring(bodyStart, bodyEnd);
                    }
                }
            } catch (error) {
                console.warn('Pattern fehlgeschlagen:', pattern, error);
                continue;
            }
        }

        // Ultimo Fallback: versuche mit DOM Parser
        try {
            let parser = new DOMParser();
            let doc = parser.parseFromString(html, 'text/html');
            let bodyElement = doc.body;

            if (bodyElement) {
                return bodyElement.innerHTML;
            }
        } catch (error) {
            console.error('DOM Parser Fallback fehlgeschlagen:', error);
        }

        console.warn('Alle Body-Parsing-Methoden fehlgeschlagen, gebe Original-HTML zurück');
        return html;
    },
    onDo: async function (btn) {
        let me = this;

        let a = me.getSelectedIds();

        let res = await fetch('./project/convertdl', {
            method: 'PUT',
            body: JSON.stringify({
                project_id: a[0],
                ids: a
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
            window.open('./remote/pdf/view_blg_list_gs/report_template/' + res.data.id, '_blank');

        }
        return res;

    }
});
