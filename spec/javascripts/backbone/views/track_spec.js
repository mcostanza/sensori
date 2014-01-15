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

  it("should extend Sensori.Views.Audio", function() {
    expect(view instanceof Sensori.Views.Audio).toBe(true);
  });

  describe("events", function() {
    it("should fire the onClick callback when the element overlay is clicked", function() {
      expect(view.events["click .overlay"]).toEqual("onClick");
    });
  });
});
