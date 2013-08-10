Sensori.Views.Tutorial = Backbone.View.extend({

  initialize: function() {
    this.subviews = [];

    this.model.on("change:id", this.redirectToEditURL, this)
  },

  events: {
    "click [data-trigger='save-tutorial']": "save",
    "click [data-trigger='publish-tutorial']": "publish",
    "click [data-trigger='preview-tutorial']": "preview",
    "click [data-trigger='view-tutorial']": "show",
    "click [data-trigger='add-more']": "addMore",
    "change #tutorial_youtube_video_url": "updateYoutubeId"
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
      body_html:       this.getHTMLValue(),
      body_components: this.getJSONValue()
    });

    this.model.save(null, {
      success: _.bind(this.saveSuccess, this),
      error: _.bind(this.saveError, this)
    });
  },

  parseYoutubeId: function() {
    var videoUrl = this.$("#tutorial_youtube_video_url").val(),
        matchData = videoUrl.match(/v=(\w+)/);
    return matchData ? matchData[1] : null;
  },

  updateYoutubeId: function() {
    var youtubeId = this.parseYoutubeId(),
        previewEl = this.$(".flex-video"),
        currentPreview = previewEl.find(".flex-video-content"),
        newPreview;

    if (youtubeId) {
      this.model.set("youtube_id", youtubeId);

      newPreview = $("<iframe>")
        .attr("type", "text/html")
        .attr("frameborder", "0")
        .attr("src", "http://www.youtube.com/embed/" + youtubeId);
    } else {
      this.model.unset("youtube_id");

      newPreview = $("<label>")
        .attr("for", "tutorial_youtube_video_url");
      newPreview.html("<img src='/assets/youtube-placeholder.png' />");
    }

    newPreview.addClass("flex-video-content");

    currentPreview.fadeOut("fast", function() { previewEl.html(newPreview); });
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

  renderAttachmentUploader: function() {
    this.attachmentUploader = new Sensori.Views.AttachmentUploader({
      model: this.model,
      el: this.$("#tutorial-attachment-container")
    }).render();
  },

  preview: function() {
    var formData = _.extend(this.model.toJSON(), { token: Sensori.authenticityToken }),
        form = $(JST["backbone/templates/tutorials/preview_form"](formData));

    form.find("#tutorial_body_html").val(this.getHTMLValue());

    form.submit();
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