describe("Sensori.Models.Track", function() {
  var track,
      mockSound;

  beforeEach(function() {
    sinon.stub(SC, 'stream');
    track = new Sensori.Models.Track({ stream_url: 'http://stream.com', member: { name: 'Five05' }, title: 'Know What I Mean' });
  });
  afterEach(function() {
    SC.stream.restore();
  });

  it("should extend Sensori.Models.Audio", function() {
    track = new Sensori.Models.Track();
    expect(track instanceof Sensori.Models.Audio).toBe(true);
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

  describe(".title()", function() {
    it("should return 'name - title' using the member's name and the track's title", function() {
      expect(track.title()).toBe("Five05 - Know What I Mean");
    });
  });
});
