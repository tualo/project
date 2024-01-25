Ext.define('Tualo.cmp.project.commands.ConvertToOffer', {
    statics:{
      glyph: 'shipping-fast',
      title: 'In Angebot umwandeln',
      tooltip: 'In Angebot umwandeln'
    },
    extend: 'Ext.panel.Panel',
    alias: 'widget.convertproject',
    layout: 'fit',
    viewModel: {
        data: {
            messagetitle: '',
            messagetext: '',
        },
        stores: {
            attachments: {
                type: 'array',
                data: [],
                fields: [
                    {name: 'filename', type: 'string'},
                    {name: 'title', type: 'string'},
                    {name: 'size', type: 'string'},
                    {name: 'contenttype', type: 'string'},
                ]
            }
        }
    },
    items: [
      {
        hidden: false,
        xtype: 'panel',
        itemId: 'startpanel',
        layout:{
          type: 'vbox',
          align: 'center'
        },
        items: [
          {
            xtype: 'component',
            cls: 'lds-container',
            html: '<div class=" "><div class="blobs-container"><div class="blob green"></div></div></div>'
            +'<div><h3>Angebot erstellen</h3>'
            +'<span>Um das Angebot anzulegen, klicken Sie auf "Angebot erstellen"</span></div>'
          }
        ]
        

      },{
        hidden: true,
        xtype: 'panel',
        itemId: 'waitpanel',
        layout:{
          type: 'vbox',
          align: 'center'
        },
        items: [
          {
            xtype: 'component',
            cls: 'lds-container',
            html: '<div class="lds-grid"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>'
            +'<div><h3>Die Mail wird gesendet</h3>'
            +'<span>Einen Moment bitte ...</span></div>'
          }
        ]
      }
    ],
    loadRecord: function(record,records,selectedrecords){
      this.record = record;
      this.records = records;
      this.selectedrecords = selectedrecords;
      
      if (this.record.get('offer_id')>0){

        Ext.toast({
          html: "Das Projekt wurde bereits in ein Angebot umgewandelt.<br/>Sie können aber ein neues Angebot erstellen.",
          title: 'Hinweis',
          align: 't',
          iconCls: 'fa fa-warning'
      });
      }


      this.getComponent('startpanel').show(); 
      this.getComponent('waitpanel').hide();
    },
    
    getNextText: function(){
      return 'Angebot erstellen';
    },
    run: async function(){
      let me = this;
      me.getComponent('startpanel').hide();
      me.getComponent('waitpanel').show();

      let res = await fetch('./project/convert2offer',{
        method: 'PUT',
        body: JSON.stringify(this.record.getData())
    });
    res = await res.json();

      
      if (res.success !== true){
        Ext.toast({
            html: res.msg,
            title: 'Fehler',
            align: 't',
            iconCls: 'fa fa-warning'
        });
      }else{
        this.record.set('offer_id',res.data.id);
        setTimeout(()=>{
          let store = Ext.create('Tualo.DataSets.store.View_blg_list_angebot',{
            autoLoad: false
          });
          store.on('load',()=>{

            /*
            let view = Ext.getApplication().addView('Tualo.cmp.mail.commands.SendPUGMail');  
            view.loadRecord(store.getRange()[0],store.getRange(),store.getRange());
            */
            Ext.getApplication().addView('Tualo.ds.lazy.DeferedCommand',{
              tablename: 'view_blg_list_angebot',
              command: 'sendpugmail',
              record: idstore.getRange()[0]
            });

  
          });
          store.filter([{property: 'id', value: res.data.id,operator: '='}]);
          store.load();

        },200);

      }
      return res;
    }
  });
