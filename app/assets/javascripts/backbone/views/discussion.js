Sensori.Views.Discussion = Backbone.View.extend({
  initialize: function() {
    this.postButton = this.$("[data-trigger='post']");
    this.subjectInput = this.$("#discussion_subject");
    this.bodyInput = this.$("#discussion_body");
    this.membersOnlyCheckbox = this.$("#discussion_members_only");
    this.validatesPresenceOf(this.subjectInput);
    this.validatesPresenceOf(this.bodyInput);
    this.render();
  },

  events: {
    "click [data-trigger='post']": "process"
  },

  process: function(event) {
    if(!this.validate()) { return; }
    var view = this;
    this.disablePostButton();

    if(Sensori.Member.has('email')) {
      this.save();
    } else { 
      this.promptForEmail();
    }
  },

  save: function() {
    var view = this;
    var attributes = {
      subject: this.subjectInput.val(),
      body: this.bodyInput.val(),
      members_only: this.membersOnlyCheckbox.prop('checked')
    };
    this.model.save(attributes, {
      success: function() {
        Sensori.redirect(view.model.url());
      },
      error: function(e) { console.log(e); }
    });
  },

  render: function() {
    this.subjectInput.val(this.model.get("subject"));
    this.bodyInput.val(this.model.get("body"));
    this.membersOnlyCheckbox.prop("checked", this.model.get("members_only"));
  },

  promptForEmail: function() {
    if(!this.emailPrompt) {
      this.emailPrompt = new Sensori.Views.EmailPrompt({ 
        model: Sensori.Member,
        message: "Email address to send response notifications:"
      });
      this.listenTo(this.emailPrompt, "email:saved", this.process);
      this.listenTo(this.emailPrompt, "hide", this.enablePostButton);
      this.$el.append(this.emailPrompt.render().el);
    }
    this.emailPrompt.show();
  },

  enablePostButton: function() { this.postButton.prop('disabled', false); },

  disablePostButton: function() { this.postButton.prop('disabled', true); }

});

_.extend(Sensori.Views.Discussion.prototype, Sensori.Mixins.Validations);
