Sensori.Views.GalleryEditor = Backbone.View.extend({

  initialize: function(options) {
    this.imageViews = [];
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

  resizeThumbnails: function() {
    $(_.pluck(this.imageViews, 'el'))
      .removeClass("span11 span5 span3 span2")
      .addClass(this.getSpanClass());
  },

  getSpanClass: function() {
    var rowSize = Math.min(this.imageViews.length, 4);
    return {
      1: "span11",
      2: "span5",
      3: "span3",
      4: "span2"
    }[rowSize];
  },

  unveilImages: function() {
    this.$("img[data-src]").unveil();
  },

  updateGallery: function() {
    this.resizeThumbnails();
    this.unveilImages();
  },

  isImage: function(file) {
    return _.include(["image/png", "image/jpeg", "image/jpg", "image/gif"], file.type.toLowerCase());
  },

  setupImageUploaderForm: function() {
    this.$("form").fileupload({
      add:      _.bind(this.uploaderOnAdd, this),
      progress: _.bind(this.uploaderOnProgress, this),
      done:     _.bind(this.uploaderOnDone, this),
      fail:     _.bind(this.uploaderOnFail, this)
    });
  },

  uploaderOnAdd: function(event, data) {
    if (this.isImage(data.files[0])) {
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
    var file       = data.files[0],
        domain     = this.$("form").attr('action'),
        path       = this.$('input[name=key]').val().replace('${filename}', file.name),
        imageModel = {
          type: "image",
          src: domain + path,
          title: ""
        };

    this.addImage(this.createImageEditorView(imageModel));


    this.$(".progress").fadeOut({
      complete: _.bind(function() {
        this.$(".progress-bar").css({ width: "0%" });
      }, this)
    });
  },

  uploaderOnFail: function(e, data) {
    console.error('upload fail', e, data);
  },

  addImage: function(imageView, options) {
    options = _.extend({ initialRender: false }, options);

    this.imageViews.push(imageView);
    this.$("ul").append(imageView.$el);

    if (!options.initialRender) { this.updateGallery(); }
  },

  removeImage: function(imageView) {
    this.imageViews = _.without(this.imageViews, imageView);
    imageView.remove();
    this.updateGallery();
  },

  renderImages: function() {
    _.each(this.content, _.bind(function(imageModel) {
      var imageView = this.createImageEditorView(imageModel);
      this.addImage(imageView, { initialRender: true });
    }, this));
    this.updateGallery();
  },

  createImageEditorView: function(imageModel) {
    return new Sensori.Views.ImageEditor({ 
      model: imageModel,
      galleryView: this
    }).render();
  },

  getHTMLValue: function() {
    return JST["backbone/templates/tutorials/gallery_show"]({
      spanClass: this.getSpanClass(),
      thumbnails: _.invoke(this.imageViews, "getHTMLValue")
    });
  },

  getJSONValue: function() {
    return {
      type: "gallery",
      content: _.invoke(this.imageViews, "getJSONValue")
    };
  },

  render: function() {
    this.$el.html(JST["backbone/templates/tutorials/gallery_editor"]({
      imageUploaderForm: JST["backbone/templates/shared/s3_uploader_form"]()
    }));

    this.setupImageUploaderForm();
  
    this.renderImages();

    return this;
  }

});
