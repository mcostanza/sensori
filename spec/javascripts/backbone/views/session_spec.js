describe("Sensori.Views.Session", function() {
	var view,
	    model,
	    collection,
	    mockView;

	beforeEach(function() {
		model = new Sensori.Models.Session();
		collection = new Sensori.Collections.SamplePacks([]);
		view = new Sensori.Views.Session({
			model: model,
			collection: collection,
			el: $("<div>").append([
				"<form id='session-form'>",
					"<input id='session_attachment_url' type='hidden' />",
				"</form>",
				"<div class='attachments-container'></div>",
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
		
		it("creates hidden inputs from the sample packs collection", function() {
			collection.add({ attachment_url: 'http://s3.amazon.com/sensori/samples-1.zip', attachment_name: 'one.zip' });
			collection.add({ attachment_url: 'http://s3.amazon.com/sensori/samples-2.zip', attachment_name: 'two.zip' });
			
			view.submitForm();
			
			expect(view.$("input[name='sample_packs[][url]']").first().val()).toEqual('http://s3.amazon.com/sensori/samples-1.zip')
			expect(view.$("input[name='sample_packs[][name]']").first().val()).toEqual('one.zip')

			expect(view.$("input[name='sample_packs[][url]']").last().val()).toEqual('http://s3.amazon.com/sensori/samples-2.zip')
			expect(view.$("input[name='sample_packs[][name]']").last().val()).toEqual('two.zip')
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
			view.$saveButton.addClass("disabled");
			view.enableSaveButton();
			expect(view.$saveButton.hasClass("disabled")).toBe(false);
		});
	});

	describe(".disableSaveButton()", function() {
		beforeEach(function() {
			view.render()			
		});
		it("should add the disabled class from the save button", function() {
			view.disableSaveButton();
			expect(view.$saveButton.hasClass("disabled")).toBe(true);
		});
	});

	describe(".addSamplePack()", function() {
		beforeEach(function() {
			view.render();
			
			mockView = {
				on: sinon.spy(),
				render: sinon.stub()
			};
			mockView.render.returns(mockView);
			sinon.stub(Sensori.Views, "AttachmentUploader").returns(mockView);
		});

		afterEach(function() {
			Sensori.Views.AttachmentUploader.restore();
		});

		it("appends a new sample pack to the collection", function() {
			view.addSamplePack();
			expect(view.collection.length).toEqual(1);
		});

		it("renders a new attachment uploader for the sample pack", function() {
			view.addSamplePack();
			expect(Sensori.Views.AttachmentUploader.callCount).toEqual(1);
			expect(mockView.render.callCount).toEqual(1);
		});
	});

	describe(".render()", function() {
		beforeEach(function() {
			mockView = {
				on: sinon.spy(),
				render: sinon.stub()
			};
			mockView.render.returns(mockView);

			collection.add({ attachment_url: 'http://s3.amazon.com/sensori/samples-1.zip', attachment_name: 'one.zip' });
			collection.add({ attachment_url: 'http://s3.amazon.com/sensori/samples-2.zip', attachment_name: 'two.zip' });

			sinon.stub(Sensori.Views, "AttachmentUploader").returns(mockView);
		});
		afterEach(function() {
			Sensori.Views.AttachmentUploader.restore()
		});
		it("should set this.$saveButton to the save button element", function() {
			view.render();
			expect(view.$saveButton).toEqual(view.$("[data-trigger='save']"));
		});

		it("renders an attachment uploader subview for each sample pack", function() {
			view.render();
			
			expect(Sensori.Views.AttachmentUploader.callCount).toEqual(2);
			expect(mockView.render.callCount).toEqual(2);

			expect(mockView.on.calledWith("upload:add", view.disableSaveButton, view)).toBe(true);
			expect(mockView.on.calledWith("upload:done", view.enableSaveButton, view)).toBe(true);
		});
		it("should return itself", function() {
			expect(view.render()).toEqual(view);
		});
	});

	describe("removing a sample pack", function() {
		var samplePack1,
				samplePack2;

		beforeEach(function() {
			samplePack1 = new Sensori.Models.SamplePack({
				attachment_name: 'samples-1.zip', 
				attachment_url: 'http://s3.amazon.com/sensori/samples-1.zip'
			});

			samplePack2 = new Sensori.Models.SamplePack({
				attachment_name: 'samples-2.zip', 
				attachment_url: 'http://s3.amazon.com/sensori/samples-2.zip'
			});

			collection.add(samplePack1);
			collection.add(samplePack2);
			
			view.render();

			sinon.stub(window, 'confirm').returns(true);
		});

		afterEach(function() {
			window.confirm.restore();
		});

		it("removes the sample pack from the view and collection", function() {
			view.$("[data-trigger='remove-attachment']").first().click();

			expect(collection.length).toEqual(1);
			expect(collection.first().cid).toEqual(samplePack2.cid);

			expect(view.$("[data-cid=" + samplePack1.cid + "]").length).toEqual(0);
			expect(view.$("[data-cid=" + samplePack2.cid + "]").length).toEqual(1);
		});
	});
});