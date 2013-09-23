describe("Sensori.Views.EmailPrompt", function() {
	var view,
      model,
      el,
      message;

	beforeEach(function() {
		model = { save: sinon.stub() }
    message = 'Enter email';
    el = $("<div>").append([
        "<div id='email-modal'>",
        "<input id='email-modal-input' type='text' />",
        "<button id='email-modal-save' type='submit' class='btn btn-primary pull-right'>Save</button>",
        "</div>"
			].join(""));
		view = new Sensori.Views.EmailPrompt({ model: model, message: message });
	});

  describe("template", function() {
    it("should be set to a the discussions response template", function() {
      expect(view.template).toEqual(JST["backbone/templates/shared/email_modal"]);
    });
  });

  describe("events", function() {
    it("should call save when the save button is clicked", function() {
      expect(view.events["click #email-modal-save"]).toEqual("save");
    });
    it("should call the saveOnEnter when the enter key is pressed", function() {
      expect(view.events["keypress #email-modal-input"]).toEqual("saveOnEnter");
    });
  });

  describe("save", function() {
    beforeEach(function() {
      sinon.stub(view, "validate").returns(true);
      view.emailInput = { val: sinon.stub() }
      view.emailInput.val.returns('email');
      sinon.stub(view, 'trigger');
      sinon.stub(view, 'hide');
    });
    it("should run validations", function() {
      view.save();
      expect(view.validate.callCount).toBe(1);
    });
    it("should save the model with the correct attributes", function() {
      view.save();
      expect(view.model.save.callCount).toBe(1);
      expect(view.model.save.calledWith({ email: 'email' })).toBe(true);
    });
    it("should not do anything if validations fails", function() {
      view.validate.returns(false);
      view.save();
      expect(view.model.save.callCount).toBe(0);
    });
    it("should trigger the save event and hide the view after a successful save", function() {
      view.save();
      expect(view.model.save.callCount).toBe(1);
      var saveCall = view.model.save.getCall(0);
      saveCall.yieldTo("success");
      expect(view.trigger.callCount).toBe(1);
      expect(view.trigger.calledWith('email:saved')).toBe(true);
      expect(view.hide.callCount).toBe(1);
    });
  });

  describe("saveOnEnter", function() {
    beforeEach(function() {
      sinon.stub(view, 'save')
    });
    it("should call save if enter is pressed", function() {
      var event = { keyCode: 13 };
      view.saveOnEnter(event);
      expect(view.save.callCount).toBe(1);
    });
    it("should not call save if another key is pressed", function() {
      var event = { keyCode: 41 };
      view.saveOnEnter(event);
      expect(view.save.callCount).toBe(0);
    });
  });

  describe("render", function() {
    beforeEach(function() {
      sinon.stub(view, 'trigger');
    });
    it("should call the template with the message", function() {
      sinon.stub(view, 'template');
      view.render();
      expect(view.template.callCount).toBe(1);
      expect(view.template.calledWith({ message: view.options.message })).toBe(true);
    });
    it("should append the template to the end of the element", function() {
      sinon.stub(view, 'template').returns('template');
      sinon.stub(view.$el, 'append');
      view.render();
      expect(view.$el.append.callCount).toBe(1);
      expect(view.$el.append.calledWith('template')).toBe(true);
    });
    it("should assign emailModal", function() {
      view.render();
      expect(view.emailModal).toEqual(view.$('#email-modal'));
    });
    it("should assign emailInput", function() {
      view.render();
      expect(view.emailInput).toEqual(view.$('#email-modal-input'));
    });
    it("should setup proxy callbacks for modal events", function() {
      view.render();
      view.emailModal.trigger('hide');
      expect(view.trigger.callCount).toBe(1);
      expect(view.trigger.calledWith('hide')).toBe(true);
      view.emailModal.trigger('hidden');
      expect(view.trigger.callCount).toBe(2);
      expect(view.trigger.calledWith('hidden')).toBe(true);
      view.emailModal.trigger('show');
      expect(view.trigger.callCount).toBe(3);
      expect(view.trigger.calledWith('show')).toBe(true);
      view.emailModal.trigger('shown');
      expect(view.trigger.callCount).toBe(4);
      expect(view.trigger.calledWith('shown')).toBe(true);
    });
    it("should focus the emailInput when the modal is shown", function() {
      view.render();
      sinon.stub(view.emailInput, 'focus');
      view.emailModal.trigger('shown');
      expect(view.emailInput.focus.callCount).toBe(1);
    });
    it("should setup a validation for the emailInput", function() {
      view.render();
      var validatedInputs = _.map(view.validations, function(validation) { return validation.input; });
      expect(validatedInputs).toContain(view.emailInput);
    });
    it("should not set the email modal if it is already setup", function() {
      sinon.stub(view.$el, 'append');
      view.emailModal = 'test'
      view.render();
      expect(view.$el.append.callCount).toBe(0);
    });
  });

  describe("show", function() {
    it("should show the modal", function() {
      view.emailModal = { modal: sinon.stub() };
      view.show();
      expect(view.emailModal.modal.callCount).toBe(1);
      expect(view.emailModal.modal.calledWith('show')).toBe(true);
    });
  });

  describe("hide", function() {
    it("should hide the modal", function() {
      view.emailModal = { modal: sinon.stub() };
      view.hide();
      expect(view.emailModal.modal.callCount).toBe(1);
      expect(view.emailModal.modal.calledWith('hide')).toBe(true);
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

