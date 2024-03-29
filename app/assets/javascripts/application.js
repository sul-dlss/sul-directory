// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require rails-ujs
//= require 'jquery.dataTables.min'
//= require 'jquery.dataTables.columnFilter'
//= require_tree .

$(function(){
     $('#staffdir').dataTable(
         { "aoColumns": [ null, { "bSortable": false }, { "bSortable": false }, { "bSortable": false }, { "bSortable": false } ],
           "oLanguage": { "sSearch" : "Search this list" },
           "oSearch": {"bSmart": false},
            "bStateSave": true,
           "iDisplayLength": 25,
           "pagingType" : "simple"
         })
        .columnFilter({
                  sPlaceHolder: "head:before",
                  aoColumns: [ null,
                              { type: "select", "bSmart": false, "bRegex": false },
                              null,
                              null,
                              null,
                             ]
      });
});
