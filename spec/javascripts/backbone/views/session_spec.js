describe("Sensori.Views.Session", function() {
	var view,
	    model,
	    mockView;

	beforeEach(function() {
		model = new Sensori.Models.Session();
		view = new Sensori.Views.Session({
			model: model,
			el: $("<div>").append([
				"<form id='session-form'>",
					"<input id='session_attachment_url' type='hidden' />",
				"</form>",
				"<div class='attachment-container'></div>",
				"<a href='javascript:;' data-trigger='save'>Save</a>"
			].join(""))
		});
	});

	describe(".submitForm()", function() {
		beforeEach(function() {
			view.render();
			sinon.stub($.fn, "submit");
		});
		afterEach(function() {
			$.fn.submit.restore();
		});
		it("should set the #session_attachment_url value from the model's attachment url", function() {
			var attachmentUrl = "http://s3.amazon.com/sensori/samples.zip";
			model.set("attachment_url", attachmentUrl);
			view.submitForm();
			expect(view.$("#session_attachment_url").val()).toEqual(attachmentUrl);
		});
		it("should submit the #session-form", function() {
			view.submitForm();
			expect($.fn.submit.callCount).toEqual(1);
			expect($.fn.submit.getCall(0).thisValue.selector).toEqual("#session-form");
		});
		it("should return without doing anything if the save button is disabled", function() {
			view.disableSaveButton();
			view.submitForm();
			expect($.fn.submit.callCount).toEqual(0);
		});
	});

	describe(".enableSaveButton()", function() {
		beforeEach(function() {
			view.render()			
		});
		it("should remove the disabled class from the save button", function() {
			view.saveButton.addClass("disabled");
			view.enableSaveButton();
			expect(view.saveButton.hasClass("disabled")).toBe(false);
		});
	});

	describe(".disableSaveButton()", function() {
		beforeEach(function() {
			view.render()			
		});
		it("should add the disabled class from the save button", function() {
			view.disableSaveButton();
			expect(view.saveButton.hasClass("disabled")).toBe(true);
		});
	});

	describe(".render()", function() {
		beforeEach(function() {
			mockView = {
				on: sinon.spy(),
				render: sinon.stub()
			};
			mockView.render.returns(mockView);

			sinon.stub(Sensori.Views, "AttachmentUploader").returns(mockView);
		});
		afterEach(function() {
			Sensori.Views.AttachmentUploader.restore()
		});
		it("should set this.saveButton to the save button element", function() {
			view.render();
			expect(view.saveButton).toEqual(view.$("[data-trigger='save']"));
		});
		it("should render an attachment uploader subview", function() {
			view.render();
			
			expect(Sensori.Views.AttachmentUploader.callCount).toEqual(1);
			expect(Sensori.Views.AttachmentUploader.calledWith({ 
				model: model, 
				el: view.$(".attachment-container") 
			})).toBe(true);

			expect(view.attachmentUploader).toEqual(mockView);
			expect(mockView.render.callCount).toEqual(1);

			expect(mockView.on.calledWith("upload:add", view.disableSaveButton, view)).toBe(true);
			expect(mockView.on.calledWith("upload:done", view.enableSaveButton, view)).toBe(true);
		});
		it("should return itself", function() {
			expect(view.render()).toEqual(view);
		});
	});
});