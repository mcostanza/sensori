describe("Sensori.Views.MediaEditor", function() {
  var view,
      imageModel,
      parentView;

  beforeEach(function() {
    parentView = new Sensori.Views.GalleryEditor()

    imageModel = {
      type: "image",
      title: "Rat near a trash can",
      src: "http://s3.amazon.com/sensori/pictures/1.jpg"
    };

    view = new Sensori.Views.MediaEditor({
      model: imageModel,
      galleryView: parentView
    })
  });

  describe(".initialize(options)", function() {
    it("should set this.galleryView from options", function() {
      expect(view.galleryView).toEqual(parentView);
    });
    it("should set this.mediaType to the model type", function() {
      expect(view.mediaType).toEqual(imageModel.type);
    });
    it("should set this.mediaTemplate based on the media type", function() {
      expect(view.mediaTemplate).toEqual(JST["backbone/templates/tutorials/image"]);
    });
    it("should set this.template based on the media type", function() {
      expect(view.template).toEqual(JST["backbone/templates/tutorials/image_editor"]);
    });
  });

  describe(".$el", function() {
    it("should be a span", function() {
      expect(view.$el.prop("tagName")).toEqual("SPAN");
    });
  });

  describe("tagName", function() {
    it("should be set to span", function() {
      expect(view.tagName).toBe("span");
    });
  });

  describe("popoverTemplate", function() {
    it("should be set to the media popover template", function() {
      expect(view.popoverTemplate).toEqual(JST["backbone/templates/tutorials/media_popover"]);
    });
  });

  describe("events", function() {
    it("should call togglePopover when the edit-media trigger is clicked", function() {
      expect(view.events["click [data-trigger='edit-media']"]).toEqual("togglePopover");
    });
    it("should call setAttributes when the save-media trigger is clicked", function() {
      expect(view.events["click [data-trigger='save-media']"]).toEqual("setAttributes");
    });
    it("should call setAttributesOnEnter when the .media-title-input class recieves a keypress", function() {
      expect(view.events["keypress .media-title-input"]).toEqual("setAttributesOnEnter");
    });
    it("should call removeMedia when the remove-media trigger is clicked", function() {
      expect(view.events["click [data-trigger='remove-media']"]).toEqual("removeMedia");
    });
  });

  describe(".togglePopover()", function() {
    beforeEach(function() {
      view.render();
      sinon.spy(view.editLink, "popover");
    });
    it("should toggle the element's popover", function() {
      view.togglePopover();
      expect(view.editLink.popover.callCount).toEqual(1);
      expect(view.editLink.popover.calledWith('toggle')).toEqual(true);
    });
    it("should set popover's input with the model's title", function() {
      view.togglePopover();
      expect(view.$(".media-title-input").val()).toEqual(imageModel.title);
    });
  });

  describe(".setAttributes()", function() {
    beforeEach(function() {
      view.render().togglePopover();
      sinon.spy(view.editLink, "popover");
    });
    it("should set this.model.title to the value of the popover's input", function() {
      view.$(".media-title-input").val("new title");
      view.setAttributes();
      expect(imageModel.title).toEqual("new title");
    });
    it("should hide the popover", function() {
      view.setAttributes();
      expect(view.editLink.popover.callCount).toEqual(1);
      expect(view.editLink.popover.calledWith('hide')).toEqual(true);
    });
    it("should set the title to an html-escaped value", function() {
      view.$(".media-title-input").val('This "Has Some Quotes" And Shit');
      view.setAttributes()
      expect(imageModel.title).toEqual("This &quot;Has Some Quotes&quot; And Shit");
    });
  });

  describe(".setAttributesOnEnter()", function() {
    beforeEach(function() {
      view.render();
      sinon.stub(view, "setAttributes");
    });
    it("should call setAttributes when the enter key is pressed", function() {
      view.setAttributesOnEnter({ keyCode: 13 });
      expect(view.setAttributes.callCount).toBe(1);
    });
    it("should not call setAttributes for other keys", function() {
      view.setAttributesOnEnter({ keyCode: 10 });
      view.setAttributesOnEnter({ keyCode: 11 });
      view.setAttributesOnEnter({ keyCode: 12 });
      expect(view.setAttributes.callCount).toBe(0);
    });
  });

  describe(".removeMedia()", function() {
    beforeEach(function() {
      view.render();
      sinon.stub(view.editLink, "popover");
      sinon.stub(parentView, "removeMedia");
    });
    it("should hide the element's popover", function() {
      view.removeMedia();
      expect(view.editLink.popover.callCount).toEqual(1);
      expect(view.editLink.popover.calledWith('hide')).toEqual(true);
    });
    it("should call removeMedia on the parent view", function() {
      view.removeMedia();
      expect(parentView.removeMedia.callCount).toEqual(1);
      expect(parentView.removeMedia.calledWith(view)).toEqual(true);
    });
  });

  describe(".getHTMLValue()", function() {
    it("should return the media template with model attributes", function() {
      expect(view.getHTMLValue()).toEqual(view.mediaTemplate(imageModel));
    });
  });

  describe(".getJSONValue()", function() {
    it("should return a JSON object with type, src, and title attributes based on the model", function() {
      var expected = {
        type: "image",
        src: "http://s3.amazon.com/sensori/pictures/1.jpg",
        title: "Rat near a trash can"
      };
      expect(view.getJSONValue()).toEqual(expected);
    })
  });

  describe(".render()", function() {
    it("should set the element content from the editor template", function() {
      view.render();
      expect(view.$("[data-trigger='edit-media']").length).toEqual(1);
      expect(view.$("img").prop("src")).toContain("/assets/loader.gif");
      expect(view.$("img").prop("title")).toEqual(imageModel.title);
      expect(view.$("img").attr("data-src")).toEqual(imageModel.src);
    });
    it("should set this.editLink to the element with the edit-media trigger", function() {
      view.render();
      expect(view.editLink).toEqual(view.$("[data-trigger='edit-media']"));
    });
    it("should initialize a popover on the edit-media element with content from the popover template", function() {
      var editLink = { popover: sinon.spy() };
      sinon.stub(view, '$').withArgs("[data-trigger='edit-media']").returns(editLink);
      view.render();
      expect(view.editLink.popover.callCount).toEqual(1);
      expect(view.editLink.popover.calledWith({
        html: true,
        content: view.popoverTemplate(),
        trigger: 'manual',
        placement: 'top'
      })).toEqual(true);
    });
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  });
});
