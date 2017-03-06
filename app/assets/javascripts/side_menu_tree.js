(function($,undefined) {
  function SideMenuTree() {
    this.attachHandlers();
  }

  var proto = SideMenuTree.prototype;

  proto.attachHandlers = function() {
    $(document).on('ready', $.proxy(this.loadSidebar, this));
    $(document).on('turbolinks:load', $.proxy(this.loadTree, this));
  };

  proto.loadSidebar = function() {
    $.get('/api/v1/nodes?include=nodes.parent', function(response) {

      $('#side_menu_tree').treeview({
        data: TreeBuilder.createFrom(response.data, false, window.currentNodeId),
        enableLinks: true,
        collapseIcon: 'fa fa-minus',
        expandIcon: 'fa fa-plus',
        emptyIcon: 'fa',
        levels: 1
      });
    });

    $('#project-search').on('keyup', debounce(function(e) {
      var value = $(this).val();

      if (value) {
        $('#side_menu_tree').treeview('search', [ value, {
          ignoreCase: true,
          exactMatch: false,
          revealResults: true,
        }]);
      } else {
        $('#side_menu_tree').treeview('clearSearch');
      }
    }, 300));
  }

  proto.loadTree = function() {
    var self = this;

    $.get('/api/v1/nodes?include=nodes.parent', function(response) {
      //response.data = [response.data];
      var programs = TreeBuilder.parentNodes(response.data);
      var program_node_ids = programs[0].relationships.nodes.data.map(function(a) {return (a.id);});

      $('#tree-hierarchy').orgchart({
        'data' : TreeBuilder.createFrom(response.data, true)[0],
        'depth': response.data.length,
        'nodeContent': 'href',
        'nodeID': 'id',
        //'direction': 'l2r',
        'draggable' : true,
        'pan': true,
        //'zoom': true

        'dropCriteria': function($draggedNode, $dragZone, $dropZone) {
          var dropNodeID = $dropZone.children('.content').text().split("/")[2];
          var draggedNodeID = $draggedNode.children('.content').text().split("/")[2];

          // adds drag and drop restrictions
          // indexOf returns -1 if the node is not a 'program'
          // dropNodeID == 1 is the root node
          if (program_node_ids.indexOf(draggedNodeID) > -1 || dropNodeID == 1) {
            return false;
          }
          return true;
        }})
        .children('.orgchart').on('nodedropped.orgchart', function(event) {
        $.get('/api/v1/nodes/'+event.dropZone.children('.content').text().split("/")[2], function(response) {
          updateNode(response.data.id);
        });

        function updateNode(id) {
          $.ajax({
            headers : {
                'Accept' : 'application/vnd.api+json',
                'Content-Type' : 'application/vnd.api+json'
            },
            url : '/api/v1/nodes/'+event.draggedNode.children('.content').text().split("/")[2]+'/relationships/parent',
            type : 'PATCH',
            data : JSON.stringify({ data: { type: 'nodes', id: id }}),
            success : function(response, textStatus, jqXhr) {
                console.log("Successfully updated");
            },
            error : function(jqXHR, textStatus, errorThrown) {
                console.log("Error: " + textStatus, errorThrown);
            },
            complete : function() {
              // Reload that sidebar
              self.loadSidebar();
            }
          })
        }
      });

    });

  };

  window.SideMenuTree = SideMenuTree;

}(jQuery))