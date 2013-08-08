Sensori.Views.Tutorial = Backbone.View.extend({

  initialize: function() {
    this.subviews = [];

    this.model.on("change:id", this.redirectToEditURL, this);
    this.model.on("change:attachment_url", this.renderAttachmentDownloadButton, this);
  },

  events: {
    "click [data-trigger='save-tutorial']": "save",
    "click [data-trigger='publish-tutorial']": "publish",
    "click [data-trigger='preview-tutorial']": "preview",
    "click [data-trigger='view-tutorial']": "show",
    "click [data-trigger='add-more']": "addMore"
  },

  addMore: function() {
    this.addComponent({ type: "text" });
    this.addComponent({ type: "gallery" });
  },

  addComponent: function(options) {
    if (options.type === "text") {
      this.addTextEditor(options.content);
    } else if (options.type === "gallery") {
      this.addGalleryEditor(options.content);
    }
  },

  addTextEditor: function(content) {
    var subview = new Sensori.Views.TextEditor({ 
      content: content 
    }).render();

    this.subviews.push(subview);
    this.editor.append(subview.$el);

    subview.createEditor();
  },

  addGalleryEditor: function(content) {
    var subview = new Sensori.Views.GalleryEditor({
      content: content
    }).render();
    this.subviews.push(subview);
    this.editor.append(subview.$el);
  },

  save: function() {
    this.model.set({
      title:           this.$("#tutorial_title").val(),
      description:     this.$("#tutorial_description").val(),
      youtube_id:      this.$("#tutorial_youtube_id").val(),
      body_html:       this.getHTMLValue(),
      body_components: this.getJSONValue()
    });

    this.model.save(null, {
      success: _.bind(this.saveSuccess, this),
      error: _.bind(this.saveError, this)
    });
  },

  publish: function() {
    this.model.publish({
      success: _.bind(this.publishSuccess, this),
      error: _.bind(this.publishError, this)
    });
  },

  getHTMLValue: function() {
    return _.invoke(this.subviews, "getHTMLValue").join("\n");
  },

  getJSONValue: function() {
    return _.invoke(this.subviews, "getJSONValue");
  },

  saveSuccess: function() {
    if (this.model.get("published")) {
      this.$("[data-trigger='view-tutorial']").fadeIn();
    } else {
      this.$("[data-trigger='publish-tutorial']").fadeIn();
    }
    this.$("[data-trigger='preview-tutorial']").fadeIn();

    this.$el.notice({ text: "Tutorial saved successfully!" });
  },

  saveError: function() {
    this.$el.notice({ text: "Tutorial could not be saved!", type: "error" });
  },

  publishSuccess: function() {
    this.$("[data-trigger='publish-tutorial']").fadeOut("fast", _.bind(function() {
      this.$("[data-trigger='view-tutorial']").fadeIn();
    }, this));
    this.$el.notice({ text: "Tutorial published!" });
  },

  publishError: function() {
    console.log("publish error!");
  },

  redirectToEditURL: function() {
    Sensori.pushState(this.model.get("slug") + "/edit");
  },

  disableAttachmentButton: function() {
    this.$(".attachment-button").addClass("disabled");
  },

  enableAttachmentButton: function() {
    this.$(".attachment-button").removeClass("disabled").attr("href", this.model.get("attachment_url"));
  },

  renderAttachmentUploader: function() {
    this.attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: this.model,
      el: this.$(".attachment-container")
    }).render();

    this.attachmentUploader.on("upload:add", this.disableAttachmentButton, this);
    this.model.on("change:attachment_url", this.enableAttachmentButton, this)
  },

  preview: function() {
    var formData = _.extend(this.model.toJSON(), {
      body_html: this.getHTMLValue(),
      token: Sensori.authenticityToken
    });
    $(JST["backbone/templates/tutorials/preview_form"](formData)).submit();
  },

  show: function() {
    Sensori.redirect("/tutorials/" + this.model.get("slug"));
  },

  render: function() {
    this.editor = this.$(".editor");
    this.editor.empty();

    _.each(this.model.get("body_components"), _.bind(function(object) {
      this.addComponent(object);
    }, this));

    this.renderAttachmentUploader();

    return this;
  }

});