(function($,undefined) {
  function OrgTree() {
    MODULES.forEach($.proxy(function(module) {
      module.apply(this, arguments);
    }, this));
    this.attachHandlers();
  }

  window.OrgTree = OrgTree;

  var MODULES = [
    OrgChartTree
  ];

  OrgTree.prototype = $.extend.call(this, OrgTree.prototype, OrgChartTree.prototype);

  var proto = OrgTree.prototype;

  proto.alert = function(msg) {
    $('.alert.alert-danger').remove();
    $('#tree-hierarchy').prepend('<div class="alert alert-danger">'+msg+'</div>');
  }

  proto.info = function(msg) {
    $('.alert.alert-info').remove();
    $('#tree-hierarchy').prepend('<div class="alert alert-info">'+msg+'</div>');
  }  

  proto.attachHandlers = function() {
    this.loadTree();
    this.attachMenuHandlers();

    // Reset the modal to a loading icon after it's been closed
    $('#editNodeModal').on('hidden.bs.modal', function (e) {
      $('div.modal-header', this).html('');
      $('div.modal-body', this)
        .html('<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i>')
        .addClass('text-center')
    })
  };

}(jQuery))