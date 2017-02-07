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

  function buildTree(parentNodes, data) {

    return parentNodes.reduce(function(memo, leaf) {
      
      var ret = {
        text: leaf.attributes.name,
        href: '/nodes/' + leaf.id
        // icon: getIcon(leaf),
        // selectedIcon: getSelectedIcon(leaf)
      };

      var relationships = Object.keys(leaf.relationships || {});

      if (relationships.length == 0) {
        memo.push(ret);
        return memo;
      }

      ret.nodes = relationships
        .reduce(function(memo2, relationship) {
    
          // Get the relation node
          const relation = leaf.relationships[relationship];
          // If it doesn't have any data we don't care about it
          if (!relation.data || relation.data.length == 0) return memo2;

          // If it does, find it's info in the data array
          const child = relation.data.map(function(datum) {
            return data.find(function(resource) {
              return resource.id == datum.id
            })
          })
   
          // Continue building the tree with this info
          memo2.push.apply(memo2, buildTree(child, data));
          return memo2;
        }, []);

      memo.push(ret);

      return memo;

    }, [])
  }

  function getIcon(resource) {
    if (resource.type == 'programs') {
      return 'fa fa-folder-o';
    } else {
      return 'fa fa-caret-right';
    }
  }

  function getSelectedIcon(resource) {
    switch(resource.type) {
      case 'programs':
        return 'fa fa-folder-open-o';
      default:
        return '';
    }
  }

  function createFrom(data) {
    return buildTree(parentNodes(data), data);
  }

  window.TreeBuilder = {
    createFrom: createFrom
  }
}(jQuery));