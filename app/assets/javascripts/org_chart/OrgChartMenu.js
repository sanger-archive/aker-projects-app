(function($, undefined) {
  
  function OrgChartMenu() {
    this.resetStatusMenu();
  };

  window.OrgChartMenu = OrgChartMenu;

  var MODULES = [
    OrgChartMenuNodeCreation, 
    OrgChartMenuNodeDelete, 
    OrgChartMenuNodeUpdate
  ];

  OrgChartMenu.prototype = $.extend.apply(this, $.map(MODULES, function(mod) { return mod.prototype; }));

  var proto = OrgChartMenu.prototype;

  proto.resetStatusMenu = function() {
    $('#edit-panel button').prop('disabled', true);
    $('#edit-panel input').prop('disabled', true);
    $('#edit-panel input').val('')
    this.unselectNode();
  };


  proto.attachMenuHandlers = function() {
    $('#btn-add-nodes').on('click', $.proxy(this.onAddNodes, this));
    // Delete Button
    $('#btn-delete-nodes').on('click', $.proxy(this.onDeleteNodes, this));
    // Reset Button
    $('#btn-reset').on('click', $.proxy(this.onResetNodes, this));
  };
  
  proto.onResetNodes = function() {
    this.unselectNode();
    $('#new-node').val('');
  };
  
}(jQuery));