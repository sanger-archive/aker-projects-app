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

  function buildTree(parentNodes, data, bool, expandedIds) {
    if (!(expandedIds instanceof Array)) {
      expandedIds = [];
    }
    return parentNodes.reduce(function(memo, parent) {

      var ret = {
        href: '/nodes/' + parent.id,
        id : parent.id,
        state: {
          expanded: expandedIds.indexOf(parent.id)>=0
        }
      };
      // depending on the type of display, tree hierachy expects 'name' and finder expects 'text'
      ret[bool ? 'name' : 'text'] = parent.attributes.name;

      var relationships = Object.keys(parent.relationships || {});
      if (relationships.length == 0) {
        memo.push(ret);
        return memo;
      }

      // depending on the type of display, tree hierachy expects 'children' and finder expects 'nodes'
      ret[bool ? 'children' : 'nodes'] = relationships
        .reduce(function(memo2, relationship) {

          // Get the relation node
          const relation = parent.relationships[relationship];
          // If it doesn't have any data we don't care about it
          if (!relation.data || relation.data.length == 0) return memo2;

          // If it does, find it's info in the data array
          const child = relation.data.map(function(datum) {
            return data.find(function(resource) {
              return resource.id == datum.id
            })
          })

          // Continue building the tree with this info
          memo2.push.apply(memo2, buildTree(child, data, bool, expandedIds));
          return memo2;
        }, []);

      memo.push(ret);

      return memo;

    }, [])
  }

  function isParent(node, childId) {
    return node.relationships.nodes && node.relationships.nodes.data && node.relationships.nodes.data.find(function(n) {
      return (n.id==childId); // This equals deliberately left doubly
    });
  }

  function findParentId(data, nodeId) {
    if (!nodeId) {
      return [];
    }
    var p = data.find(function(n) { return isParent(n, nodeId) });
    if (p) {
      return p.id;
    }
  }

  function findExpandedIds(data, currentId) {
    var expandedIds = [];
    while (currentId) {
      expandedIds.push(currentId);
      currentId = findParentId(data, currentId);
    }
    return expandedIds;
  }

  function createFrom(data, bool, currentId) {
    var expandedIds = findExpandedIds(data, currentId);
    return buildTree(parentNodes(data), data, bool, expandedIds);
  }

  window.TreeBuilder = {
    createFrom: createFrom,
    parentNodes: parentNodes
  }
}(jQuery));