// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function get_amazon_data(friend_id){
 new Ajax.Request("/get_amazon_data/"+ friend_id, {
      method: 'get',      
      onComplete:  function(response){
          jQuery.unblockUI();
      }
});

}