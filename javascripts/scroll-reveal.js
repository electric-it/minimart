var ScrollReveal = function() {
  this.init();
};

ScrollReveal.prototype = {
  init: function() {
    var _this = this;

    // Elements
    this.$els = $('.scroll-reveal');
    this.$els.each(function() {
      $(this).data('hidden', true);
    });

    $(window).on('scroll', bind(this.onWindowScroll, this));
    $(window).on('load', bind(this.onWindowLoad, this));
    $(window).on('resize', bind(this.onWindowResize, this));

    this.scrollTop = $(window).scrollTop();

    this.cacheOffsets();

    (function run() {
      requestAnimationFrame(run);
      _this.animate.call(_this);
    })();
  },

  animate: function() {
    var screenBottom = this.scrollTop + this.windowHeight;
    this.$els.each(function() {
      var $this = $(this);
      if($this.data('offsetTop') < screenBottom
      && $this.data('hidden') === true) {
        $this.addClass('is-visible');
      }
    });
  },

  onWindowScroll: function(e) {
    this.scrollTop = $(window).scrollTop();
  },

  onWindowLoad: function(e) {
    this.cacheOffsets();
  },

  onWindowResize: function(e) {
    this.cacheOffsets();
  },

  cacheOffsets: function(e) {
    this.windowHeight = $(window).height();
    this.$els.each(function() {
      $(this).data('offsetTop', $(this).offset().top);
    });
  }
};
