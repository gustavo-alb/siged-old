//= require jquery
//= require jquery_ujs
//= require effects
//= require jquery-ui.min
//= require jquery.purr
//= require json2
//= require history
//= require history.adapter.jquery
//= require jquery.ba-bbq
//= require jquery.url
//= require twitter/bootstrap
//= require loading_notice
//= require ajax_pagination
//= require maskedinput
//= require mascara
//= require autocomplete-rails
//= require dragdrop
//= require controls
//= require facebox
//= require tabs
//= require loading_notice
//= require paginate
//= require accordion
//= require accordion_activator
//= require holder
//= require ie10-viewport-bug-workaround
//= require ie-emulation-modes-warning
//= require selectize

jQuery(function() {
    // Executes a callback detecting changes
    jQuery("#funcionario_cargo_id").change(function(){
    jQuery.ajax({data:'disciplina=' + this.value, success:function(request){jQuery('#disc').html(request);}, url:"/funcionarios/cargo"
  })});});

jQuery(function() {
    // Executes a callback detecting changes
    jQuery("#funcionario_municipio_id").change(function(){
    jQuery.ajax({data:'municipio=' + this.value, success:function(request){jQuery('#dist').html(request);}, url:"/funcionarios/distrito"
  })});});


jQuery('#lotacao_destino_id').selectize({
    delimiter: ',',
    persist: false
});