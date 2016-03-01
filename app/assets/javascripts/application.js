//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery.purr
//= require json2
//= require history
//= require history.adapter.jquery
//= require jquery.ba-bbq
//= require jquery.url
//= require twitter/bootstrap
// require loading_notice
//= require ajax_pagination
//= require maskedinput
//= require mascara
//= require autocomplete-rails
// require loading_notice
//= require ie10-viewport-bug-workaround
//= require ie-emulation-modes-warning
//= require autocomplete-rails

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


jQuery(function() {
    // Executes a callback detecting changes
    jQuery("#lotacao_tipo_lotacao_regular").change(function(){
    jQuery.ajax({data:'tp_lotacao=' + this.value, success:function(request){jQuery('#destino').html(request);}, url:"/lotacoes/lotacao_especial"
  })});});

jQuery(function() {
    // Executes a callback detecting changes
    jQuery("#lotacao_tipo_lotacao_especial").change(function(){
    jQuery.ajax({data:'tp_lotacao=' + this.value, success:function(request){jQuery('#destino').html(request);}, url:"/lotacoes/lotacao_especial"
  })});});

jQuery(document).ready(function() {
    $('a[href="' + this.location.pathname + '"]').addClass('active');
});

