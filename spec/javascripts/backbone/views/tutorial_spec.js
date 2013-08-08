describe("Sensori.Views.Tutorial", function() {
  var view,
      element,
      model,
      mockSubview;

  beforeEach(function() {

    element = $([
      "<div>",
        "<div class='editor'><img src='/assets/loader.gif' /></div>",
        "<a href='javascript:;' class='btn attachment-button'>Download Samples</a>",
        "<div class='attachment-container'></div>",
        "<button data-trigger='add-more'>Add More</button>",
        "<button data-trigger='save-tutorial'>Save</button>",
        "<button data-trigger='publish-tutorial'>Publish</button>",
        "<button data-trigger='preview-more'>Preview</button>",
      "</div>"
    ].join(""))[0];

    model = new Sensori.Models.Tutorial();
    view = new Sensori.Views.Tutorial({
      model: model,
      el: element
    });
  });

  describe(".initialize()", function() {
    it("should set this.subviews to an empty array", function() {
      expect(view.subviews).toEqual([]);
    });
    it("should bind the redirectToEditURL function to be called when the model triggers a 'change:id' event", function() {
      sinon.stub(Sensori.Views.Tutorial.prototype, "redirectToEditURL");
      
      model = new Sensori.Models.Tutorial();
      view = new Sensori.Views.Tutorial({ model: model });
      model.set("id", "123");
      expect(view.redirectToEditURL.callCount).toEqual(1);

      Sensori.Views.Tutorial.prototype.redirectToEditURL.restore();
    });
  });

  describe(".addMore()", function() {
    beforeEach(function() {
      sinon.stub(view, "addComponent");
    });
    it("should add a text editor component and a gallery component", function() {
      view.addMore();
      expect(view.addComponent.callCount).toEqual(2);
      expect(view.addComponent.getCall(0).args).toEqual([{ type: "text" }]);
      expect(view.addComponent.getCall(1).args).toEqual([{ type: "gallery" }]);
    });
  });

  describe(".addComponent(options)", function() {
    beforeEach(function() {
      sinon.stub(view, "addTextEditor");
      sinon.stub(view, "addGalleryEditor");
    });
    it("should add a text editor with options.content if options.type is 'text'", function () {
      view.addComponent({ type: "text", content: "text editor content" });
      expect(view.addTextEditor.callCount).toEqual(1);
      expect(view.addTextEditor.calledWith("text editor content")).toBe(true);
    });
    it("should add a gallery editor with options.content if options.type is 'gallery'", function (){
      view.addComponent({ type: "gallery", content: "gallery editor content" });
      expect(view.addGalleryEditor.callCount).toEqual(1);
      expect(view.addGalleryEditor.calledWith("gallery editor content")).toBe(true);
    });
  });

  describe(".addTextEditor(content)", function() {
    beforeEach(function() {
      mockSubview = {
        $el: $("<div>editor!</div>"),
        createEditor: sinon.spy(),
        render: sinon.stub()
      };
      mockSubview.render.returns(mockSubview);
      sinon.stub(Sensori.Views, "TextEditor").returns(mockSubview);

      view.render();

      view.subviews = ['subview', 'subview'];
    });
    afterEach(function() {
      Sensori.Views.TextEditor.restore();
    });
    it("should initialize and render a text editor with the content", function() {
      view.addTextEditor("content!");
      
      expect(Sensori.Views.TextEditor.callCount).toEqual(1);
      expect(Sensori.Views.TextEditor.calledWith({ content: "content!" })).toBe(true);
      
      expect(mockSubview.render.callCount).toEqual(1);
    });
    it("should append the text editor view to this.subviews and append the element to the .editor element", function(){
      view.addTextEditor("content!");

      expect(view.subviews.length).toEqual(3);
      expect(view.subviews[2]).toEqual(mockSubview);

      expect(mockSubview.$el.closest(view.$('.editor')).length).toEqual(1);
    });
  });

  describe(".addGalleryEditor(content)", function() {
    beforeEach(function() {
      mockSubview = {
        $el: $("<div>editor!</div>"),
        render: sinon.stub()
      };
      mockSubview.render.returns(mockSubview);
      sinon.stub(Sensori.Views, "GalleryEditor").returns(mockSubview);

      view.render();

      view.subviews = ['subview', 'subview'];
    });
    afterEach(function() {
      Sensori.Views.GalleryEditor.restore();
    });
    it("should initialize and render a gallery editor with the content", function() {
      view.addGalleryEditor("content!");
      
      expect(Sensori.Views.GalleryEditor.callCount).toEqual(1);
      expect(Sensori.Views.GalleryEditor.calledWith({ content: "content!" })).toBe(true);
      
      expect(mockSubview.render.callCount).toEqual(1);
    });
    it("should append the text editor view to this.subviews and append the element to the .editor element", function(){
      view.addGalleryEditor("content!");

      expect(view.subviews.length).toEqual(3);
      expect(view.subviews[2]).toEqual(mockSubview);

      expect(mockSubview.$el.closest(view.$('.editor')).length).toEqual(1);
    });
  });

  describe(".save()", function() {
    beforeEach(function() {
      sinon.stub(model, "save");
      sinon.stub(view, "getHTMLValue").returns("html value");
      sinon.stub(view, "getJSONValue").returns("json value");
      sinon.stub(view, "saveSuccess");
      sinon.stub(view, "saveError");
      view.$el.append([
        "<input type='text' value='title' id='tutorial_title' />",
        "<input type='text' value='description' id='tutorial_description' />",
        "<input type='text' value='youtube_id' id='tutorial_youtube_id' />",
      ].join(""));
    });
    it("should set model attributes from input and component values", function() {
      view.save();
      expect(view.model.get("title")).toEqual("title");
      expect(view.model.get("description")).toEqual("description");
      expect(view.model.get("youtube_id")).toEqual("youtube_id");
      expect(view.getHTMLValue.callCount).toEqual(1);
      expect(view.getJSONValue.callCount).toEqual(1);
      expect(view.model.get("body_html")).toEqual("html value");
      expect(view.model.get("body_components")).toEqual("json value");
    });
    it("should save the model with success and error callbacks", function() {
      view.save();
      expect(model.save.callCount).toEqual(1);
      var saveCall = model.save.getCall(0);
      expect(saveCall.args[0]).toEqual(null);
      
      saveCall.yieldTo("success");
      expect(view.saveSuccess.callCount).toEqual(1);

      saveCall.yieldTo("error");
      expect(view.saveError.callCount).toEqual(1);
    });
  });

  describe(".publish()", function() {
    beforeEach(function() {
      sinon.stub(model, "publish");
      sinon.stub(view, "publishSuccess");
      sinon.stub(view, "publishError");
    });
    it("should publish", function() {
      view.publish();

      expect(model.publish.callCount).toEqual(1);

      var publishCall = model.publish.getCall(0);
      
      publishCall.yieldTo("success");
      expect(view.publishSuccess.callCount).toEqual(1);

      publishCall.yieldTo("error");
      expect(view.publishError.callCount).toEqual(1);
    });
  });


  describe(".getHTMLValue()", function() {
    it("should return the HTML value of each subview joined together", function() {
      var subview1 = { getHTMLValue: sinon.stub().returns("<p>content 1</p>") },
          subview2 = { getHTMLValue: sinon.stub().returns("<p>content 2</p>") };

      view.subviews = [subview1, subview2];

      expect(view.getHTMLValue()).toEqual("<p>content 1</p>\n<p>content 2</p>");

      expect(subview1.getHTMLValue.callCount).toEqual(1);
      expect(subview2.getHTMLValue.callCount).toEqual(1);
    });
  });

  describe(".getJSONValue()", function() {
    it("should return an array with the JSON value of each subview", function() {
      var subview1 = { getJSONValue: sinon.stub().returns({ type: "text", content: "content 1"}) },
          subview2 = { getJSONValue: sinon.stub().returns({ type: "gallery", content: "content 2"}) };

      view.subviews = [subview1, subview2];

      expect(view.getJSONValue()).toEqual([
        { type: "text", content: "content 1"},
        { type: "gallery", content: "content 2"}
      ]);

      expect(subview1.getJSONValue.callCount).toEqual(1);
      expect(subview2.getJSONValue.callCount).toEqual(1);
    });
  });

  describe(".saveSuccess()", function() {
    beforeEach(function(){ 
      view.render();
      sinon.stub($.fn, "fadeIn");
      sinon.stub($.fn, "notice");
    });
    afterEach(function() {
      $.fn.notice.restore()
      $.fn.fadeIn.restore()
    });
    it("should show the preview and publish tutorial buttons if the tutorial is not published yet", function() {
      view.saveSuccess()
      expect($.fn.fadeIn.callCount).toEqual(2);
      expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual("[data-trigger='publish-tutorial']")
      expect($.fn.fadeIn.getCall(1).thisValue.selector).toEqual("[data-trigger='preview-tutorial']")
    });
    it("should show the preview and view tutorial buttons if the tutorial is already published", function() {
      view.model.set("published", true);
      view.saveSuccess()
      expect($.fn.fadeIn.callCount).toEqual(2);
      expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual("[data-trigger='view-tutorial']")
      expect($.fn.fadeIn.getCall(1).thisValue.selector).toEqual("[data-trigger='preview-tutorial']")
    });
    it("should render a success notice", function() {
      view.saveSuccess();
      expect($.fn.notice.callCount).toEqual(1);
      expect($.fn.notice.getCall(0).thisValue.selector).toEqual(view.$el.selector);
    });
  });

  describe(".saveError()", function() {
    beforeEach(function(){ 
      view.render();
      sinon.stub($.fn, "notice");
    });
    afterEach(function() {
      $.fn.notice.restore()
    });
    it("should render an error notice", function() {
      view.saveError();
      expect($.fn.notice.callCount).toEqual(1);
      expect($.fn.notice.getCall(0).thisValue.selector).toEqual(view.$el.selector);
      expect($.fn.notice.getCall(0).args[0].type).toEqual("error");
    });
  });

  describe(".publishSuccess()", function() {
    beforeEach(function() {
      view.render();
      sinon.stub($.fn, "fadeOut");
      sinon.stub($.fn, "fadeIn");
      sinon.stub($.fn, "notice");
    });
    afterEach(function() {
      $.fn.fadeIn.restore()
      $.fn.fadeOut.restore()
      $.fn.notice.restore()
    });
    it("should hide the publish tutorial button and show the view tutorial button", function() {
      view.publishSuccess()
      expect($.fn.fadeOut.callCount).toEqual(1);
      expect($.fn.fadeOut.getCall(0).thisValue.selector).toEqual("[data-trigger='publish-tutorial']");

      $.fn.fadeOut.yield();
      expect($.fn.fadeIn.callCount).toEqual(1);
      expect($.fn.fadeIn.getCall(0).thisValue.selector).toEqual("[data-trigger='view-tutorial']");
    });
    it("should render a success notice", function() {
      view.saveSuccess();
      expect($.fn.notice.callCount).toEqual(1);
      expect($.fn.notice.getCall(0).thisValue.selector).toEqual(view.$el.selector);
    });
  });

  describe(".redirectToEditURL()", function() {
    it("should redirect to the edit URL for this.model", function() {
      sinon.stub(Sensori, "pushState");

      view.model.set("slug", "/tutorials/title--123")
      view.redirectToEditURL()
      expect(Sensori.pushState.callCount).toEqual(1);
      expect(Sensori.pushState.calledWith("/tutorials/title--123/edit")).toBe(true);

      Sensori.pushState.restore();
    });
  });

  describe(".disableAttachmentButton()", function() {
    it("should disable the attachment button", function() {
      view.disableAttachmentButton();
      expect(view.$(".attachment-button").hasClass("disabled")).toBe(true);
    });
  });

  describe(".enableAttachmentButton()", function() {
    it("should the attachment button and set the href from the model's attachment_url", function() {
      view.$(".attachment-button").addClass("disabled");
      model.set("attachment_url", "http://s3.amazon.com/download.zip");
      view.enableAttachmentButton();
      expect(view.$(".attachment-button").hasClass("disabled")).toBe(false);
      expect(view.$(".attachment-button").attr("href")).toEqual("http://s3.amazon.com/download.zip");
    });
  });

  describe(".renderAttachmentUploader()", function() {
    beforeEach(function() {
      mockSubview = {
        on: sinon.stub(),
        render: sinon.stub()
      };
      mockSubview.render.returns(mockSubview);
      sinon.stub(Sensori.Views, "AttachmentUploader").returns(mockSubview);
      model.on = sinon.stub();
    });
    afterEach(function() {
      Sensori.Views.AttachmentUploader.restore();
    });
    it("should set this.attachmentUploader to an attachment uploader view", function() {
      view.renderAttachmentUploader();

      expect(Sensori.Views.AttachmentUploader.callCount).toEqual(1);
      expect(Sensori.Views.AttachmentUploader.calledWith({
        model: view.model,
        el: view.$(".attachment-container")
      })).toBe(true);

      expect(mockSubview.render.callCount).toEqual(1);
    });
    it("should bind this.disableAttachmentButton to run when an 'upload:add' event is triggered", function() {
      view.renderAttachmentUploader();
      expect(mockSubview.on.callCount).toEqual(1);
      expect(mockSubview.on.calledWith("upload:add", view.disableAttachmentButton, view)).toBe(true);
    });
    it("should bind this.enableAttachmentButton to run when the model's attachment_url is changed", function() {
      view.renderAttachmentUploader();
      expect(model.on.callCount).toEqual(1);
      expect(model.on.calledWith("change:attachment_url", view.enableAttachmentButton, view)).toBe(true);
    });
  });

  describe(".preview()", function() {
    beforeEach(function() {
      sinon.stub($.fn, "submit");
      sinon.stub(view, "getHTMLValue").returns("body html");
      model.set({
        title: "wah effect",
        description: "how to make one",
        youtube_id: "123",
        attachment_url: "http://s3.amazon.com/wah.zip",
        slug: "wah-effect--123"
      });
    });
    afterEach(function() {
      $.fn.submit.restore()
    });
    it("should render and submit a preview form based on tutorial data", function() {
      view.preview();
      
      expect($.fn.submit.callCount).toEqual(1);

      var form = $.fn.submit.getCall(0).thisValue;

      expect(form.attr("action")).toEqual("/tutorials/wah-effect--123/preview");
      expect(form.attr("method")).toEqual("POST");
      expect(form.attr("target")).toEqual("_blank");

      expect(form.find("input#tutorial_title").val()).toEqual(model.get("title"));
      expect(form.find("input#tutorial_description").val()).toEqual(model.get("description"));
      expect(form.find("input#tutorial_youtube_id").val()).toEqual(model.get("youtube_id"));
      expect(form.find("input#tutorial_attachment_url").val()).toEqual(model.get("attachment_url"));
      expect(form.find("input#tutorial_body_html").val()).toEqual("body html");
      
      expect(view.getHTMLValue.callCount).toEqual(1);
    });
  });

  describe(".show()", function() {
    beforeEach(function() {
      sinon.stub(Sensori, "redirect");
    });
    afterEach(function() {
      Sensori.redirect.restore();
    });
    it("should redirect to the tutorial show url", function() {
      model.set("slug", "title--123");
      view.show();
      expect(Sensori.redirect.callCount).toEqual(1);
      expect(Sensori.redirect.calledWith("/tutorials/title--123")).toBe(true);
    });
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub(view, "addComponent");
      sinon.stub(view, "renderAttachmentUploader");
      model.set("body_components", [{ type: "text", content: "<p>This is how I think?</p>" }]);
    });
    it("should set this.editor to the '.editor' element", function() {
      view.render();
      expect(view.editor).toEqual(view.$(".editor"));
    });
    it("should add a component for each object the model's body_components", function() {
      view.render();
      expect(view.addComponent.callCount).toEqual(1);
      expect(view.addComponent.calledWith({ type: "text", content: "<p>This is how I think?</p>" })).toBe(true);
    });
    it("should render an attachment uploader", function() {
      view.render();
      expect(view.renderAttachmentUploader.callCount).toEqual(1);
    });
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  });
});