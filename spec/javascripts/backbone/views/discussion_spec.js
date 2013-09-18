describe("Sensori.Views.Discussion", function() {
	var view,
	    model,
      mockEmailPrompt;

	beforeEach(function() {
		model = new Sensori.Models.Discussion();
		view = new Sensori.Views.Discussion({
			model: model,
			el: $("<div>").append([
        "<input id='discussion_subject' name='discussion[subject]' placeholder='Topic' size='30' type='text' />",
        "<textarea cols='40' id='discussion_body' name='discussion[body]' placeholder='Message' rows='10'></textarea>",
        "<input class='inline' id='discussion_attachment' name='discussion[attachment]' type='file' />",
        "<input id='discussion_members_only' name='discussion[members_only]' type='checkbox' value='1' />",
        "<button data-trigger='post' type='submit' class='btn btn-primary pull-right'>Post</button>"
			].join(""))
		});
	});
  afterEach(function() {
    Sensori.Member = null;
  });

  describe(".initialize()", function() {
    it("should set postButton to the post button in the page", function() {
      expect(view.postButton).toEqual(view.$("[data-trigger='post']"));
    });
    it("should set subjectInput to the subject input in the page", function() {
      expect(view.subjectInput).toEqual(view.$("#discussion_subject"));
    });
    it("should set bodyInput to the body input in the page", function() {
      expect(view.bodyInput).toEqual(view.$("#discussion_body"));
    });
    it("should set membersOnlyCheckbox to the members only checkbox in the page", function() {
      expect(view.membersOnlyCheckbox).toEqual(view.$("#discussion_members_only"));
    });
    it("should setup a validation for the subject input", function() {
      var validatedInputs = _.map(view.validations, function(validation) { return validation.input; });
      expect(validatedInputs).toContain(view.subjectInput);
    });
    it("should setup a validation for the body input", function() {
      var validatedInputs = _.map(view.validations, function(validation) { return validation.input; });
      expect(validatedInputs).toContain(view.bodyInput);
    });
  });

  describe("events", function() {
    it("should process the discussion when the post button is clicked", function() {
      expect(view.events["click [data-trigger='post']"]).toEqual("process");
    });
  });

  describe("process", function() {
    beforeEach(function() {
      sinon.stub(view, "validate").returns(true);
      sinon.stub(view, "disablePostButton");
      sinon.stub(view, "save");
      sinon.stub(view, "promptForEmail");
      Sensori.Member = { has: sinon.stub() }
    });
    it("should call validate", function() {
      view.process();
      expect(view.validate.callCount).toBe(1);
    });
    it("should disable the post button", function() {
      view.process();
      expect(view.disablePostButton.callCount).toBe(1);
    });
    it("should prompt for email if the user doesn't have an email", function() {
      Sensori.Member.has.returns(false);
      view.process();
      expect(Sensori.Member.has.callCount).toBe(1);
      expect(Sensori.Member.has.calledWith("email")).toBe(true);
      expect(view.promptForEmail.callCount).toBe(1);
    });
    it("should call save if the member has an email", function() {
      Sensori.Member.has.returns(true);
      view.process();
      expect(Sensori.Member.has.callCount).toBe(1);
      expect(Sensori.Member.has.calledWith("email")).toBe(true);
      expect(view.save.callCount).toBe(1);
    });
    it("should not do anything if validate returns false", function() {
      view.validate.returns(false);
      view.process();
      expect(view.promptForEmail.callCount).toBe(0);
      expect(view.save.callCount).toBe(0);
    });
  });

  describe("save", function() {
    beforeEach(function() {
      sinon.stub(view.subjectInput, 'val').returns('subject');
      sinon.stub(view.bodyInput, 'val').returns('body');
      sinon.stub(view.membersOnlyCheckbox, 'prop').returns('checked');
      view.model = { save: sinon.stub(), url: sinon.stub() };
      sinon.stub(Sensori, "redirect");
    });
    afterEach(function() {
      Sensori.redirect.restore();
    });
    it("should save the model with the correct attributes", function() {
      view.save();
      expect(view.model.save.callCount).toEqual(1);
      var saveCall = view.model.save.getCall(0);
      expect(saveCall.args[0]).toEqual({
        subject: 'subject',
        body: 'body',
        members_only: 'checked'
      });
    });
    it("should redirect to the disucssion after a successful save", function() {
      view.model.url.returns("model url");
      view.save();
      expect(view.model.save.callCount).toEqual(1);
      var saveCall = view.model.save.getCall(0);
      saveCall.yieldTo("success");
      expect(Sensori.redirect.callCount).toBe(1);
      expect(Sensori.redirect.calledWith("model url")).toBe(true);
    });
  });

  describe("render", function() {
    beforeEach(function() {
      view.model = new Sensori.Models.Discussion({
        subject: 'subject',
        body: 'body',
        members_only: true
      });
      view.render();
    });
    it("should set the subject input value to the model's subject", function() {
      expect(view.subjectInput.val()).toEqual("subject");
    });
    it("should set the body input value the model's body", function() {
      expect(view.bodyInput.val()).toEqual("body");
    });
    it("should set the members only checkbox state the the model's members_only property", function() {
      expect(view.membersOnlyCheckbox.prop("checked")).toBe(true);
    });
    it("should return the view", function() {
      expect(view.render()).toBe(view);
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
      expect(view.listenTo.calledWith(mockEmailPrompt, 'email:saved', view.process)).toBe(true);
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
