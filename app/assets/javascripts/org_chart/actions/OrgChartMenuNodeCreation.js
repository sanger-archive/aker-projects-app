(function($, undefined) {
  function OrgChartMenuNodeCreation() {};

  window.OrgChartMenuNodeCreation = OrgChartMenuNodeCreation;

  var proto = OrgChartMenuNodeCreation.prototype;

  proto.onAddNodes = function() {
    // Get the values of the new nodes and add them to the nodeVals array
    var newNodeName = $('#new-node').val().trim();

    // Get the data of the currently selected node
    var $node = this.selectedNode();

    if (newNodeName.length == 0 || !$node) {
      return;
    }
    this.createNode(newNodeName, $node[0].id);
    $('#new-node').val('');
  };

  proto.onErrorCreateNode = function(error) {
    error.responseJSON.errors.forEach($.proxy(function(error) {
      this.alert(error.detail);
    }, this));
  };

  proto.onCreateNode = function(response) { };

  proto.createNode = function(newName, parentId) {
    return $.ajax({
        headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : Routes.api_v1_nodes_path(),
        type : 'POST',
        data : JSON.stringify({
          data: {
            type: 'nodes',
            attributes: {
              name: newName
            },
            relationships: {
              parent: {
                data: {
                  type: 'nodes',
                  id: parentId
                }
              }
            }
          }
        })
    }).then(
      $.proxy(this.onCreateNode, this),
      $.proxy(this.onErrorCreateNode, this)
    );
  };

}(jQuery));
