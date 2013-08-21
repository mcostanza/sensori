Sensori.Views.EmailPrompt = Backbone.View.extend({
  template: JST["backbone/templates/shared/email_modal"],

  events: {
    "click #email-modal-save": "save",
    "keypress #email-modal-input": "saveOnEnter"
  },

  save: function() {
    if(!this.validate()) { return; }
    var view = this;
    this.model.save({ email: this.emailInput.val() }, {
      success: function() { 
        view.trigger("email:saved");
        view.hide();
      },
      error: function() { alert('error'); }
    });
  },

  saveOnEnter: function(e) { 
    if(e.keyCode == 13) { this.save(); }
  },

  render: function() {
    if(!this.emailModal) {
      this.$el.append(this.template({ message: this.options.message }));

      this.emailModal = this.$("#email-modal");
      this.emailInput = this.$("#email-modal-input");

      var view = this;
      this.emailModal.on("hide", function() { view.trigger("hide"); });
      this.emailModal.on("hidden", function() { view.trigger("hidden"); });
      this.emailModal.on("show", function() { view.trigger("show"); });
      this.emailModal.on("shown", function() { view.trigger("shown"); });
      this.emailModal.on("shown", function() { view.emailInput.focus(); });
      this.emailInput.on("focus", function() { view.emailInput.closest(".control-group").removeClass("error"); });

    }
    return this;
  },

  validate: function() {
    if(_.isNull(this.emailInput.val().match(Sensori.Validations.email))) {
      this.emailInput.closest(".control-group").addClass("error");
      return false;
    } else {
      this.emailInput.closest(".control-group").removeClass("error");
      return true;
    }
  },

  show: function() { this.emailModal.modal('show'); },
  
  hide: function() { this.emailModal.modal('hide'); },
});
