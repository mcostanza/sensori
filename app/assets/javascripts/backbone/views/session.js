Sensori.Views.Session = Backbone.View.extend({

  events: {
    "click [data-trigger='save']": "submitForm",
    "click [data-trigger='remove-sample-pack']": "removeSamplePack",
    "click [data-trigger='add-sample-pack']": "addSamplePack"
  },

  submitForm: function() {
    if (this.$saveButton.hasClass("disabled")) { return; }
      
    this.collection.each(this.renderHiddenInputsForSamplePack, this);

    this.$form.submit();
  },

  renderHiddenInputsForSamplePack: function(samplePack) {
    var $nameInput = $("<input>")
      .attr("type", "hidden")
      .attr("name", "sample_packs[][name]")
      .val(samplePack.get("attachment_name"));

    var $urlInput = $("<input>")
      .attr("type", "hidden")
      .attr("name", "sample_packs[][url]")
      .val(samplePack.get("attachment_url"));

    this.$form.append($nameInput);
    this.$form.append($urlInput);
  },

  enableSaveButton: function() {
    this.$saveButton.removeClass("disabled");
  },

  disableSaveButton: function() {
    this.$saveButton.addClass("disabled");
  },

  addSamplePack: function() {
    this.collection.add();
    this.renderNewSamplePackUploader(this.collection.last());
  },

  removeSamplePack: function(model) {
    this.collection.remove(model);
    this.$("[data-cid=" + model.cid + "]").remove();
  },

  renderNewSamplePackUploader: function(samplePack) {
    var attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: samplePack,
      removeButton: true
    }).render();

    attachmentUploader.on("upload:add", this.disableSaveButton, this);
    attachmentUploader.on("upload:done", this.enableSaveButton, this);
    attachmentUploader.on("remove-attachment", this.removeSamplePack, this);

    var $attachmentUploaderContainer = $("<div>")
      .attr("data-cid", samplePack.cid)
      .append(attachmentUploader.$el);

    this.$(".attachments-container").append($attachmentUploaderContainer);
  },

  render: function() {
    this.$form = this.$("#session-form");
    this.$saveButton = this.$("[data-trigger='save']");
    this.collection.each(_.bind(this.renderNewSamplePackUploader, this));
    return this;
  }

});