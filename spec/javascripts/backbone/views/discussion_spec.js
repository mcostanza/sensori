describe("Sensori.Views.Discussion", function() {
	var view,
	    model;

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
    it("should call validate", function() {
    });
    it("should disable the post button", function() {
    });
    it("should prompt for email if the user doesn't have an email", function() {
    });
    it("should call save if the member has an email", function() {
    });
    it("should not do anything if validate returns false", function() {
    });
  });
});
