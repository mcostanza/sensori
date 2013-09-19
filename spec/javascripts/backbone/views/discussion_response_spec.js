describe("Sensori.Views.DiscussionResponse", function() {
	var view,
	    model,
      collection,
      el,
      mockEmailPrompt,
      mockResponse;

	beforeEach(function() {
		model = new Sensori.Models.Discussion({ id: 414 });
    collection = new Sensori.Collections.Responses([]);
    el = $("<div>").append([
        "<div class='responses'></div>",
        "<textarea cols='40' id='response_body' name='response[body]' placeholder='Add a comment...' rows='2'></textarea>",
        "<button data-trigger='post' type='submit' class='btn btn-primary pull-right'>Post</button>"
			].join(""));
		view = new Sensori.Views.DiscussionResponse({ model: model, collection: collection, el: el });
	});
  afterEach(function() {
    Sensori.Member = null;
  });

  describe(".initialize()", function() {
    it("should render the response when it is added to the collection", function() {
      sinon.stub(Sensori.Views.DiscussionResponse.prototype, "renderResponse").returns(true);
      collection = new Sensori.Collections.Responses([]);
      view = new Sensori.Views.DiscussionResponse({ model: model, collection: collection, el: el });
      var response = new Sensori.Models.Response({});
      view.collection.add(response);
      expect(view.renderResponse.callCount).toBe(1);
      expect(view.renderResponse.calledWith(response)).toBe(true);

      Sensori.Views.DiscussionResponse.prototype.renderResponse.restore();
    });
    it("should set postButton to the post button in the page", function() {
      expect(view.postButton).toEqual(view.$("[data-trigger='post']"));
    });
    it("should set responseInput to the subject input in the page", function() {
      expect(view.responseInput).toEqual(view.$("#response_body"));
    });
    it("should set responsesElement to the responses element in the page", function() {
      expect(view.responsesElement).toEqual(view.$(".responses"));
    });
    it("should setup a validation for the response input", function() {
      var validatedInputs = _.map(view.validations, function(validation) { return validation.input; });
      expect(validatedInputs).toContain(view.responseInput);
    });
  });

  describe("template", function() {
    it("should be set to a the discussions response template", function() {
      expect(view.template).toEqual(JST["backbone/templates/discussions/response"]);
    });
  });

  describe("events", function() {
    it("should process the response when the post button is clicked", function() {
      expect(view.events["click [data-trigger='post']"]).toEqual("processResponse");
    });
  });

  describe("processResponse", function() {
    beforeEach(function() {
      sinon.stub(view, "validate").returns(true);
      sinon.stub(view, "disablePostButton");
      sinon.stub(view, "saveResponse");
      sinon.stub(view, "promptForEmail");
      Sensori.Member = { has: sinon.stub() }
    });
    it("should call validate", function() {
      view.processResponse();
      expect(view.validate.callCount).toBe(1);
    });
    it("should disable the post button", function() {
      view.processResponse();
      expect(view.disablePostButton.callCount).toBe(1);
    });
    it("should prompt for email if the user doesn't have an email", function() {
      Sensori.Member.has.returns(false);
      view.processResponse();
      expect(Sensori.Member.has.callCount).toBe(1);
      expect(Sensori.Member.has.calledWith("email")).toBe(true);
      expect(view.promptForEmail.callCount).toBe(1);
    });
    it("should call saveResponse if the member has an email", function() {
      Sensori.Member.has.returns(true);
      view.processResponse();
      expect(Sensori.Member.has.callCount).toBe(1);
      expect(Sensori.Member.has.calledWith("email")).toBe(true);
      expect(view.saveResponse.callCount).toBe(1);
    });
    it("should not do anything if validate returns false", function() {
      view.validate.returns(false);
      view.processResponse();
      expect(view.promptForEmail.callCount).toBe(0);
      expect(view.saveResponse.callCount).toBe(0);
    });
  });

  describe("saveResponse", function() {
    beforeEach(function() {
      sinon.stub(view.responseInput, 'val').returns('response');
      sinon.stub(view.collection, 'add');
      sinon.stub(view, 'enablePostButton');
      mockResponse = { save: sinon.stub() }
      sinon.stub(Sensori.Models, "Response").returns(mockResponse);
    });
    afterEach(function() {
      Sensori.Models.Response.restore();
    });
    it("should initialize a new response", function() {
      view.saveResponse();
      expect(Sensori.Models.Response.callCount).toBe(1);
      expect(Sensori.Models.Response.calledWith({
        body: 'response',
        discussion_id: model.get('id')
      })).toBe(true);
    });
    it("should save the response", function() {
      view.saveResponse();
      expect(mockResponse.save.callCount).toBe(1);
      var saveCall = mockResponse.save.getCall(0);
      expect(saveCall.args[0]).toEqual(null);
    });
    it("should add the response to the collection, reset the response input and enable the post button after a sucessful save", function() {
      view.saveResponse();
      expect(mockResponse.save.callCount).toBe(1);
      var saveCall = mockResponse.save.getCall(0);
      saveCall.yieldTo("success");
      expect(view.collection.add.callCount).toBe(1);
      expect(view.collection.add.calledWith(mockResponse)).toBe(true);

      expect(view.responseInput.val.callCount).toBe(2);
      expect(view.responseInput.val.calledWith("")).toBe(true);

      expect(view.enablePostButton.callCount).toBe(1);
    });
  });

  describe("renderResponse", function() {
    beforeEach(function() {
      sinon.stub(view, 'template').returns('template');
      sinon.stub(view.responsesElement, 'append');
      Sensori.Member = 'member';
      mockResponse = 'response';
    });
    afterEach(function() {
      Sensori.member = null;
    });
    it("should render the template", function() {
      view.renderResponse(mockResponse);
      expect(view.template.callCount).toBe(1);
      expect(view.template.calledWith({ member: Sensori.Member, response: mockResponse })).toBe(true);
    });
    it("should append the template to the end of the responses element", function() {
      view.renderResponse(mockResponse);
      expect(view.responsesElement.append.callCount).toBe(1);
      expect(view.responsesElement.append.calledWith('template')).toBe(true);
    });
  });

  describe("promptForEmail", function() {
    beforeEach(function() {
      mockEmailPrompt = {
        render: sinon.stub(),
        el: sinon.stub(),
        show: sinon.stub()
      }
      mockEmailPrompt.render.returns(mockEmailPrompt);
      mockEmailPrompt.el.returns('email prompt element');
      sinon.stub(Sensori.Views, "EmailPrompt").returns(mockEmailPrompt);
      sinon.stub(view, 'listenTo');
      sinon.stub(view.$el, 'append');
      Sensori.Member = 'member';
    });
    afterEach(function() {
      Sensori.Views.EmailPrompt.restore();
    });
    it("should initialize a new email prompt", function() {
      view.promptForEmail();
      expect(Sensori.Views.EmailPrompt.callCount).toEqual(1);
      expect(Sensori.Views.EmailPrompt.calledWith({
        model: 'member',
        message: "Email address to send response notifications:"
      })).toBe(true);
    });
    it("should listen to the save and hide callbacks on the email prompt", function() {
      view.promptForEmail();
      expect(view.listenTo.callCount).toBe(2);
      expect(view.listenTo.calledWith(mockEmailPrompt, 'email:saved', view.processResponse)).toBe(true);
      expect(view.listenTo.calledWith(mockEmailPrompt, 'hide', view.enablePostButton)).toBe(true);
    });
    it("should append the email prompt view to the discussion view's element", function() {
      view.promptForEmail();
      expect(view.$el.append.callCount).toBe(1);
      expect(view.$el.append.calledWith('email prompt element'));
    });
    it("should show the email prompt", function() {
      view.promptForEmail();
      expect(mockEmailPrompt.show.callCount).toBe(1);
    });
    it("should not initialize the email prompt if it is already setup", function() {
      view.promptForEmail();
      view.promptForEmail();
      expect(Sensori.Views.EmailPrompt.callCount).toEqual(1);
    });
  });

  describe("enablePostButton", function() {
    beforeEach(function() {
      sinon.stub(view.postButton, 'prop');
    });
    it("should set the disabled property on the post button to false", function() {
      view.enablePostButton();
      expect(view.postButton.prop.callCount).toBe(1);
      expect(view.postButton.prop.calledWith('disabled', false)).toBe(true);
    });
  });

  describe("disablePostButton", function() {
    beforeEach(function() {
      sinon.stub(view.postButton, 'prop');
    });
    it("should set the disabled property on the post button to true", function() {
      view.disablePostButton();
      expect(view.postButton.prop.callCount).toBe(1);
      expect(view.postButton.prop.calledWith('disabled', true)).toBe(true);
    });
  });

  describe("Mixins", function() {
    it("should include the Sensori.Mixins.Validations module", function() {
      for(var property in Sensori.Mixins.Validations) {
        expect(view[property]).toEqual(Sensori.Mixins.Validations[property]);
      }
    });
  });
});

