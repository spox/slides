require(['order!../slide_config', 'order!modernizr.custom.45394',
         'order!prettify/prettify', 'order!hammer', 'order!slide-controller',
         'order!slide-deck'], function(someModule) {

});

// autoscroll helpers
$('document').ready(function(){
  $('slide pre.auto-scroll').each(function(){
    slide = $(this).parents('slide');
    slide.bind('slideenter', function(){
      auto_scroll = $(this).find('pre.auto-scroll');
      if(window.slidedeck){
        increment_every = window.slidedeck.config_.settings.increment_every || 20000;
      }
      if(typeof increment_every == 'undefined'){
        increment_every = 20000;
      }
      if(auto_scroll.size() > 0){
        auto_scroll.each(function(){
          a_scroll = $(this);
          setTimeout(function(){
            a_scroll.animate({scrollTop: auto_scroll.prop('scrollHeight')},
            (a_scroll.attr('data-scroll-duration') || increment_every) - 1500);
          }, 1000);
        });
      }
    });
    slide.bind('slideleave', function(){
      auto_scroll = $(this).find('pre.auto-scroll');
      setTimeout(function(){ auto_scroll.scrollTop(0); }, 600);
    });
  });
});

// autoincrement helpers
$('document').ready(function(){
  window.auto_incrementers = {};
  $('slide').bind('slideenter', function(evt){
    if(window.slidedeck && window.slidedeck.config_.settings.incrementEvery){
      slide_number = evt.originalEvent.slideNumber
      inc_val = window.slidedeck.config_.settings.incrementEvery * 1000;
      if(window.auto_incrementer){
        console.log('Skipping increment. One already running.');
      } else {
        if(slide_number == window.slidedeck.slides.length){
          if(window.slidedeck.config_.settings.incrementLoop){
            setTimeout(function(){
              window.slidedeck.curSlide_ = 0;
              window.auto_incrementer = false;
              window.slidedeck.nextSlide();
            }, inc_val);
          }
        } else {
          setTimeout(function(){
            window.auto_incrementer = false;
            window.slidedeck.nextSlide();
          }, inc_val);
        }
        window.auto_incrementer = true;
      }
    }
  });
});

// video display helpers
$('document').ready(function(){
  $('slide video').each(function(){
    video = $(this);
    video.bind('ended', function(){
      video = $(this);
      vid = video[0];
      if(video.hasClass('autoplay')){
        vid.pause();
        vid.currentTime = 0;
      }
      if(video.hasClass('expand')){
        video.removeClass('filled');
      }
    });
    slide = video.parents('slide');
    slide.bind('slideenter', function(){
      video = $(this).find('video');
      vid = video[0];
      if(video.hasClass('expand')){
        video.addClass('filled');
      }
      if(video.attr('data-speed')){
        vid.playbackRate = video.attr('data-speed');
      }
      if(video.hasClass('autoplay')){
        vid.play();
      }
    });
    slide.bind('slideleave', function(){
      video = $(this).find('video');
      if(video.hasClass('autoplay')){
        vid = video[0];
        vid.pause();
      }
      if(video.hasClass('expand')){
        setTimeout(10, function(){
          video.removeClass('filled');
        });
      }
    });
  });
});

// build display helpers
$('document').ready(function(){
  $('img.build-hide').each(function(){
    img = $(this);
    img.hide();
    slide = img.parents('slide');
    slide.bind('slidebuild', function(){
      shower = $(this).find('.build-show');
      if(shower.hasClass('build-current')){
        img = $(this).find('img');
        img.fadeIn(3000);
      }
    });
  });
});