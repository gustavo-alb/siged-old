(function(jQuery){
    jQuery.fn.jExpand = function(){
        var element = this;

        jQuery(element).find("tr:odd").addClass("odd");
        jQuery(element).find("tr:not(.odd)").hide();
        jQuery(element).find("tr:first-child").show();

        jQuery(element).find("tr.odd").click(function() {
            jQuery(this).next("tr").toggle();
        });
        
    }    
})(jQuery); 