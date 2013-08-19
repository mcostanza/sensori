Sensori.Views.GalleryEditor = Backbone.View.extend({

  initialize: function(options) {
    this.imageViews = [];
    this.content = this.options.content || [];
  },

  tagName: "div",

  className: "gallery-editor",

  events: {
    "click [data-trigger='add-image']": "showImageUploader"
  },

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

  showImageUploader: function() {
    this.imageUploaderModal.modal('show');
  },

  setupImageUploaderForm: function() {
    this.$("form").fileupload({
      add:      _.bind(this.uploaderOnAdd, this),
      progress: _.bind(this.uploaderOnProgress, this),
      done:     _.bind(this.uploaderOnDone, this),
      fail:     _.bind(this.uploaderOnFail, this)
    });
  },

  uploaderOnAdd: function(e, data) {
    data.submit();
  },

  uploaderOnProgress: function(e, data) {
    console.log("progress...", e, data);
  },

  uploaderOnDone: function(e, data) {
    this.imageUploaderModal.modal('hide');

    var file       = data.files[0],
        domain     = this.$("form").attr('action'),
        path       = this.$('input[name=key]').val().replace('${filename}', file.name),
        imageModel = {
          type: "image",
          src: domain + path,
          title: ""
        };

    this.addImage(this.createImageEditorView(imageModel));
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
      imageUploaderForm: JST["backbone/templates/tutorials/s3_uploader_form"]()
    }));

    this.imageUploaderModal = this.$(".image-uploader-modal");
    this.imageUploaderModal.modal({ 
      show: false 
    });

    this.setupImageUploaderForm();
  
    this.renderImages();

    return this;
  }

});
