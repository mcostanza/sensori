describe("Sensori.Views.Track", function() {
	var view,
      model,
      el;

  beforeEach(function() {
    sinon.stub(SC, 'stream');
    model = new Sensori.Models.Track({ stream_url: 'http://stream.com' });
    el = $("<div class='thumbnail'><div class='thumbnail-wrapper'><a class='overlay' href='javascript:;'></a></div></div>");
    view = new Sensori.Views.Track({ model: model, el: el });
  });
  afterEach(function() {
    SC.stream.restore();
  });

  describe("events", function() {
    it("should fire the onClick callback when the element overlay is clicked", function() {
      expect(view.events["click .overlay"]).toEqual("onClick");
    });
  });

  describe(".initialize()", function() {
    it("should update the status class when the track's status changes", function() {
      expect(view.$el.hasClass('playing')).toBe(false);
      model.updateStatus('playing');
      expect(view.$el.hasClass('playing')).toBe(true);
    });
  });

  describe(".onClick", function() {
    beforeEach(function() {
      sinon.stub(view.model, 'play');
      sinon.stub(view.model, 'pause');
    });
    it("should play the track if the status is stopped", function() {
      view.model.status = 'stopped';
      view.onClick();
      expect(view.model.play.callCount).toBe(1);
    });
    it("should play the track if the status is paused", function() {
      view.model.status = 'paused';
      view.onClick();
      expect(view.model.play.callCount).toBe(1);
    });
    it("should pause the track if the status is playing", function() {
      view.model.status = 'playing';
      view.onClick();
      expect(view.model.pause.callCount).toBe(1);
    });
  });

  describe(".updateStatusClass()", function() {
    it("should update the elements class with the track status", function() {
      view.model.status = 'playing';
      view.updateStatusClass();
      expect(view.$el.hasClass('playing')).toBe(true);
    });
    it("should remove current status classes from teh element", function() {
      view.model.status = 'paused';
      view.$el.addClass('stopped');
      view.updateStatusClass();
      expect(view.$el.hasClass('stopped')).toBe(false);
      expect(view.$el.hasClass('paused')).toBe(true);
    });
  });
});
