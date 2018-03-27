(function($, undefined) {

  function isRoot(node, data) {
    if (typeof node === 'undefined') {
      return false;
    }
    return data.every(function(checkNode) {
      return !checkNode.relationships.nodes.data.some(function(m) {
        return (m.id == node.id);
      });
    });
  }

  function parentNodes(data) {
    var parentNodesList = [];
    data.forEach(function(parentToCheck) {
      if (isRoot(parentToCheck, data)) {
        parentNodesList.push(parentToCheck);
      }
    });
    return parentNodesList;
  }

  function buildTree(parentNodes, data, istree, expandedIds) {
    if (!(expandedIds instanceof Array)) {
      expandedIds = [];
    }
    return parentNodes.sort(function(a,b) {
      return (Date.parse(a["attributes"]['created-at']) - Date.parse(b["attributes"]['created-at']));
    }).reduce(function(memo, parent) {
      var classes = ""
      // All references to methods in node_resource.rb must use - instead of _
      if (parent.attributes['owned-by-current-user']) {
        classes = 'owned-by-current-user '
      } else if (parent.attributes['editable-by-current-user']) {
        classes = 'editable-by-current-user '
      }

      if (parent.attributes['spendable-by-current-user'] && parent.attributes['is-sub-project-node']) classes += 'spendable-by-current-user '

      node_type = "organisational"
      if (parent.attributes['is-project-node']) {
        node_type = "project"
      } else if (parent.attributes['is-sub-project-node']) {
        node_type = "sub-project"
      }

      var ret = {
        cost_code: parent.attributes['cost-code'],
        id : parent.id,
        className: classes,
        writable : parent.attributes['writable'],
        state: {
          expanded: expandedIds.indexOf(parent.id)>=0
        },
        node_type: node_type
      };
      // depending on the type of display, tree hierachy expects 'name' and finder expects 'text'
      ret[istree ? 'name' : 'text'] = parent.attributes.name;

      ret['href'] = istree ? parent.id : Routes.node_path(parent.id);

      var relationships = Object.keys(parent.relationships || {});
      if (relationships.length == 0) {
        memo.push(ret);
        return memo;
      }

      // depending on the type of display, tree hierachy expects 'children' and finder expects 'nodes'
      ret[istree ? 'children' : 'nodes'] = relationships
        .reduce(function(memo2, relationship) {

          // Get the relation node
          const relation = parent.relationships[relationship];
          // If it doesn't have any data we don't care about it
          if (!relation.data || relation.data.length == 0) return memo2;

          // If it does, find it's info in the data array
          const children = relation.data.map(function(datum) {
            return data.find(function(resource) {
              return resource.id == datum.id
            })
          }).filter(function(x) { return x }); // filter out missing nodes (presumably deactivated)

          if (children.length > 0) {
            // Continue building the tree with this info
            memo2.push.apply(memo2, buildTree(children, data, istree, expandedIds));
          }
          return memo2;
        }, []);

      memo.push(ret);

      return memo;

    }, [])
  }

  function findExpandedIds(data, currentId) {
    if (!currentId) {
      return [];
    }
    var parents = Object();
    data.forEach(function(node) {
      if (node.relationships.nodes && node.relationships.nodes.data) {
        var parentId = node.id;
        node.relationships.nodes.data.forEach(function(child) {
          parents[child.id] = parentId;
        });
      }
    });
    var expandedIds = [];
    while (currentId) {
      expandedIds.push(currentId);
      currentId = parents[currentId];
    }
    return expandedIds;
  }

  function createFrom(data, istree, currentId) {
    var expandedIds = findExpandedIds(data, currentId);
    return buildTree(parentNodes(data), data, istree, expandedIds);
  }

  window.TreeBuilder = {
    createFrom: createFrom,
    parentNodes: parentNodes
  }
}(jQuery));
