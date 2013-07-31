describe("Sensori.Views.ImageEditor", function() {
  var view,
      imageModel,
      parentView;

  beforeEach(function() {
    // TODO: replace with Sensori.Views.Gallery instance when implemented
    parentView = {
      trigger: sinon.spy()
    };

    imageModel = {
      type: "image",
      title: "Rat near a trash can",
      src: "http://s3.amazon.com/sensori/pictures/1.jpg"
    };

    view = new Sensori.Views.ImageEditor({
      model: imageModel,
      galleryView: parentView
    })
  });

  describe(".initialize(options)", function() {
    it("should set this.galleryView from options", function() {
      expect(view.galleryView).toEqual(parentView)
    });
  });

  describe(".$el", function() {
    it("should be an li with popover-link class", function() {
      expect(view.$el.prop("tagName")).toEqual("LI");
      expect(view.$el.hasClass("popover-link")).toEqual(true);
    });
  });

  describe(".showPopover()", function() {
    beforeEach(function() {
      view.render();
      sinon.spy(view.$el, "popover");
    });
    it("should show the element's popover", function() {
      view.showPopover();
      expect(view.$el.popover.callCount).toEqual(1);
      expect(view.$el.popover.calledWith('show')).toEqual(true);
    });
    it("should set the image title input value to this.model.title", function() {
      view.showPopover();
      expect(view.$(".image-title").val()).toEqual(imageModel.title);
    });
  });

  describe(".setAttributes()", function() {
    beforeEach(function() {
      view.render().showPopover();
      sinon.spy(view.$el, "popover");
    });
    it("should set this.model.title to the image title input value", function() {
      view.$(".image-title").val("new title");
      view.setAttributes();
      expect(imageModel.title).toEqual("new title");
    });
    it("should hide the popover", function() {
      view.setAttributes();
      expect(view.$el.popover.callCount).toEqual(1);
      expect(view.$el.popover.calledWith('hide')).toEqual(true);
    });
  });

  describe(".removeImage()", function() {
    beforeEach(function() {
      view.render();
      sinon.stub(view.$el, "popover");
      sinon.stub(view, "remove");
    });
    it("should hide the element's popover", function() {
      view.removeImage();
      expect(view.$el.popover.callCount).toEqual(1);
      expect(view.$el.popover.calledWith('hide')).toEqual(true);
    });
    it("should remove the view", function() {
      view.removeImage();
      expect(view.remove.callCount).toEqual(1);
    });
    it("should trigger a 'removeItem' event on the gallery view", function() {
      view.removeImage();
      expect(parentView.trigger.callCount).toEqual(1);
      expect(parentView.trigger.calledWith('removeItem', view)).toEqual(true);
    });
  });

  describe(".getHTMLValue()", function() {
    it("should return an image tag with model attributes", function() {
      var expected = "<img src=\"/assets/loader.gif\" data-src=\"http://s3.amazon.com/sensori/pictures/1.jpg\" title=\"Rat near a trash can\" />";
      expect(view.getHTMLValue()).toEqual(expected);
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
    beforeEach(function() {
      sinon.spy(view.$el, "popover");
    });
    it("should set the element content from the tutorials/thumbnail template", function() {
      view.render();
      expect(view.$("span[data-trigger='edit-image']").length).toEqual(1);
      expect(view.$("img").prop("src")).toEqual(imageModel.src);
      expect(view.$("img").prop("title")).toEqual(imageModel.title);
    });
    it("should initialize a popover on the element with content from the tutorials/thumbnail_popover template", function() {
      view.render();
      expect(view.$el.popover.callCount).toEqual(1);
      expect(view.$el.popover.calledWith({
        html: true,
        content: JST["backbone/templates/tutorials/thumbnail_popover"](),
        container: view.$el,
        trigger: 'manual'
      })).toEqual(true);
    });
    it("should return itself", function() {
      expect(view.render()).toEqual(view);
    });
  });
});