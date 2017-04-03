(function($,undefined) {
  function SideMenuTree() {
    this.resetStatusMenu();
    this.attachHandlers();
  }

  function alert(msg) {
    $('#tree-hierarchy').prepend('<div class="alert alert-danger">'+msg+'</div>');
  }

  var proto = SideMenuTree.prototype;

  proto.resetStatusMenu = function() {
    $('#edit-panel button').prop('disabled', true);
    $('#edit-panel input').prop('disabled', true);
    $('#edit-panel input').val('')
    $('#selected-node').val('');    
  };

  proto.equalHierarchy = function(tree1, tree2) {
    if ((!tree1 || !tree2) || (tree1.id !== tree2.id)) {
      return false;
    } else {
      if (tree1.children && (tree1.children.length>0)) {
        if (!((tree2.children) && (tree2.children.length>0))) {
          return false;
        }        
        return tree1.children.every($.proxy(function(child) {
          var child2 = tree2.children.filter(function(child2) {
            return (child2.id == child.id);
          })[0];
          return (this.equalHierarchy(child, child2));
        }, this));
      }
      return true;
    }
  }

  proto.keepTreeUpdate = function() {
    var defer = $.Deferred();
    return $.get('/api/v1/nodes?include=nodes.parent', $.proxy(function(response, status, promise) {
      var localTree = $('#tree-hierarchy').orgchart('getHierarchy');
      var remoteTree = TreeBuilder.createFrom(response.data, true)[0]
      if (!this.equalHierarchy(localTree, remoteTree) || !this.equalHierarchy(remoteTree, localTree)) {
        resetTree.call(this);
        defer.reject();
        return defer;
        //return Promise.reject('Not up to date');
      }
      defer.resolve();
      return defer;
    }, this)).fail($.proxy(onErrorConnection, this));
    return promise;
  }

  proto.attachHandlers = function() {
    var loadSidebar = $.proxy(this.loadSidebar, this)

    $(document).ready(loadSidebar);
    $('#tree-tab').on('show.bs.tab', function(e) {
      if (e.target.innerText == 'Home') loadSidebar();
    })
    $(document).ready($.proxy(this.loadTree, this));
    $(document).on('turbolinks:load', $.proxy(this.loadTree, this));
    $(document).ready($.proxy(this.attachMenuHandlers, this));
  };


  proto.attachMenuHandlers = function() {
    $('#btn-add-nodes').on('click', $.proxy(this.onAddNodes, this));

    // Delete Button
    $('#btn-delete-nodes').on('click', $.proxy(this.onDeleteNodes, this));

    // Reset Button
    $('#btn-reset').on('click', $.proxy(this.onResetNodes, this));

    $('#editNodeModal').on('show.bs.modal', $.proxy(this.onUpdateNodes, this));    
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
  };

  proto.onAddNodes = function() {
    // Get the values of the new nodes and add them to the nodeVals array
    var newNodeName = $('#new-node').val().trim();

    // Get the data of the currently selected node
    var $node = $('#selected-node').data('node');

    if (newNodeName.length == 0 || !$node) {
      return;
    }
    createNode.call(this, newNodeName, $node[0].id).then(function (response) {
      // See https://github.com/dabeng/OrgChart#structure-of-datasource
      var relationship = '';
      var id = response['data']['id'];

      $node.attr('id', id);
      if (!hasChildren($node)) {
        // Relationship will always be "has parent, no siblings, no children"
        relationship = '100'

        /*$('#chart-container').orgchart('addChildren', $node, {
          'children': [{ name: newNodeName, relationship: relationship, id: id }]
        });*/
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
      error.responseJSON.errors.forEach(function(error) {
        alert(error.detail);
      });
    });
    $('#new-node').val('');
  };


  proto.onResetNodes = function() {
    $('#selected-node').data('node', null).val('');
    $('#new-node').val('');
  };

  proto.onDeleteNodes = function() {
    var $node = $('#selected-node').data('node');
    if ($node[0].id) {
      deleteNode.call(this, $node[0].id).then( function (response) {
        $('#chart-container').orgchart('removeNodes', $node);
        $('#selected-node').data('node', null);
      },
      function() {
        alert('Failed to delete the node');
      });
    }
  };

  proto.onUpdateNodes = function(e) {
    // We get the nodeId of the currently selected node

    var url = '/nodes/'+$('#selected-node').data('node')[0].id; 
    /*var url = $('form', e.target).attr('action');
    if (!url) {
      var url = '/nodes/'+$('#selected-node').data('node')[0].id; 
    }*/
    //var nodeId = $('#selected-node').data('node')[0].id;

    // We call jQuery's load method to fetch the html content of /nodes/:id/edit.js
    // and load it into the modal body
    $('div.modal-body', '#editNodeModal').load(url+ '/edit.js', function(response, status, xhr) {
      $('form', 'div.modal-body')
        .on('ajax:before', function() {
          $(this).clear_form_errors();
        })
        .on('ajax:beforeSend', function(event, xhr, settings) {
          xhr.setRequestHeader('Accept', 'application/json');
        })
        .on('ajax:success', function(e, data, status, xhr) {
          // If the name has updated, we need to update the node
          $('#selected-node').data('node').find('div.title').text(data['name']);
          $('#selected-node').data('node').find('div.content').text(data['cost_code']);

          // Show a success message
          $('div.modal-body', '#editNodeModal').prepend('<div class="alert alert-success">Update successful</div>');

          // Setting a timeout so the user can see the update was successful just before closing
          // the modal window
          setTimeout(function() {
            $('#editNodeModal input').each(function(input) {
              $(input).val('');
            });
            $('#editNodeModal').modal('hide');
          }, 1000);
        })
        .on('ajax:error', function(e, data, status, xhr) {
          $('form', 'div.modal-body').render_form_errors('node', data.responseJSON);
        })
    });

  };

  proto.loadTree = function() {
    var self = this;
    return $.get('/api/v1/nodes?include=nodes.parent', $.proxy(function(response) {
      var programs = TreeBuilder.parentNodes(response.data);
      $('#tree-hierarchy').orgchart({
        'data' : TreeBuilder.createFrom(response.data, true)[0],
        'depth': response.data.length,
        'nodeContent': 'cost_code',
        'nodeID': 'id',
        //'direction': 'l2r',
        'draggable' : true,
        'pan': false,
        //'zoom': true

        // Callback function called every time a node is created
        createNode: function($node, data) {
          $('#selected-node').val('');
          self.resetStatusMenu();
          $node.attr('title', data.name);
          $node.attr('id', data.id);
          $node.on('click', function(event) {
            if (!$(event.target).is('.edge')) {
              $('#selected-node').val(data.name).data('node', $node);
              //$('#edit-panel').css('visibility', 'visible');
              $('#edit-panel button').prop('disabled', false);
              $('#edit-panel input').prop('disabled', false);
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
      .on('click', '.orgchart', $.proxy(function(event) {
        if (!$(event.target).closest('.node').length) {
          this.resetStatusMenu();
        }
      }, this))

      .children('.orgchart')
      .on('nodedropped.orgchart', $.proxy(function(event) {
        $.get('/api/v1/nodes/'+event.dropZone[0].id, $.proxy(function(response) {
          updateNode.call(this, response.data.id, event);
        }, this)).fail($.proxy(onErrorConnection, this));
      }, this));

    }, this));

    //this.attachMenuHandlers();
  };

  function setIconChildren(node, val) {
    if (val) {
      if ($('.title .fa-users', node).length == 0) {
        $('.title', node).append($('<i class="fa fa-users symbol"></i>'));
      }
    } else {
      $('.title .fa-users', node).remove();
    }
  };

  function getChildrenForParentId(id) {
    return $('[data-parent]').filter(function(idx, elem) { return ($(elem).data('parent')==id);});
  }

  function getNodeNumChildren(id) {
    return getChildrenForParentId(id).length;
  }

  function updateIconChildren(dropNode, draggedNode) {
    var previousParent = $('#'+draggedNode.data('parent')+'.node');
    draggedNode.data('parent', dropNode.attr('id'));
    setIconChildren(dropNode, true);
    setIconChildren(previousParent, (getNodeNumChildren(previousParent.attr('id'))>0));
  }

  function onSuccessfulUpdateNode(id, event) {
    var dropNode = $('#'+id+'.node');
    var draggedNode = $('#'+event.draggedNode[0].id+'.node');    
    updateIconChildren(dropNode, draggedNode);
  }

  function onErrorConnection() {
    resetTree.call(this);
  }

  function disableTree() {
    $('#tree-hierarchy').html('<div class="alert alert-danger">Sorry, there was a problem while updating the server</div>');
    $('#tree-hierarchy').append('<button id="reconnect" class="button btn btn-default">Reconnect?</button>');
    $('#reconnect').on('click', $.proxy(resetTree, this));
  }

  function resetTree() {
    $('#tree-hierarchy').html('');
    return this.loadTree().fail($.proxy(disableTree, this));
  }

  function updateNode(id, event) {
    return this.keepTreeUpdate().then($.proxy(function() {
      return $.ajax({
        headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/'+event.draggedNode[0].id+'/relationships/parent',
        type : 'PATCH',
        data : JSON.stringify({ data: { type: 'nodes', id: id }})
      }).then($.proxy(onSuccessfulUpdateNode, this, id, event), $.proxy(onErrorConnection, this));
    }, this));
  }

  function createNode(newName, parentId) {
    return this.keepTreeUpdate().then($.proxy(function() {
      debugger;
      return $.ajax({
        headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/',
        type : 'POST',
        data : JSON.stringify({ data: { type: 'nodes', attributes: { name: newName}, relationships: { parent: { data: { type: 'nodes', id: parentId }}} }})
      }).fail($.proxy(onErrorConnection, this));
    }, this));
  }

  function deleteNode(id) {
    return this.keepTreeUpdate().then($.proxy(function() {
      return $.ajax({
         headers : {
            'Accept' : 'application/vnd.api+json',
            'Content-Type' : 'application/vnd.api+json'
        },
        url : '/api/v1/nodes/'+id,
        type : 'DELETE'
      }).fail($.proxy(onErrorConnection, this));
    }, this));
  }

  // Determine whether parent has any children (based on its colspan???)
  function hasChildren(node) {
    return node.parent().attr('colspan') > 0 ? true : false;
  }

  window.SideMenuTree = SideMenuTree;

}(jQuery))