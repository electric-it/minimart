var HeroParallax = function() {
  this.init();
};

HeroParallax.prototype = {
  init: function() {
    var _this = this;

    this.els = {};
    this.els.$stars = $('.home-hero__stars');
    this.els.$moon = $('.home-hero__moon');
    this.els.$buildings = $('.home-hero__buildings-bg');
    this.els.$sky = this.els.$stars.add(this.els.$moon);

    $(window).scroll(bind(this.onWindowScroll, this));

    (function run() {
      requestAnimationFrame(run);
      _this.animate.call(_this);
    })();
  },

  animate: function() {
    if((typeof this.scrollTop !== 'undefined' && typeof this.prevScrollTop === 'undefined')
    || (typeof this.scrollTop !== 'undefined' && this.scrollTop !== this.prevScrollTop)) {
      this.els.$sky.css('transform', 'translate3d(0px, ' + (0 + (this.scrollTop / 2)) + 'px, 0px)');
      this.els.$buildings.css('transform', 'translate3d(0px, ' + (0 + (this.scrollTop / 5)) + 'px, 0px)');
      this.prevScrollTop = this.scrollTop;
    }
  },

  onWindowScroll: function() {
    this.scrollTop = $(window).scrollTop();
  }
};
