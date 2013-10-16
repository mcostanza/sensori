Sensori.Views.Discussions = Backbone.View.extend({

  initialize: function() {
    this.collection = (this.collection || new Sensori.Collections.Discussions()); 
    this.bootstrap();
  },

  bootstrap: function() {
    // Setup views for the discussion previews (rendered server side on page load)
    this.collection.each(function(discussion) {
      new Sensori.Views.DiscussionPreview({ model: discussion, el: this.$("[data-discussion-id='" + discussion.id + "']") });
    }, this);
  }
  /*
  initialize: function() {
    _.bindAll(this, "refresh", "updatePageInfo", "render");
    this.currentPage = this.options.currentPage;
    this.totalPages = this.options.totalPages;
    this.category = this.options.category;
    this.discussionsWrapper = this.$(".discussions-wrapper");
    this.categoryControls = this.$(".categories");
    this.paginationControls = this.$(".pagination");
  },

  events: {
    //"click ul.categories li" : "setCategory"
    //"click .pagination li" : "setPage"
  },

  setCategory: function(e) {
    e.preventDefault();
    $(e.target).blur();
    this.categoryControls.find('li').removeClass('active');
    var listItem = $(e.target).closest('li');
    listItem.addClass('active');
    this.category = listItem.data('category');
    this.refresh();
  },

  setPage: function(e) {
    e.preventDefault();
    $(e.target).blur();
    this.paginationControls.find('li').removeClass('active');
    var listItem = $(e.target).closest('li');
    listItem.addClass('active');
    this.currentPage = parseInt(listItem.data('page'), 10);
    this.refresh();
  },

  refresh: function() {
    var queryParams = {};
    if(this.currentPage) { queryParams.page = this.currentPage; }
    if(this.category) { queryParams.category = this.category; }
    if(_.isEmpty(queryParams)) {
      Sensori.pushState(this.collection.url);
    } else {
      Sensori.pushState(this.collection.url + "?" + $.param(queryParams));
    }
    this.collection.fetch({ data: queryParams, success: this.updatePageInfo });
  },

  updatePageInfo: function(collection, response, options) {
    this.currentPage = response.current_page;
    this.totalPages = response.total_pages;
    this.render();
  },

  render: function() {
    this.discussionsWrapper.hide()
    this.discussionsWrapper.empty();
      

    this.collection.each(function(discussion) {
      this.discussionsWrapper.append(new Sensori.Views.DiscussionPreview({ model: discussion }).render().el)
    }, this);
    $("abbr.timeago").timeago();
    this.discussionsWrapper.fadeIn();

    return this;
  }
  */
});
