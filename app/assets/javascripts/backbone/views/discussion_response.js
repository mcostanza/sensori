Sensori.Views.DiscussionResponse = Backbone.View.extend({
  template: JST["backbone/templates/discussions/response"],

  initialize: function() {
    this.listenTo(this.collection, "add", this.renderResponse);
    this.postButton = this.$("[data-trigger='post']");
    this.responseInput = this.$("#response_body");
    this.validatesPresenceOf(this.responseInput);
  },

  events: {
    "click [data-trigger='post']": "processResponse"
  },

  processResponse: function(event) {
    if(!this.validate()) { return; }
    var view = this;
    this.disablePostButton();

    if(Sensori.Member.has('email')) {
      this.saveResponse();
    } else { 
      this.promptForEmail();
    }
  },

  saveResponse: function() {
    var view = this;
    var response = new Sensori.Models.Response({
      body: this.responseInput.val(),
      discussion_id: this.model.get("id")
    });
    response.save(null, {
      success: function() {
        view.collection.add(response);
        view.responseInput.val("");
        view.enablePostButton();
      },
      error: function(e) { console.log(e); }
    });
  },

  renderResponse: function(response) {
    this.$('.responses').append(this.template({
      member: Sensori.Member,
      response: response
    }));
  },
  
  promptForEmail: function() {
    if(!this.emailPrompt) {
      this.emailPrompt = new Sensori.Views.EmailPrompt({ 
        model: Sensori.Member,
        message: "Email address to send response notifications:"
      });
      this.listenTo(this.emailPrompt, "email:saved", this.processResponse);
      this.listenTo(this.emailPrompt, "hide", this.enablePostButton);
      this.$el.append(this.emailPrompt.render().el);
    }
    this.emailPrompt.show();
  },

  enablePostButton: function() { this.postButton.prop('disabled', false); },

  disablePostButton: function() { this.postButton.prop('disabled', true); }
});

_.extend(Sensori.Views.DiscussionResponse.prototype, Sensori.Mixins.Validations);
