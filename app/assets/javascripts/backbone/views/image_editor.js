Sensori.Views.ImageEditor = Backbone.View.extend({

  initialize: function() {
    this.galleryView = this.options.galleryView;
  },

  tagName: "li",

  className: "popover-link",

  events: {
    "click [data-trigger='edit-image']": "showPopover",
    "click [data-trigger='save-image']": "setAttributes",
    "click [data-trigger='remove-image']": "removeImage"
  },

  showPopover: function() {
    this.$el.popover('show');
    this.$(".image-title").val(this.model.title);
  },

  setAttributes: function() {
    this.model.title = _.escape(this.$(".image-title").val());
    this.$el.popover("hide");
  },

  removeImage: function() {
    this.$el.popover("hide");
    this.galleryView.removeImage(this);
  },

  getHTMLValue: function() {
    return JST["backbone/templates/tutorials/image_show"](this.model);
  },

  getJSONValue: function() {
    return {
      type: "image",
      src: this.model.src,
      title: this.model.title
    };
  },

  render: function() {
    this.$el.html(JST["backbone/templates/tutorials/image_editor"](this.model));

    this.$el.popover({ 
      html: true,
      content: JST["backbone/templates/tutorials/thumbnail_popover"](),
      container: this.$el,
      trigger: 'manual',
      placement: 'top'
    });

    return this;
  }

});