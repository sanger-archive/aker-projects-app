(function($,undefined) {
  function SideMenuTree() {
    this.attachHandlers();
  }

  var proto = SideMenuTree.prototype;

  proto.attachHandlers = function() {
    var loadSidebar = $.proxy(this.loadSidebar, this)

    $(document).ready(loadSidebar);
    $('#tree-tab').on('show.bs.tab', function(e) {
      if (e.target.innerText == 'Home') loadSidebar();
    })
    $(document).ready($.proxy(this.loadTree, this));
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
      var programs = TreeBuilder.parentNodes(response.data);

      $('#tree-hierarchy').orgchart({
        'data' : TreeBuilder.createFrom(response.data, true)[0],
        'depth': response.data.length,
        'nodeContent': 'href',
        'nodeID': 'id',
        //'direction': 'l2r',
        'draggable' : true,
        'pan': true,
        //'zoom': true

        // Callback function called every time a node is created
        createNode: function($node, data) {
          $node.on('click', function(event) {
            if (!$(event.target).is('.edge')) {
              $('#selected-node').val(data.name).data('node', $node);
              $('#edit-panel').show();
              $('#btn-delete-nodes').prop('disabled', hasChildren($node));
            }
          });

          $node.on('dblclick', function(event) {
            $('#selected-node').val(data.name).data('node', $node);
            $('#editNodeModal').modal('show')
          })
        },

        dropCriteria: function($draggedNode, $dragZone, $dropZone) {
          var dropNodeID = $dropZone.children('.content').text().split("/")[2];
          var draggedNodeID = $draggedNode.children('.content').text().split("/")[2];

          // adds drag and drop restrictions
          // ID 1 is the root node
          return (dropNodeID != 1);
        }
      })

      // Deselect selected node
      .on('click', '.orgchart', function(event) {
        if (!$(event.target).closest('.node').length) {
          $('#selected-node').val('');
        }
      })

      .children('.orgchart')
      .on('nodedropped.orgchart', function(event) {
        $.get('/api/v1/nodes/'+event.dropZone[0].id, function(response) {
          updateNode(response.data.id, event);
        })
      });

      $('#btn-add-nodes').on('click', function() {
        // Get the values of the new nodes and add them to the nodeVals array
        var newNodeName = $('#new-node').val().trim();

        // Get the data of the currently selected node
        var $node = $('#selected-node').data('node');

        if (newNodeName.length == 0 || !$node) {
          return;
        }
        createNode(newNodeName, $node[0].id).then(function (response) {

          // See https://github.com/dabeng/OrgChart#structure-of-datasource
          var relationship = '';
          var id = response['data']['id'];

          if (!hasChildren($node)) {
            // Relationship will always be "has parent, no siblings, no children"
            relationship = '100'

            $('#chart-container').orgchart('addChildren', $node, {
              'children': [{ name: newNodeName, relationship: relationship, id: id }]
            });
          } else {
            // Relationship will always be "has parent, has sibling(s), no children"
            relationship = '110'

            $('#chart-container').orgchart('addSiblings', $node.closest('tr').siblings('.nodes').find('.node:first'),
              {
                'siblings': [{
                  'name': newNodeName,
                  'relationship': relationship,
                  'id': id
                }]
              }
            );
          }

        }, function(error) {
          alert('Failed to create node')
        });

      });

      // Delete Button
      $('#btn-delete-nodes').on('click', function() {
        var $node = $('#selected-node').data('node');
        deleteNode($node[0].id).then( function (response) {
          $('#chart-container').orgchart('removeNodes', $node);
          $('#selected-node').data('node', null);
        },
        function() {
          alert('Failed to delete the node');
        })
      });

      // Reset Button
      $('#btn-reset').on('click', function() {
        $('#selected-node').data('node', null).val('');
        $('#new-node').val('');
      })

    });

    $('#editNodeModal').on('show.bs.modal', function(e) {
      // We get the nodeId of the currently selected node
      var nodeId = $('#selected-node').data('node')[0].id;

      // We call jQuery's load method to fetch the html content of /nodes/:id/edit.js
      // and load it into the modal body
      $('div.modal-body', '#editNodeModal').load('/nodes/' + nodeId + '/edit.js', function(response, status, xhr) {
        $('form', 'div.modal-body')
          .on('ajax:before', function() {
            $(this).clear_form_errors();
          })
          .on('ajax:beforeSend', function(event, xhr, settings) {
            xhr.setRequestHeader('Accept', 'application/json');
          })
          .on('ajax:success', function(e, data, status, xhr) {
            // If the name has updated, we need to update the node
            $('#selected-node').data('node').find('div.title').text(data['name'])

            // Show a success message
            $('div.modal-body', '#editNodeModal').prepend('<div class="alert alert-success">Update successful</div>');

            // Setting a timeout so the user can see the update was successful just before closing
            // the modal window
            setTimeout(function() {
              $('#editNodeModal').modal('hide');
            }, 1000);
          })
          .on('ajax:error', function(e, data, status, xhr) {
            $('form', 'div.modal-body').render_form_errors('node', data.responseJSON);
          })
      });

    });

  };

  function updateNode(id, event) {
    $.ajax({
      headers : {
          'Accept' : 'application/vnd.api+json',
          'Content-Type' : 'application/vnd.api+json'
      },
      url : '/api/v1/nodes/'+event.draggedNode[0].id+'/relationships/parent',
      type : 'PATCH',
      data : JSON.stringify({ data: { type: 'nodes', id: id }})
    })
  }

  function createNode(newName, parentId) {
    return $.ajax({
      headers : {
          'Accept' : 'application/vnd.api+json',
          'Content-Type' : 'application/vnd.api+json'
      },
      url : '/api/v1/nodes/',
      type : 'POST',
      data : JSON.stringify({ data: { type: 'nodes', attributes: { name: newName}, relationships: { parent: { data: { type: 'nodes', id: parentId }}} }})
    });
  }

  function deleteNode(id) {
    return $.ajax({
       headers : {
          'Accept' : 'application/vnd.api+json',
          'Content-Type' : 'application/vnd.api+json'
      },
      url : '/api/v1/nodes/'+id,
      type : 'DELETE'
    })
  }

  // Determine whether parent has any children (based on its colspan???)
  function hasChildren(node) {
    return node.parent().attr('colspan') > 0 ? true : false;
  }

  window.SideMenuTree = SideMenuTree;

}(jQuery))