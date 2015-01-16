// jQuery Listeners
$(function () {
  $('#cookbook-search-form').submit(function (ev) {
    ev.preventDefault();
    var searchValue, searchPath;
    searchValue = $(this).find('input[name="query"]').val();
    searchPath  = $(this).attr('action');
    document.location.href = encodeURI(searchPath + searchValue);
  });
});

// simple app for managing pagination & search of cookbooks.
var MinimartApp = {
  start: function (opts) {
    new MinimartApp.Router(opts);
    Backbone.history.start();
  }
};

MinimartApp.Cookbook = Backbone.Model.extend({});

MinimartApp.CookbookList = Backbone.Collection.extend({ model: MinimartApp.Cookbook });

MinimartApp.CookbookListView = Backbone.View.extend({
  el: '#cookbooks',

  events: {
    "click #next-page-button": 'nextPage',
    "click #previous-page-button": 'previousPage'
  },

  initialize: function (opts) {
    this.query = opts.query;
  },

  template: function () {
    if (!this.cachedTemplate) {
      this.cachedTemplate = _.template($('#cookbook-list-template').html());
    }
    return this.cachedTemplate;
  },

  render: function () {
    this.$el.html(this.template()({
      query:            this.query,
      total_cookbooks:  this.collection.size(),
      cookbooks:        this.collection.toJSON()
    }));
  },
});

MinimartApp.Router = Backbone.Router.extend({
  routes: {
    "": 'index',
    "search/:query": 'search'
  },

  initialize: function (opts) {
    this.collection = new MinimartApp.CookbookList(opts.collection);
  },

  index: function () {
    new MinimartApp.CookbookListView({ collection: this.collection }).render();
  },

  search: function (query) {
    var filtered = this.collection.filter(function (c) {
      return c.get('name').match(query);
    });

    new MinimartApp.CookbookListView({
      query: query,
      collection: new MinimartApp.CookbookList(filtered)
    }).render();
  }
});
