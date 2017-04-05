(function($, undefined) {
  function OrgChartMenuNodeDelete() {};


  window.OrgChartMenuNodeDelete = OrgChartMenuNodeDelete;

  var proto = OrgChartMenuNodeDelete.prototype;

  proto.onDeleteNodes = function() {
    return this.deleteNode(this.selectedNode().attr('id'));
  };

  proto.onDeleteNode = function () {
    $('#chart-container').orgchart('removeNodes', this.selectedNode());
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
        url : '/api/v1/nodes/'+id,
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
