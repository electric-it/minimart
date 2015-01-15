// jQuery Listeners
$(function () {
  $('#cookbook-search-form').submit(function (ev) {
    ev.preventDefault();
    var searchValue = $(this).find('input[name="query"]').val();
    document.location.href = '/#/search/' + encodeURI(searchValue);
  });
});

// simple app for managing pagination & search of cookbooks.
var MinimartApp = {
  start: function () {
    new MinimartApp.Router();
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

  template: function () {
    if (!this.cachedTemplate) {
      this.cachedTemplate = _.template($('#cookbook-list-template').html());
    }
    return this.cachedTemplate;
  },

  render: function () {
    this.$el.html(this.template()({
      total_cookbooks: this.collection.size(),
      cookbooks: this.collection.toJSON()
    }));
  },
});

MinimartApp.Router = Backbone.Router.extend({
  routes: {
    "": 'index',
    "search/:query": 'search'
  },

  index: function () {
    var self = this;
    self.withCollection({}, function () {
      new MinimartApp.CookbookListView({ collection: self.collection }).render();
    });
  },

  search: function (query) {
    var self = this;
    self.withCollection({}, function () {
      collection = self.collection.filter(function (cookbook) {
        return cookbook.get('name').match(query);
      });
      new MinimartApp.CookbookListView({ collection: new MinimartApp.CookbookList(collection) }).render();
    });
  },

  withCollection: function (opts, callback) {
    if (!this.collection) {
      this.collection = new MinimartApp.CookbookList();
      this.collection.fetch({ url: '/data.json', success: callback });
    } else {
      callback();
    }
  }
});
