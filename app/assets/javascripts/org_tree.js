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
    $('#tree-hierarchy').prepend('<div class="alert alert-danger">'+msg+'</div>');
  }

  proto.attachHandlers = function() {
    this.loadTree();
    this.attachMenuHandlers();
  };

}(jQuery))