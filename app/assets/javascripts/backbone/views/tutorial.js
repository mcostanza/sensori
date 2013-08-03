Sensori.Views.Tutorial = Backbone.View.extend({

  initialize: function() {
    this.subviews = [];

    this.model.on("change:id", this.redirectToEditURL, this);
  },

  events: {
    "click [data-trigger='save-tutorial']": "save",
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

  getHTMLValue: function() {
    return _.invoke(this.subviews, "getHTMLValue").join("\n");
  },

  getJSONValue: function() {
    return _.invoke(this.subviews, "getJSONValue");
  },

  saveSuccess: function() {
    console.log("save success!", arguments);
  },

  saveError: function() {
    console.log("save error!");
  },

  redirectToEditURL: function() {
    Sensori.redirect(this.model.url() + "/edit");
  },

  render: function() {
    this.editor = this.$(".editor");
    this.editor.empty();

    _.each(this.model.get("body_components"), _.bind(function(object) {
      this.addComponent(object);
    }, this));

    return this;
  }

});