Sensori.Views.GalleryEditor = Backbone.View.extend({

  initialize: function(options) {
    this.mediaViews = [];
    this.content = this.options.content || [];
  },

  events: {
    "click .fileinput-button": "triggerUpload"
  },

  triggerUpload: function(e) {
    this.$("input[type='file']").click();
  },

  tagName: "div",

  className: "gallery-editor",

  unveilImages: function() {
    this.$("img[data-src]").unveil();
  },

  updateGallery: function() {
    this.unveilImages();
  },

  isImage: function(file) {
    return !!file.name.match(/(png|jpe?g|gif)$/i);
  },

  isAudio: function(file) { 
    return !!file.name.match(/(mp3|wav)$/i);
  },

  setupUploaderForm: function() {
    this.$("form").fileupload({
      add:      _.bind(this.uploaderOnAdd, this),
      progress: _.bind(this.uploaderOnProgress, this),
      done:     _.bind(this.uploaderOnDone, this),
      fail:     _.bind(this.uploaderOnFail, this)
    });
  },

  uploaderOnAdd: function(event, data) {
    var file = data.files[0];
    if (this.isImage(file) || this.isAudio(file)) {
      this.$(".control-group").removeClass("error");
      this.$(".control-group").find(".help-inline").fadeOut();

      this.$(".progress").fadeIn();
      this.$(".progress-bar").css({ width: "0%" });

      data.submit();
    } else {
      this.$(".control-group").addClass("error");
      this.$(".control-group").find(".help-inline").fadeIn();
    }
  },

  uploaderOnProgress: function(e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    this.$(".progress-bar").css({ width: progress + "%" });
  },

  uploaderOnDone: function(e, data) {
    var model,
        file       = data.files[0],
        domain     = this.$("form").attr('action'),
        path       = this.$('input[name=key]').val().replace('${filename}', file.name);

    if(this.isImage(file)) {
      model = {
        type: "image",
        src: domain + path,
        title: ""
      };
    } else {
      model = {
        type: "audio",
        src: domain + path,
        title: file.name
      }
    }
    this.addMedia(this.createEditorView(model));

    this.$(".progress").fadeOut({
      complete: _.bind(function() {
        this.$(".progress-bar").css({ width: "0%" });
      }, this)
    });
  },

  uploaderOnFail: function(e, data) {
    console.error('upload fail', e, data);
  },

  addMedia: function(mediaView, options) {
    options = _.extend({ initialRender: false }, options);

    this.mediaViews.push(mediaView);
    this.$(".media-items").append(mediaView.$el);

    if (!options.initialRender) { this.updateGallery(); }
  },

  removeMedia: function(mediaView) {
    this.mediaViews = _.without(this.mediaViews, mediaView);
    mediaView.remove();
    this.updateGallery();
  },

  renderMedia: function() {
    var mediaView;
    _.each(this.content, _.bind(function(model) {
      mediaView = this.createEditorView(model);
      this.addMedia(mediaView, { initialRender: true });
    }, this));
    this.updateGallery();
  },

  createEditorView: function(model) {
    return new Sensori.Views.MediaEditor({
      model: model,
      galleryView: this
    }).render();
  },

  getHTMLValue: function() {
    return JST["backbone/templates/tutorials/gallery"]({
      mediaItems: _.invoke(this.mediaViews, "getHTMLValue")
    });
  },

  getJSONValue: function() {
    return {
      type: "gallery",
      content: _.invoke(this.mediaViews, "getJSONValue")
    };
  },

  render: function() {
    this.$el.html(JST["backbone/templates/tutorials/gallery_editor"]({
      mediaUploaderForm: JST["backbone/templates/shared/s3_uploader_form"]()
    }));

    this.setupUploaderForm();
  
    this.renderMedia();

    return this;
  }
});
