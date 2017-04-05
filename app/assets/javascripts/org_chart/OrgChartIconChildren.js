(function($, undefined) {
  function OrgChartIconChildren() {
  };

  window.OrgChartIconChildren = OrgChartIconChildren;

  var proto = OrgChartIconChildren.prototype;

  proto.onUpdateNode = function(id, event) {
    var dropNode = $('#'+id+'.node');
    var draggedNode = $('#'+event.draggedNode[0].id+'.node');
    return this.updateIconChildren(dropNode, draggedNode);
  };

  proto.setIconChildren = function(node, val) {
    if (val) {
      if ($('.title .fa-users', node).length == 0) {
        $('.title', node).append($('<i class="fa fa-users symbol"></i>'));
      }
    } else {
      $('.title .fa-users', node).remove();
    }
  };

  proto.getChildrenForParentId = function(id) {
    return $('[data-parent]').filter(function(idx, elem) { return ($(elem).data('parent')==id);});
  };

  proto.getNodeNumChildren = function (id) {
    return this.getChildrenForParentId(id).length;
  };

  proto.updateIconChildren = function (dropNode, draggedNode) {
    var previousParent = $('#'+draggedNode.data('parent')+'.node');
    draggedNode.data('parent', dropNode.attr('id'));
    this.setIconChildren(dropNode, true);
    this.setIconChildren(previousParent, (this.getNodeNumChildren(previousParent.attr('id'))>0));
  };

}(jQuery));

