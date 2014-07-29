$(document).ready(function(){

  // More/Less Description
  $("[id^='item_']").delegate('.more','click',function(){
    $(this).toggle();
    parent = $(this).closest('.item');
    $(parent).find('.less').toggle();
    $(parent).find('.item_desc').toggle();
  });

  $("[id^='item_']").delegate('.less','click',function(){
    $(this).toggle();
    parent = $(this).closest('.item');
    $(parent).find('.more').toggle();
    $(parent).find('.item_desc').toggle();
  });

  // Spinner's for like buttons
  $('.like_it').delegate('a','click',function() {
    $(this).replaceWith('<i class="fa fa-spinner fa-spin"></i>');
  });

});