(function($, undefined) {
  function OrgChartTree() {
    MODULES.forEach($.proxy(function(module) {
      module.apply(this, arguments);
    }, this));
  };

  window.OrgChartTree = OrgChartTree;

  var MODULES = [
    OrgChartMenu,
    OrgChartStatus,
    OrgChartIconChildren
  ];

  OrgChartTree.prototype = $.extend.apply(this, $.map(MODULES, function(mod) { return mod.prototype; }));

  var proto = OrgChartTree.prototype;

  proto.loadTree = function() {
    var defer = $.Deferred();
    var self = this;
    return $.get('/api/v1/nodes?include=nodes.parent', $.proxy(function(response) {
      $('#tree-hierarchy').html('');
      var programs = TreeBuilder.parentNodes(response.data);
      $('#tree-hierarchy').orgchart({
        'data' : TreeBuilder.createFrom(response.data, true)[0],
        'depth': response.data.length,
        'nodeContent': 'cost_code',
        'nodeID': 'id',
        'draggable' : true,
        'pan': false,
        // Callback function called every time a node is created
        createNode: $.proxy(this.createTreeNode, this),
        dropCriteria: $.proxy(this.onBeforeDrop, this)
      })
      // Deselect selected node
      .on('click', '.orgchart', $.proxy(this.onClickOnTree, this))
      .children('.orgchart')
      .on('nodedropped.orgchart', $.proxy(this.onDrop, this));
      defer.resolve(true);
    }, this));
    return defer;
  };

  proto.onBeforeDrop = function($draggedNode, $dragZone, $dropZone) {
    var dropNodeID = $dropZone.children('.content').text().split("/")[2];
    var draggedNodeID = $draggedNode.children('.content').text().split("/")[2];

    // adds drag and drop restrictions
    // ID 1 is the root node
    return (dropNodeID != 1);
  };

  proto.onDrop = function(event) {
    $.get('/api/v1/nodes/'+event.dropZone[0].id, $.proxy(function(response) {
      this.updateNode(response.data.id, event);
    }, this)).fail($.proxy(this.onErrorConnection, this));
  };

  proto.onClickOnTree = function(event) {
    if (!$(event.target).closest('.node').length) {
      this.resetStatusMenu();
    }
  };

  proto.selectedNode = function() {
    return $('#selected-node').data('node');
  };

  proto.selectNode = function(node) {
    $('#selected-node').val(node.attr('title')).data('node', node);
  };

  proto.unselectNode = function() {
    $('#selected-node').data('node', null);
    $('#selected-node').val('');
  };

  proto.createTreeNode = function($node, data) {
    this.unselectNode();
    this.resetStatusMenu();
    $node.attr('title', data.name);
    $node.attr('id', data.id);
    $node.on('click', $.proxy(function(event) {
      if (!$(event.target).is('.edge')) {
        this.selectNode($node);
        //$('#edit-panel').css('visibility', 'visible');
        $('#edit-panel button').prop('disabled', false);
        $('#edit-panel input').prop('disabled', false);
        $('#btn-delete-nodes').prop('disabled', this.hasChildren($node));
      }
    }, this));

    $node.on('dblclick', $.proxy(this.onUpdateNodes, this, $node));
    return($node);
  };

  // Determine whether parent has any children (based on its colspan???)
  proto.hasChildren = function (node) {
    return node.parent().attr('colspan') > 0 ? true : false;
  };

}(jQuery));