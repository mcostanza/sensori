(function($) {

	// Usage:
	//
	//   $(".selector").notice({ text: "Congratulations....you've won!" })
	//
	$.fn.notice = function(options) {
		options = _.extend({
			type: "success",
			fadeOut: true,
			fadeOutDelay: 5000
		}, options);

		var noticeType = {
			"warning": "alert",
			"success": "alert alert-success",
			"error":   "alert alert-error"
		}[options.type];

		var notice = $("<div>")
			.addClass("notice")
			.addClass(noticeType)
			.text(options.text)
			.append("<button type=\"button\" class=\"close\" data-dismiss=\"alert\">&times;</button>")
			.hide();

		$(this).append(notice);

		notice.fadeIn();

		if (options.fadeOut) {
			setTimeout(function() {
				notice.fadeOut("fast", function() { notice.remove() });
			}, options.fadeOutDelay);
		}

	};

})(jQuery);