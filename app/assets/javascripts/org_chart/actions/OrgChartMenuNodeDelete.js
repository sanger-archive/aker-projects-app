(function($, undefined) {
  function OrgChartMenuNodeDelete() {};

  window.OrgChartMenuNodeDelete = OrgChartMenuNodeDelete;

  var proto = OrgChartMenuNodeDelete.prototype;

  proto.onDeleteNodes = function() {
    return this.deleteNode(this.selectedNode().attr('id'));
  };

  proto.onDeleteNode = function () {
    this.unselectNode();
  };

  proto.onErrorDeleteNode = function() {
    this.alert('Failed to delete the node');
  };

  proto.deleteNode = function(id) {
    return $.ajax({
         headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : Routes.api_v1_node_path(id),
        type : 'DELETE'
    }).then(
      $.proxy(this.onDeleteNode, this),
      $.proxy(this.onErrorConnection, this)
    )
  };

}(jQuery));
