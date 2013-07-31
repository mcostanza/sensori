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
    this.model.title = this.$(".image-title").val();
    this.$el.popover("hide");
  },

  removeImage: function() {
    this.$el.popover("hide");
    this.remove();
    this.galleryView.trigger("removeItem", this);
  },

  getHTMLValue: function() {
    return "<img src=\"/assets/loader.gif\" data-src=\"" + this.model.src + "\" title=\"" + this.model.title + "\" />";
  },

  getJSONValue: function() {
    return {
      type: "image",
      src: this.model.src,
      title: this.model.title
    };
  },

  render: function() {
    this.$el.html(JST["backbone/templates/tutorials/thumbnail"](this.model));

    this.$el.popover({ 
      html: true,
      content: JST["backbone/templates/tutorials/thumbnail_popover"](),
      container: this.$el
    });

    return this;
  }

});