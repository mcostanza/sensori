describe("Sensori.Views.Discussion", function() {
	var view,
      model;

  beforeEach(function() {
    model = new Sensori.Models.Discussion();
    view = new Sensori.Views.DiscussionPreview({
      model: model;
    });
  });

  describe("template", function() {
    it("should be set to the discussions preview template", function() {
      expect(view.template).toEqual(JST["backbone/templates/discussions/discussion_preview"]);
    });
  });

  describe(".render()", function() {
    it("should render the template with the discussion", function() {
      sinon.stub(view, 'template');
      view.render();
      expect(view.template.callCount).toBe(1);
      expect(view.template.calledWith({ discussion: view.model })).toBe(true);
    });
    it("should set the view element to the rendered template", function() {
      sinon.stub(view, 'template').returns('template');
      sinon.stub(view, 'setElement');
      view.render();
      expect(view.setElement.callCount).toBe(1);
      expect(view.setElement.calledWith('template')).toBe(true);
    });
    it("should return itself", function() {
      expect(view.render()).toBe(view);
    });
  });
});

