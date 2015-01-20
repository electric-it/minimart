
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

  events: {
    "click #paginator a": 'goToPage',
    "submit #cookbook-search-form": 'search'
  },

  initialize: function (opts) {
    this.query     = opts.query;
    this.paginator = opts.paginator;
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
      paginator:        this.paginator,
      total_cookbooks:  (_.isUndefined(this.paginator) ? this.collection.size() : this.paginator.size()),
      cookbooks:        this.collection.toJSON()
    }));

    $('#cookbooks').
      empty().
      append(this.$el);
  },

  search: function (ev) {
    ev.preventDefault();
    var query = $(ev.target).find('input[name="query"]').val();
    this.navigate('#search/' + encodeURI(query));
  },

  goToPage: function (ev) {
    var self, pageNumber;
    ev.preventDefault();
    self = this;
    pageNumber = parseInt($(ev.target).data('page'));
    $('body').animate({ scrollTop: 0 }, "fast", function () {
      self.navigate('#page/' + pageNumber);
    });
  },

  navigate: function (route) {
    this.remove();
    Backbone.history.navigate(route, {trigger: true});
  }
});

MinimartApp.Router = Backbone.Router.extend({
  routes: {
    "": 'index',
    "search/:query": 'search',
    "page/:pageNumber": 'paginated'
  },

  initialize: function (opts) {
    this.collection = opts.collection;
  },

  index: function () {
    this.buildView(0).render();
  },

  paginated: function (pageNumber) {
    this.buildView(parseInt(pageNumber)).render();
  },

  search: function (query) {
    query = decodeURI(query);

    var filtered = _.filter(this.collection, function (c) {
      return c.name.match(query);
    });

    new MinimartApp.CookbookListView({
      query: query,
      collection: new MinimartApp.CookbookList(filtered)
    }).render();
  },

  buildView: function (pageNumber) {
    var paginator, filtered;

    paginator = new MinimartApp.Paginator({ collection: this.collection, page: pageNumber });
    filtered  = new MinimartApp.CookbookList(paginator.collectionForPage());

    return new MinimartApp.CookbookListView({ collection: filtered, paginator:  paginator });
  }
});

MinimartApp.Paginator = function (opts) {
  this.pageSize    = opts.pageSize || 10;
  this.currentPage = opts.page || 0;
  this.collection  = opts.collection;
};

MinimartApp.Paginator.prototype.canShow = function () {
  return this.size() > this.pageSize;
};

MinimartApp.Paginator.prototype.collectionForPage = function () {
  var lower, upper;
  lower = this.currentPage * this.pageSize;
  upper = (lower + this.pageSize);
  return this.collection.slice(lower, upper);
};

MinimartApp.Paginator.prototype.canShowNext = function () {
  return this.isPageInRange(this.nextPage());
};

MinimartApp.Paginator.prototype.nextPage = function () {
  return this.currentPage + 1;
};

MinimartApp.Paginator.prototype.isPageInRange = function (pageNumber) {
  return (pageNumber * this.pageSize) < this.size();
};

MinimartApp.Paginator.prototype.canShowPrevious = function () {
  return this.previousPage() >= 0;
};

MinimartApp.Paginator.prototype.previousPage = function () {
  return this.currentPage - 1;
};

MinimartApp.Paginator.prototype.size = function () {
  return this.collection.length;
};

MinimartApp.Paginator.prototype.lastPage = function () {
  return Math.floor(this.collection.length / this.pageSize);
};

MinimartApp.Paginator.prototype.surroundingPages = function () {
  var startPage, endPage;
  startPage = this.currentPage - 2 > 0 ? this.currentPage - 2 : 0;
  endPage   = this.currentPage + 2 < this.lastPage() ? this.currentPage + 2 : this.lastPage();
  return _.range(startPage, endPage + 1);
};

MinimartApp.Paginator.prototype.isCurrentPage = function (page) {
  return page === this.currentPage;
};
