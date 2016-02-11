Sensori.Views.Session = Backbone.View.extend({

  events: {
    "click [data-trigger='save']": "submitForm",
    "click [data-trigger='remove-sample-pack']": "removeSamplePack",
    "click [data-trigger='add-sample-pack']": "addSamplePack"
  },

  submitForm: function() {
    if (this.saveButton.hasClass("disabled")) { return; }
      
    var $form = this.$("#session-form");

    this.collection.each(_.bind(function(samplePack) {
      var $nameInput = $("<input>")
        .attr("type", "hidden")
        .val(samplePack.get("attachment_name"))
        .attr("name", "sample_packs[][name]");

      var $urlInput = $("<input>")
        .attr("type", "hidden")
        .val(samplePack.get("attachment_url"))
        .attr("name", "sample_packs[][url]");

      $form.append($nameInput);
      $form.append($urlInput);
    }, this));


    $form.submit();
  },

  enableSaveButton: function() {
    this.saveButton.removeClass("disabled");
  },

  disableSaveButton: function() {
    this.saveButton.addClass("disabled");
  },

  addSamplePack: function() {
    this.collection.add();
    this.renderNewSamplePackUploader(this.collection.last());
  },

  removeSamplePack: function(event) {
    $(event.target).closest("[data-sample-pack]").remove();
  },

  renderNewSamplePackUploader: function(samplePack) {
    var attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: samplePack
    }).render();

    attachmentUploader.on("upload:add", this.disableSaveButton, this);
    attachmentUploader.on("upload:done", this.enableSaveButton, this);

    var $attachmentUploaderContainer = $("<div>")
      .data("sample-pack", true)
      .append(attachmentUploader.$el)
      .append("<button data-trigger='remove-sample-pack'>Remove</button>");

    this.$(".attachments-container").append($attachmentUploaderContainer);
  },

  render: function() {
    this.saveButton = this.$("[data-trigger='save']");
    this.collection.each(_.bind(this.renderNewSamplePackUploader, this));
    return this;
  }

});