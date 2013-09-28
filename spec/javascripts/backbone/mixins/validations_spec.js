describe("Sensori.objects.EmailPrompt", function() {
  var object,
      input,
      invalidInput,
      el;

  beforeEach(function() {
    TestObject = function() {};
    _.extend(TestObject.prototype, Sensori.Mixins.Validations);
    object = new TestObject();
    input = { val: sinon.stub() };
  });

  describe("matchers", function() {
    it("should setup an email matcher", function() {
      expect("test@mail.com").toMatch(object.matchers.email);
      expect("test :)").not.toMatch(object.matchers.email);
    });
  });

  describe("validatesPresenceOf", function() {
    it("should setup a validation to test an input's value", function() {
      sinon.stub(object, 'addValidation');
      object.validatesPresenceOf(input);
      expect(object.addValidation.callCount).toBe(1);
      var addValidationCall = object.addValidation.getCall(0);
      //assert a validation is added with the input
      expect(addValidationCall.args[0]).toBe(input);
      //assert the validation function returns true when there is a value in the input
      input.val.returns("Roger");
      expect(addValidationCall.args[1]()).toBe(true);
      //assert the validation function returns false when the input value is blank
      input.val.returns(" ");
      expect(addValidationCall.args[1]()).toBe(false);
    });
  });

  describe("validatesFormatOf", function() {
    it("should setup a validates to test the format of an input", function() {
      sinon.stub(object, 'addValidation');
      object.validatesFormatOf(input, 'email');
      expect(object.addValidation.callCount).toBe(1);
      var addValidationCall = object.addValidation.getCall(0);
      //assert a validation is added with the input
      expect(addValidationCall.args[0]).toBe(input);
      //assert the validation function returns true when there is a value in the input
      input.val.returns("test@mail.com");
      expect(addValidationCall.args[1]()).toBe(true);
      //assert the validation function returns false when the input value is blank
      input.val.returns("test test");
      expect(addValidationCall.args[1]()).toBe(false);
    });
  });

  describe("validate", function() {
    beforeEach(function() {
      invalidInput = { val: sinon.stub() };
      object.validations = [
        { input: input, isValid: sinon.stub().returns(true) },
        { input: invalidInput, isValid: sinon.stub().returns(false) }
      ];
      sinon.stub(object, 'addErrors');
    });
    it("should run all validations", function() {
      object.validate();
      expect(object.validations[0].isValid.callCount).toBe(1);
      expect(object.validations[1].isValid.callCount).toBe(1);
    });
    it("should call addErrors with invalid input", function() {
      object.validate();
      expect(object.addErrors.callCount).toBe(1);
      expect(object.addErrors.calledWith([invalidInput])).toBe(true);
    });
    it("should return true if there are no errors", function() {
      object.validations = [
        { input: input, isValid: sinon.stub().returns(true) },
      ];
      expect(object.validate()).toBe(true);
    });
    it("should return false if there are errors", function() {
      expect(object.validate()).toBe(false);
    });
    it("should return true if there are no validations", function() {
      object.validations = undefined;
      expect(object.validate()).toBe(true);
    });
  });

  describe("addValidation", function() {
    beforeEach(function() {
      el = $("<div class='control-group'><input type='text' /></div>");
      input = el.find('input');
      validation = sinon.stub();
      sinon.stub(object, 'removeErrors');
    });
    it("should add the passed validation into the validations object", function() {
      object.validations = ['test'];
      object.addValidation(input, validation);
      expect(object.validations[1].input).toBe(input);
      expect(object.validations[1].isValid).toBe(validation);
    });
    it("should setup a callback to removeErrors when the input is focused", function() {
      object.addValidation(input, validation);
      input.trigger("focus");
      expect(object.removeErrors.callCount).toBe(1);
      expect(object.removeErrors.calledWith(input)).toBe(true);
    });
    it("should work correctly if validations is undefined", function() {
      object.validations = undefined;
      object.addValidation(input, validation);
      expect(object.validations[0].input).toBe(input);
      expect(object.validations[0].isValid).toBe(validation);
    });
  });

  describe("addErrors", function() {
    beforeEach(function() {
      el = $("<div class='control-group'><input type='text' /></div>");
      input = el.find('input');
    });
    it("should add an error to the closest control group surrounding the input", function() {
      expect(el.hasClass('error')).toBe(false);
      object.addErrors([input]);
      expect(el.hasClass('error')).toBe(true);
    });
    it("should handle being passed a single input instead of an array", function() {
      object.addErrors(input);
      expect(el.hasClass('error')).toBe(true);
    });
  });

  describe("removeErrors", function() {
    beforeEach(function() {
      el = $("<div class='control-group error'><input type='text' /></div>");
      input = el.find('input');
    });
    it("should remove the error on the closest control group surrounding the input", function() {
      expect(el.hasClass('error')).toBe(true);
      object.removeErrors([input]);
      expect(el.hasClass('error')).toBe(false);
    });
    it("should handle being passed a single input instead of an array", function() {
      object.removeErrors(input);
      expect(el.hasClass('error')).toBe(false);
    });
  });
});

