(function($, undefined) {
  function OrgChartMenuNodeDelete() {};


  window.OrgChartMenuNodeDelete = OrgChartMenuNodeDelete;

  var proto = OrgChartMenuNodeDelete.prototype;

  proto.onDeleteNodes = function() {
    return this.deleteNode(this.selectedNode().attr('id'));
  };

  proto.onDeleteNode = function () {
    // If all the parent nodes are hidden, reload the tree
    // Fixes issue of there being an empty chart after deletion
    if (this.selectedNode().closest('tr.nodes').siblings().is('.hidden')) {
      this.loadTree();
    } else {
      $('#chart-container').orgchart('removeNodes', this.selectedNode());
      this.unselectNode();
    }
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
    ).then(
      $.proxy(this.keepTreeUpdate, this),
      $.proxy(this.onErrorConnection, this)
    );
  };

}(jQuery));
