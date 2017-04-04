(function($, undefined) {
  function OrgChartMenuNodeDelete() {};


  window.OrgChartMenuNodeDelete = OrgChartMenuNodeDelete;

  var proto = OrgChartMenuNodeDelete.prototype;

  proto.onDeleteNode = function (response) {
    $('#chart-container').orgchart('removeNodes', $node);
    $('#selected-node').data('node', null);
  };

  proto.onErrorDeleteNode = function() {
    this.alert('Failed to delete the node');
  };

  proto.deleteNode = function(id) {
    return this.keepTreeUpdate().then($.proxy(function() {
      return $.ajax({
         headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/'+id,
        type : 'DELETE'
      }).fail($.proxy(this.onErrorConnection, this));
    }, this));
  };
  
}(jQuery));
