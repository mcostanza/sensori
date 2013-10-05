_.mixin({
  truncate: function(text, length) {
    if(text.length > length) {
      text = text.slice(0, length - 3) + "...";
    }
    return text;
  }
});

