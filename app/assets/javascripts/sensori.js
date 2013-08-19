window.Sensori = {
  Models: {},
  Views: {},
  Collections: {},
  pushState: function(path, data) {
  	try {
  		window.history.pushState(data, "Sensori Collective", path);
  	} catch(ex) {
  		this.redirect(url);
  	}
  },
  redirect: function(url) {
    window.location.href = url;
  }
};

$(function() {
  Sensori.authenticityToken = $('meta[name="csrf-token"]').attr('content');
});
