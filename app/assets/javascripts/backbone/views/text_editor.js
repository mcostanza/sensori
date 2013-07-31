Sensori.Views.TextEditor = Backbone.View.extend({
  
  tagName: "textarea",

  className: "wysihtml5",

  // Options passed to the wysihtml5 editor instance
  wysihtml5Config: {
    // Insert p tags instead of br when the return key is typed
    useLineBreaks: false,
    parserRules: {
      // The following tags are allowed when initialized with pre-existing content
      tags: {
        b:  {},
        i:  {},
        u:  {},
        p:  {},
        ul: {},
        ol: {},
        li: {},
        a:  {
          set_attributes: {
            target: "_blank",
            rel:    "nofollow"
          },
          check_attributes: {
            href:   "url" // important to avoid XSS
          }
        }
      }
    }
  },

  getHTMLValue: function() {
    return this.$el.val();
  },

  getJSONValue: function() {
    return { 
      "type": "text", 
      "content": this.getHTMLValue() 
    };
  },

  createEditor: function() {
    this.$el.wysihtml5(this.wysihtml5Config);
  },

  render: function() {
    this.$el.html(this.options.content);
    return this;
  }

});