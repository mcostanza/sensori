describe("Sensori.Views.Discussion", function() {
	var view,
      model,
      event;

  beforeEach(function() {
    model = new Sensori.Models.Discussion();
    view = new Sensori.Views.DiscussionPreview({
      model: model
    });
  });

  describe("template", function() {
    it("should be set to the discussions preview template", function() {
      expect(view.template).toEqual(JST["backbone/templates/discussions/discussion_preview"]);
    });
  });

  describe(".render()", function() {
    beforeEach(function() {
      sinon.stub(view, 'template');
    });
    it("should render the template with the discussion", function() {
      view.render();
      expect(view.template.callCount).toBe(1);
      expect(view.template.calledWith({ discussion: view.model })).toBe(true);
    });
    it("should set the view element to the rendered template", function() {
      view.template.returns('template');
      sinon.stub(view, 'setElement');
      view.render();
      expect(view.setElement.callCount).toBe(1);
      expect(view.setElement.calledWith('template')).toBe(true);
    });
    it("should return itself", function() {
      expect(view.render()).toBe(view);
    });
  });

  describe("events", function() {
    it("should fire the onHover callback when the element is hovered", function() {
      expect(view.events["hover"]).toEqual("onHover");
    });
    it("should fire the onClick callback when the element is clicked", function() {
      expect(view.events["click"]).toEqual("onClick");
    });
  });

  describe(".onHover", function() {
    beforeEach(function() {
      view = new Sensori.Views.DiscussionPreview({
        model: model,
        el: $("<div>")
      });
    });
    it("should add the 'hover' class on mouseenter events", function() {
      var event = { type: 'mouseenter' };
      view.onHover(event);
      expect(view.$el.hasClass('hover')).toBe(true);
    });
    it("should remove the 'hover' class on mouseleave events", function() {
      var event = { type: 'mouseenter' };
      view.onHover(event);
      event.type = 'mouseleave';
      view.onHover(event);
      expect(view.$el.hasClass('hover')).toBe(false);
    });
    it("should do nothing for other event types", function() {
      var event = { type: 'mousewhuteva' };
      view.onHover(event);
      expect(view.$el.hasClass('hover')).toBe(false);
    });
  });

  describe(".onClick", function() {
    beforeEach(function() {
      sinon.stub(Sensori, 'redirect');
      event = { preventDefault: sinon.stub(), target: '<div></div>' };
      sinon.stub(view.model, 'url').returns('/url');
    });
    afterEach(function() {
      Sensori.redirect.restore();
    });
    it("should prevent the default behavior", function() {
      view.onClick(event);
      expect(event.preventDefault.callCount).toBe(1);
    });
    it("should redirect to the model's url", function() {
      view.onClick(event);
      expect(Sensori.redirect.callCount).toBe(1);
      expect(Sensori.redirect.calledWith('/url')).toBe(true);
    });
    it("should do nothing if the target element is an 'a'", function() {
      event.target = '<a href="">test</a>';
      view.onClick(event);
      expect(event.preventDefault.callCount).toBe(0);
      expect(Sensori.redirect.callCount).toBe(0);
    });
  });
});

