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
            html: '<div class="lds-grid"><div class="blobs-container"><div class="blob green"></div></div>'
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
      let res= await fetch('./project/convert2offer',{
        method: 'PUT',
        body: JSON.stringify(this.record.getData())
      });
      if (res.success !== true){
        Ext.toast({
            html: res.msg,
            title: 'Fehler',
            align: 't',
            iconCls: 'fa fa-warning'
        });
      }
      return res;
    }
  });
