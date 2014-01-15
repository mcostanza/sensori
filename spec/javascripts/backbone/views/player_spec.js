describe("Sensori.Views.Player", function() {
  var view,
      el,
      collection,
      track,
      pageTitle,
      audioView,
      clickEvent;

  beforeEach(function() {
    collection = new Sensori.Collections.Tracks([{ id: 13 }, { id: 14 }]);
    el = $("<div>").append([
      "<div class='thumbnail' data-track-id='13'>",
      "<div class='thumbnail' data-track-id='14'>"
      ].join(""));
    view = new Sensori.Views.Player({
      collection: collection,
      el: el
    });
  });

  describe("events", function() {
    it("should fire the setupAndPlayAudio callback when an audio data type element is clicked", function() {
      expect(view.events["click [data-type=audio]"]).toEqual("setupAndPlayAudio");
    });
  });

  describe(".initialize()", function() {
    beforeEach(function() {
      sinon.stub(Sensori.Views, 'Track');
      sinon.stub(_, 'bindAll');
      sinon.stub(Sensori.Views.Player.prototype, 'onTrackStatusChanging');
      sinon.stub(Sensori.Views.Player.prototype, 'onTrackStatusChanged');
      sinon.stub(Sensori.Views.Player.prototype, 'onTrackFinished');
    });
    afterEach(function() {
      Sensori.Views.Track.restore();
      _.bindAll.restore();
      Sensori.Views.Player.prototype.onTrackStatusChanging.restore();
      Sensori.Views.Player.prototype.onTrackStatusChanged.restore();
      Sensori.Views.Player.prototype.onTrackFinished.restore();
    });
    it("should setup tracks if the view is initialized with a collection", function() {
      view = new Sensori.Views.Player({
        collection: collection,
        el: el
      });
      expect(Sensori.Views.Track.callCount).toBe(2);
      expect(Sensori.Views.Track.calledWith({
        model: collection.models[0],
        el: el.find("[data-track-id='" + collection.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.Track.calledWith({
        model: collection.models[1],
        el: el.find("[data-track-id='" + collection.models[1].id + "']")
      })).toBe(true);
    });
    it("should not setup tracks if the view was not initialized with a collection", function() {
      view = new Sensori.Views.Player();
      expect(Sensori.Views.Track.callCount).toBe(0);
    });
    it("should setup an empty collection if one is not passed", function() {
      view = new Sensori.Views.Player({
        el: el
      });
      expect(view.collection).toBeDefined();
    });
    it("should call onTrackStatusChanging when the status:changing event is fired on the collection", function() {
      collection = new Sensori.Collections.Tracks([{ id: 13 }, { id: 14 }]);
      view = new Sensori.Views.Player({
        collection: collection,
        el: el
      });
      view.collection.trigger('status:changing')
      expect(view.onTrackStatusChanging.callCount).toBe(1);
    });
    it("should call onTrackStatusChanged when the status:changed event is fired on the collection", function() {
      collection = new Sensori.Collections.Tracks([{ id: 13 }, { id: 14 }]);
      view = new Sensori.Views.Player({
        collection: collection,
        el: el
      });
      view.collection.trigger('status:changed')
      expect(view.onTrackStatusChanged.callCount).toBe(1);
    });
    it("should call onTrackFinished when the finished event is fired on the collection", function() {
      collection = new Sensori.Collections.Tracks([{ id: 13 }, { id: 14 }]);
      view = new Sensori.Views.Player({
        collection: collection,
        el: el
      });
      view.collection.trigger('finished')
      expect(view.onTrackFinished.callCount).toBe(1);
    });
    it("should set pageTitle to the current page title", function() {
      expect(view.pageTitle).toBe(document.title);
    });
  });

  describe(".bootstrap()", function() {
    beforeEach(function() {
      sinon.stub(Sensori.Views, 'Track');
    });
    afterEach(function() {
      Sensori.Views.Track.restore();
    });
    it("should setup track views for each of the models in the collection", function() {
      view.bootstrap();
      expect(Sensori.Views.Track.callCount).toBe(2);
      expect(Sensori.Views.Track.calledWith({
        model: collection.models[0],
        el: el.find("[data-track-id='" + collection.models[0].id + "']")
      })).toBe(true);
      expect(Sensori.Views.Track.calledWith({
        model: collection.models[1],
        el: el.find("[data-track-id='" + collection.models[1].id + "']")
      })).toBe(true);
    });
  });

  describe(".onTrackStatusChanging(track, newStatus)", function() {
    it("should stop the current track if it is set and the new status is 'playing'", function() {
      view.currentTrack = { stop: sinon.stub() };
      view.onTrackStatusChanging('track', 'playing');
      expect(view.currentTrack.stop.callCount).toBe(1);
    });
    it("should not stop the current track if the event is triggered on the current track (resuming from a pause)", function() {
      view.currentTrack = { stop: sinon.stub() };
      view.onTrackStatusChanging(view.currentTrack, 'playing');
      expect(view.currentTrack.stop.callCount).toBe(0);
    });
    it("should do nothing if the status is not 'playing'", function() {
      view.currentTrack = { stop: sinon.stub() };
      view.onTrackStatusChanging('track', 'stopped');
      expect(view.currentTrack.stop.callCount).toBe(0);
    });
    it("should not fail if the current track is not set", function() {
      view.currentTrack = undefined;
      view.onTrackStatusChanging('track', 'playing');
    });
  });

  describe(".onTrackStatusChanged(track)", function() {
    beforeEach(function() {
      pageTitle = document.title;
    });
    afterEach(function() {
      document.title = pageTitle;
    });
    it("should update the currentTrack if the status is playing", function() {
      expect(view.currentTrack).toBeUndefined();
      track = new Sensori.Models.Track({ member: { name: 'Five05' }, title: 'Vaca' });
      track.status = 'playing';
      view.onTrackStatusChanged(track);
      expect(view.currentTrack).toBe(track);
    });
    it("should set the page title to the currentTrack's title if it is playing", function() {
      expect(view.currentTrack).toBeUndefined();
      track = new Sensori.Models.Track({ member: { name: 'Five05' }, title: 'Vaca' });
      sinon.stub(track, 'title').returns('title');
      track.status = 'playing';
      view.onTrackStatusChanged(track);
      expect(document.title).toBe("► title");
    });
    it("should reset the page title if the status is not playing", function() {
      expect(view.currentTrack).toBeUndefined();
      track = new Sensori.Models.Track({ member: { name: 'Five05' }, title: 'Vaca' });
      track.status = 'playing';
      view.onTrackStatusChanged(track);
      expect(document.title).toBe("► " + track.title());
      track.status = 'stopped';
      view.onTrackStatusChanged(track);
      expect(document.title).toBe(pageTitle);
    });
  });

  describe(".onTrackFinished(track)", function() {
    beforeEach(function() {
      firstTrack = view.collection.first();
      sinon.stub(firstTrack, 'stop');
      sinon.stub(firstTrack, 'play');
      lastTrack = view.collection.last();
      sinon.stub(lastTrack, 'stop');
      sinon.stub(lastTrack, 'play');
    });
    it("should play the next track", function() {
      view.onTrackFinished(firstTrack);
      expect(lastTrack.play.callCount).toBe(1);
    });
    it("should not play the next track if the finished track is the last", function() {
      view.onTrackFinished(lastTrack);
      expect(firstTrack.play.callCount).toBe(0);
    });
  });
  describe("setupAndPlayAudio(e)", function() {
    beforeEach(function() {
      sinon.stub(soundManager, 'createSound');
      el = $("<a data-type='audio' href='http://stream.com/sound.wav'>Drums 88bpm</a>");
      audioView = new Sensori.Views.Audio({ el: el });
      sinon.stub(audioView.model, 'play');
      el.removeData('audio-id');
      sinon.stub(Sensori.Views, 'Audio').returns(audioView);
      clickEvent = { target: el, preventDefault: sinon.stub() }
    });
    afterEach(function() {
      soundManager.createSound.restore();
      Sensori.Views.Audio.restore();
    });
    it("should return if the element already has an audio-id (has already been setup)", function() {
      clickEvent.target.data('audio-id', '414');
      view.setupAndPlayAudio(clickEvent);
      expect(Sensori.Views.Audio.callCount).toBe(0);
    });
    it("should prevent the default click behavior", function() {
      view.setupAndPlayAudio(clickEvent);
      expect(clickEvent.preventDefault.callCount).toBe(1);
    });
    it("should setup an audio with with the target element", function() {
      view.setupAndPlayAudio(clickEvent);
      expect(Sensori.Views.Audio.callCount).toBe(1);
      expect(Sensori.Views.Audio.calledWith({ el: clickEvent.target })).toBe(true);
    });
    it("should fire the onTrackStatusChanging event when the view's model triggers a status:changing event", function() {
      sinon.stub(view, 'onTrackStatusChanging');
      view.setupAndPlayAudio(clickEvent);
      expect(view.onTrackStatusChanging.callCount).toBe(0);
      audioView.model.trigger("status:changing", audioView.model, 'playing');
      expect(view.onTrackStatusChanging.callCount).toBe(1);
    });
    it("should fire the onTrackStatusChanged event wwhen the view's model triggers a status:changed event", function() {
      sinon.stub(view, 'onTrackStatusChanged');
      view.setupAndPlayAudio(clickEvent);
      expect(view.onTrackStatusChanged.callCount).toBe(0);
      audioView.model.trigger("status:changed", audioView.model);
      expect(view.onTrackStatusChanged.callCount).toBe(1);
    });
    it("should not listen for finished events", function() {
      sinon.stub(view, 'onTrackFinished');
      view.setupAndPlayAudio(clickEvent);
      expect(view.onTrackFinished.callCount).toBe(0);
      audioView.model.trigger("finished", audioView.model);
      expect(view.onTrackFinished.callCount).toBe(0);
    });
    it("should play the audio", function() {
      view.setupAndPlayAudio(clickEvent);
      expect(audioView.model.play.callCount).toBe(1);
    });
  });
});
