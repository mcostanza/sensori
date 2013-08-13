Sensori.Models.Tutorial = Backbone.Model.extend({

  urlRoot: "/tutorials",

  publish: function(options) {
  	this.set("published", true);
  	return $.ajax({
  		url: this.url(),
  		type: "PUT",
  		dataType: "json",
  		data: { 
  			tutorial: { 
  				published: true 
  			} 
  		},
  		success: options.success,
  		error: options.error
  	});
  }

});