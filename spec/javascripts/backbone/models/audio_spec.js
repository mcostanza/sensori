describe("Sensori.Models.Audio", function() {
  var audio,
      mockSound;

  beforeEach(function() {
    mockSound = 'sound object';
    sinon.stub(soundManager, 'createSound').returns(mockSound);
    audio = new Sensori.Models.Audio({ url: 'http://stream.com/song.wav', name: 'Bob Swurl' });
  });
  afterEach(function() {
    soundManager.createSound.restore();
  });

  it("should extend Backbone.Model", function() {
    audio = new Sensori.Models.Audio();
    expect(audio instanceof Backbone.Model).toBe(true);
  });

  describe(".title()", function() {
    it("should return the 'name' attribute of the audio", function() {
      expect(audio.title()).toEqual("Bob Swurl");
    });
  });

  describe(".initialize()", function() {
    it("should set the status to 'stopped'", function() {
      expect(audio.status).toBe('stopped');
    });
    // This is where the functionality of .prepareSoundObject is tested
    it("should initialize the sound object", function() {
      expect(soundManager.createSound.callCount).toBe(1);
      var createSoundCall = soundManager.createSound.getCall(0);
      expect(createSoundCall.args[0]).toEqual({ url: audio.get("url") });
      expect(audio.soundObject).toBe(mockSound);
    });
  });

  describe(".prepareSoundObject()", function() {
    // This is not intended to be called directly and is tested in the initialize() test block
  });

  describe(".play()", function() {
    beforeEach(function() {
      audio.soundObject = { play: sinon.stub() };
      sinon.stub(audio, 'trigger');
    });
    it("should call play on the soundObject", function() {
      audio.play();
      expect(audio.soundObject.play.callCount).toBe(1);
    });
    it("should trigger a finished event and set the status to stopped when finished playing", function() {
      sinon.stub(audio, 'updateStatus');
      audio.play();
      audio.soundObject.play.yieldTo("onfinish");
      expect(audio.trigger.calledWith('finished', audio)).toBe(true);
      expect(audio.updateStatus.calledWith('stopped')).toBe(true);
    });
    it("should set the status to 'playing'", function() {
      audio.play();
      expect(audio.status).toBe('playing');
    });
    it("should fire a status:change and status:changed events", function() {
      audio.play();
      expect(audio.trigger.callCount).toBe(2);
      expect(audio.trigger.calledWith('status:changing', audio, 'playing')).toBe(true);
      expect(audio.trigger.calledWith('status:changed', audio)).toBe(true);
      // ensure the ordering
      expect(audio.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(audio.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".pause()", function() {
    beforeEach(function() {
      audio.soundObject = { pause: sinon.stub() };
      sinon.stub(audio, 'trigger');
    });
    it("should call pause on the soundObject", function() {
      audio.pause();
      expect(audio.soundObject.pause.callCount).toBe(1);
    });
    it("should set the status to 'paused'", function() {
      audio.pause();
      expect(audio.status).toBe('paused');
    });
    it("should fire a status:change and status:changed events", function() {
      audio.pause();
      expect(audio.trigger.callCount).toBe(2);
      expect(audio.trigger.calledWith('status:changing', audio, 'paused')).toBe(true);
      expect(audio.trigger.calledWith('status:changed', audio)).toBe(true);
      // ensure the ordering
      expect(audio.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(audio.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".stop()", function() {
    beforeEach(function() {
      audio.soundObject = { stop: sinon.stub() };
      sinon.stub(audio, 'trigger');
    });
    it("should call stop on the soundObject", function() {
      audio.stop();
      expect(audio.soundObject.stop.callCount).toBe(1);
    });
    it("should set the status to 'stopped'", function() {
      audio.stop();
      expect(audio.status).toBe('stopped');
    });
    it("should fire a status:change and status:changed events", function() {
      audio.stop();
      expect(audio.trigger.callCount).toBe(2);
      expect(audio.trigger.calledWith('status:changing', audio, 'stopped')).toBe(true);
      expect(audio.trigger.calledWith('status:changed', audio)).toBe(true);
      // ensure the ordering
      expect(audio.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(audio.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".updateStatus(status)", function() {
    beforeEach(function() {
      sinon.stub(audio, 'trigger');
    });
    it("should set the status to the passed status", function() {
      expect(audio.status).toBe('stopped');
      audio.updateStatus('playing');
      expect(audio.status).toBe('playing');
    });
    it("should fire a status:changed event", function() {
      audio.updateStatus('playing');
      expect(audio.trigger.callCount).toBe(1);
      expect(audio.trigger.calledWith('status:changed', audio)).toBe(true);
    });
  });
});

