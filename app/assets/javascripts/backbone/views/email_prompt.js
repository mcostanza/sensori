Sensori.Views.EmailPrompt = Backbone.View.extend({
  template: JST["backbone/templates/shared/email_modal"],

  events: {
    "click #email-modal-save": "save",
    "keypress #email-modal-input": "saveOnEnter"
  },

  save: function() {
    var view = this;
    this.model.save({ email: this.$("#email-modal-input").val() }, {
      success: function() { 
        view.trigger("email:saved");
        view.emailModal.modal('hide');
      },
      error: function() { alert('error'); }
    });
  },

  saveOnEnter: function(e) { 
    if(e.keyCode == 13) { this.save(); }
  },

  render: function() {
    var view = this;
    if(!this.emailModal) {
      this.$el.append(this.template({
        message: this.options.message
      }));
      this.emailModal = this.$("#email-modal");
      this.emailModal.on("hide", function() { view.trigger("hide"); });
      this.emailModal.on("shown", function() { view.$("#email-modal-input").focus(); });
    }
    this.emailModal.modal('show');
    return this;
  }
});
