Sensori.Views.Discussion = Backbone.View.extend({
  initialize: function() {
    this.postButton = this.$("[data-trigger='post']");
    this.subjectInput = this.$("#discussion_subject");
    this.bodyInput = this.$("#discussion_body");
    this.membersOnlyCheckbox = this.$("#discussion_members_only");
    this.validatesPresenceOf(this.subjectInput);
    this.validatesPresenceOf(this.bodyInput);
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

  disablePostButton: function() { this.postButton.prop('disabled', true); },

  renderAudioLink: function() {
    var a = $("<a>")
      .attr("href", this.model.get("attachment_url"))
      .attr("target", "_blank")
      .text(this.model.get("attachment_name"));

    this.$(".attachment-container .link-container").html(a)
  },

  render: function() {
    this.subjectInput.val(this.model.get("subject"));
    this.bodyInput.val(this.model.get("body"));
    this.membersOnlyCheckbox.prop("checked", this.model.get("members_only"));

    this.attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: this.model,
      el: this.$(".attachment-container"),
      template: "backbone/templates/discussions/attachment_uploader"
    }).render();
    this.attachmentUploader.on("upload:add", this.disablePostButton, this);
    this.attachmentUploader.on("upload:done", this.enablePostButton, this);
    this.attachmentUploader.on("upload:done", this.renderAudioLink, this);

    return this;
  }

});

_.extend(Sensori.Views.Discussion.prototype, Sensori.Mixins.Validations);
