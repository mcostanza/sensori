describe("Sensori.Models.Track", function() {
  var track,
      mockSound;

  beforeEach(function() {
    sinon.stub(SC, 'stream');
    track = new Sensori.Models.Track({ stream_url: 'http://stream.com' });
  });
  afterEach(function() {
    SC.stream.restore();
  });

  it("should extend Backbone.Model", function() {
    track = new Sensori.Models.Track();
    expect(track instanceof Backbone.Model).toBe(true);
  });

  describe(".url()", function() {
    it("should return /tracks for new records", function() {
      track = new Sensori.Models.Track();
      expect(track.url()).toEqual("/tracks");
    });
    it("should return /tracks/:id for existing records", function() {
      track = new Sensori.Models.Track({ id: 3 });
      expect(track.url()).toEqual("/tracks/3");
    });
  });

  describe(".initialize()", function() {
    beforeEach(function() {
      mockMember = { name: 'John' };
      sinon.stub(Sensori.Models, "Member").returns(mockMember);
    });
    afterEach(function() {
      Sensori.Models.Member.restore();
    });
    it("should set the status to 'stopped'", function() {
      expect(track.status).toBe('stopped');
    });
    // This is where the functionality of .prepareSoundObject is tested
    it("should initialize the sound object", function() {
      expect(SC.stream.callCount).toBe(1);
      var streamCall = SC.stream.getCall(0);
      expect(streamCall.args[0]).toBe(track.get("stream_url"));
      streamCall.yield("sound object");
      expect(track.soundObject).toBe("sound object");
    });
    it("should set member to a new Sensori.Models.Member if set in attributes", function() {
      var trackAttrs = { title: 'test', member: { name: 'John' } };
      track = new Sensori.Models.Track(trackAttrs);
      expect(Sensori.Models.Member.callCount).toBe(1);
      expect(Sensori.Models.Member.calledWith(trackAttrs.member)).toBe(true);
    });
    it("should unset the member attribute if passed", function() {
      var trackAttrs = { title: 'test', member: { name: 'John' } };
      track = new Sensori.Models.Track(trackAttrs);
      expect(track.attributes['member']).not.toBeDefined();
    });
    it("should not set member if the member attribute is not passed", function() {
      track = new Sensori.Models.Track();
      expect(track.member).not.toBeDefined();
    });
  });

  describe(".prepareSoundObject()", function() {
    // This is not intended to be called directly and is tested in the initialize() test block
  });

  describe(".play()", function() {
    beforeEach(function() {
      track.soundObject = { play: sinon.stub() };
      sinon.stub(track, 'trigger');
    });
    it("should call play on the soundObject", function() {
      track.play();
      expect(track.soundObject.play.callCount).toBe(1);
      track.soundObject.play.yieldTo("onfinish");
      expect(track.trigger.calledWith('finished', track)).toBe(true);
    });
    it("should set the status to 'playing'", function() {
      track.play();
      expect(track.status).toBe('playing');
    });
    it("should fire a status:change and status:changed events", function() {
      track.play();
      expect(track.trigger.callCount).toBe(2);
      expect(track.trigger.calledWith('status:changing', track, 'playing')).toBe(true);
      expect(track.trigger.calledWith('status:changed', track)).toBe(true);
      // ensure the ordering
      expect(track.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(track.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".pause()", function() {
    beforeEach(function() {
      track.soundObject = { pause: sinon.stub() };
      sinon.stub(track, 'trigger');
    });
    it("should call pause on the soundObject", function() {
      track.pause();
      expect(track.soundObject.pause.callCount).toBe(1);
    });
    it("should set the status to 'paused'", function() {
      track.pause();
      expect(track.status).toBe('paused');
    });
    it("should fire a status:change and status:changed events", function() {
      track.pause();
      expect(track.trigger.callCount).toBe(2);
      expect(track.trigger.calledWith('status:changing', track, 'paused')).toBe(true);
      expect(track.trigger.calledWith('status:changed', track)).toBe(true);
      // ensure the ordering
      expect(track.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(track.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".stop()", function() {
    beforeEach(function() {
      track.soundObject = { stop: sinon.stub() };
      sinon.stub(track, 'trigger');
    });
    it("should call stop on the soundObject", function() {
      track.stop();
      expect(track.soundObject.stop.callCount).toBe(1);
    });
    it("should set the status to 'stopped'", function() {
      track.stop();
      expect(track.status).toBe('stopped');
    });
    it("should fire a status:change and status:changed events", function() {
      track.stop();
      expect(track.trigger.callCount).toBe(2);
      expect(track.trigger.calledWith('status:changing', track, 'stopped')).toBe(true);
      expect(track.trigger.calledWith('status:changed', track)).toBe(true);
      // ensure the ordering
      expect(track.trigger.getCall(0).args[0]).toBe('status:changing');
      expect(track.trigger.getCall(1).args[0]).toBe('status:changed');
    });
  });

  describe(".updateStatus(status)", function() {
    beforeEach(function() {
      sinon.stub(track, 'trigger');
    });
    it("should set the status to the passed status", function() {
      expect(track.status).toBe('stopped');
      track.updateStatus('playing');
      expect(track.status).toBe('playing');
    });
    it("should fire a status:changed event", function() {
      track.updateStatus('playing');
      expect(track.trigger.callCount).toBe(1);
      expect(track.trigger.calledWith('status:changed', track)).toBe(true);
    });
  });
});
