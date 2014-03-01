Sensori.Views.MediaEditor = Backbone.View.extend({
  tagName: "span",

  popoverTemplate: JST["backbone/templates/tutorials/media_popover"],

  events: {
    "click [data-trigger='edit-media']": "togglePopover",
    "click [data-trigger='save-media']": "setAttributes",
    "keypress .media-title-input": "setAttributesOnEnter",
    "click [data-trigger='remove-media']": "removeMedia"
  },

  initialize: function() {
    this.galleryView = this.options.galleryView;
    this.mediaType = this.model.type;
    this.mediaTemplate = JST["backbone/templates/tutorials/" + this.mediaType];
    this.template = JST["backbone/templates/tutorials/" + this.mediaType + "_editor"];
  },

  togglePopover: function() {
    this.editLink.popover('toggle');
    this.$(".media-title-input").val(this.model.title);
  },

  setAttributes: function() {
    this.model.title = _.escape(this.$(".media-title-input").val());
    this.editLink.popover("hide");
    this.$(".media-title").html(this.model.title);
  },

  setAttributesOnEnter: function(e) {
    if(e.keyCode == 13) { this.setAttributes(); } 
  },

  removeMedia: function() {
    this.editLink.popover("hide");
    this.galleryView.removeMedia(this);
  },

  getHTMLValue: function() {
    return this.mediaTemplate(this.model);
  },

  getJSONValue: function() {
    return {
      type: this.mediaType,
      src: this.model.src,
      title: this.model.title
    };
  },

  render: function() {
    this.$el.html(this.template(this.model));
    this.editLink = this.$("[data-trigger='edit-media']");

    this.editLink.popover({ 
      html: true,
      content: this.popoverTemplate(),
      trigger: 'manual',
      placement: 'top'
    });

    return this;
  }
});
