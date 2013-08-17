Sensori.Views.TextEditor = Backbone.View.extend({
  
  tagName: "textarea",

  className: "wysihtml5",

  attributes: {
    placeholder: "Enter text..."
  },

  // Options passed to the wysihtml5 editor instance
  wysihtml5Config: {

    // Custom menu for font styles restricted to normal text, h3 headings, and h4 subheadings
    customTemplates: {
      "font-styles": function(locale, options) {
        var size = (options && options.size) ? ' btn-'+options.size : '';
        return "<li class='dropdown'>" +
          "<a class='btn dropdown-toggle" + size + "' data-toggle='dropdown' href='#'>" +
            "<i class='icon-font'></i>&nbsp;<span class='current-font'>" + locale.font_styles.normal + "</span>&nbsp;<b class='caret'></b>" +
          "</a>" +
          "<ul class='dropdown-menu'>" +
            "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='p' tabindex='-1'>" + locale.font_styles.normal + "</a></li>" +
            "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h3' tabindex='-1'>Heading</a></li>" +
            "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h4' tabindex='-1'>Sub-heading</a></li>" +
          "</ul>" +
        "</li>";
      }
    },

    // Do not allow inline images (use gallery instead)
    image: false,

    // Insert p tags instead of br when the return key is typed
    useLineBreaks: false,

    parserRules: {
      // The following tags are allowed when initialized with pre-existing content
      tags: {
        h3:  {},
        h4:  {},
        b:   {},
        i:   {},
        u:   {},
        p:   {},
        div: {},
        ul:  {},
        ol:  {},
        li:  {},
        a:   {
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