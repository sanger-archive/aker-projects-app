(function($,undefined) {
  function SideMenuTree() {
    this.attachHandlers();
  }

  var proto = SideMenuTree.prototype;

  proto.attachHandlers = function() {
    //$(document).on('ready', $.proxy(this.loadTree, this));
    $(document).on('turbolinks:load', $.proxy(this.loadTree, this));
  };

  proto.getCurrentNodeId = function() {
    var pathElems = window.location.pathname.split('/');
    return parseInt(pathElems[pathElems.length - 1], 10);
  };

  proto.loadTree = function() {
    $.get('/api/v1/nodes?include=nodes.parent', function(response) {
      //response.data = [response.data];
      var programs = TreeBuilder.parentNodes(response.data);
      var program_node_ids = programs[0].relationships.nodes.data.map(function(a) {return (a.id);});

      $('#side_menu_tree').treeview({
        data: TreeBuilder.createFrom(response.data, false),
        enableLinks: true,
        collapseIcon: 'fa fa-minus',
        expandIcon: 'fa fa-plus',
        emptyIcon: 'fa',
        levels: 1
      });

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
                'Accept' : 'application/json',
                'Content-Type' : 'application/json'
            },
            url : '/nodes/'+event.draggedNode.children('.content').text().split("/")[2],
            type : 'PATCH',
            data : JSON.stringify({ parent_id: id }),
            success : function(response, textStatus, jqXhr) {
                console.log("Successfully updated");
            },
            error : function(jqXHR, textStatus, errorThrown) {
                console.log("Error: " + textStatus, errorThrown);
            },
            complete : function() {
                console.log("Update successful");
            }
          })
        }
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

  };

  window.SideMenuTree = SideMenuTree;

}(jQuery))