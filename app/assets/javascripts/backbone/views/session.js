Sensori.Views.Session = Backbone.View.extend({

  events: {
    "click [data-trigger='save']": "submitForm"
  },

  submitForm: function() {
    if (this.saveButton.hasClass("disabled")) { return; }
    this.$("#session_attachment_url").val(this.model.get("attachment_url"));
    this.$("#session-form").submit();
  },

  enableSaveButton: function() {
    this.saveButton.removeClass("disabled");
  },

  disableSaveButton: function() {
    this.saveButton.addClass("disabled");
  },

  render: function() {
    this.saveButton = this.$("[data-trigger='save']");

    this.attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: this.model,
      el: this.$(".attachment-container")
    }).render();

    this.attachmentUploader.on("upload:add", this.disableSaveButton, this);
    this.attachmentUploader.on("upload:done", this.enableSaveButton, this);
    
    return this;
  }

});