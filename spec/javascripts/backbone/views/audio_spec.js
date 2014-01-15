describe("Sensori.Views.Audio", function() {
	var view,
      model,
      el,
      mockAudio,
      clickEvent;

  beforeEach(function() {
    sinon.stub(soundManager, 'createSound');
    mockAudio = new Sensori.Models.Audio();
    el = $("<a data-type='audio' href='http://stream.com/sound.wav'>Drums 88bpm</a>");
    view = new Sensori.Views.Audio({ el: el });
    clickEvent = { preventDefault: sinon.stub() };
  });
  afterEach(function() {
    soundManager.createSound.restore();
  });

  describe("events", function() {
    it("should fire the onClick callback when the element is clicked", function() {
      expect(view.events["click"]).toEqual("onClick");
    });
  });

  describe(".initialize()", function() {
    it("should setup the model with element data if it is not passed", function() {
      sinon.stub(Sensori.Models, 'Audio').returns(mockAudio);
      view = new Sensori.Views.Audio({ el: el });
      expect(Sensori.Models.Audio.callCount).toBe(1);
      expect(Sensori.Models.Audio.calledWith({ url: 'http://stream.com/sound.wav', name: 'Drums 88bpm' })).toBe(true);
      expect(view.model).toBe(mockAudio);

      Sensori.Models.Audio.restore();
    });
    it("should not setup the model if it is passed", function() {
      sinon.stub(Sensori.Models, 'Audio');
      view = new Sensori.Views.Audio({ el: el, model: mockAudio });
      expect(Sensori.Models.Audio.callCount).toBe(0);
      expect(view.model).toBe(mockAudio);

      Sensori.Models.Audio.restore();
    });
    it("should update the status class when the audio's status changes", function() {
      expect(view.$el.hasClass('playing')).toBe(false);
      view.model.updateStatus('playing');
      expect(view.$el.hasClass('playing')).toBe(true);
    });
    it("should add an audio-id data attribute to the element with the model's cid", function() {
      expect(view.$el.data('audio-id')).toBe(view.model.cid);
    });
  });

  describe(".onClick", function() {
    beforeEach(function() {
      sinon.stub(view.model, 'play');
      sinon.stub(view.model, 'pause');
    });
    it("should play the audio if the status is stopped", function() {
      view.model.status = 'stopped';
      view.onClick(clickEvent);
      expect(view.model.play.callCount).toBe(1);
    });
    it("should play the audio if the status is paused", function() {
      view.model.status = 'paused';
      view.onClick(clickEvent);
      expect(view.model.play.callCount).toBe(1);
    });
    it("should pause the audio if the status is playing", function() {
      view.model.status = 'playing';
      view.onClick(clickEvent);
      expect(view.model.pause.callCount).toBe(1);
    });
  });

  describe(".updateStatusClass()", function() {
    it("should update the elements class with the audio status", function() {
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

