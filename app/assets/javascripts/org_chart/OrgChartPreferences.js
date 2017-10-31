(function($, undefined) {
  var SAVE_URL = "/tree_layouts";
  var RESTORE_URL = "/tree_layouts";
  var DELETE_URL = "/tree_layouts";

  function OrgChartPreferences() {
    this.attachPreferencesHandlers();
  };

  window.OrgChartPreferences = OrgChartPreferences;

  var proto = OrgChartPreferences.prototype;

  proto.attachPreferencesHandlers = function() {
    $('button[data-user-preferences-expand]').on('click', $.proxy(function() {
      this.loadTree({restoreStateRequested: false}).then($.proxy(this.saveUserConfig, this));
    }, this));
    $(this).on('orgchart.restoreStateRequested', $.proxy(function(event, opts) {
      $('.edge').on('click', $.proxy(function() {
        setTimeout($.proxy(this.saveUserConfig, this), 500);
      }, this));
      if ((!opts) || (!!opts.restoreStateRequested)) {
        this.restoreUserConfig();  
      }
    }, this)); 
  };

  proto.onSaveUserConfig = function() {
    //this.info('Tree layout saved')
  };

  proto.onErrorSaveUserConfig = function() {
    this.alert('There was a problem while saving tree layout for current user');
  };

  proto.onRestoreUserConfig = function(json) {
    var layout = this.parseLayout(json[0]);
    var success = this.applyLayout(layout);
    if (layout) {
      //this.info('Tree layout restored');
      return layout;
    } else {
      this.onErrorRestoreUserConfig();  
    }
  };

  proto.onErrorRestoreUserConfig = function() {
    this.alert('There was a problem while restoring tree layout for current user');
  };

  proto.parseLayout = function(json) {
    if (!json) {
      return null;
    }
    return JSON.parse(json.tree_layout.layout);
  };

  function getIdsForNodesWithCss(cssSelector) {
    return $(cssSelector).map(function(pos, n) { return n.id;}).toArray();
  }

  proto.getLayout = function() {
    return {
      'slide-left': getIdsForNodesWithCss('.node.slide-left'),
      'slide-right': getIdsForNodesWithCss('.node.slide-right'),
      'slide-up': getIdsForNodesWithCss('.node.slide-up'),
      'slide-down': getIdsForNodesWithCss('.node.slide-down')
    }
  };

  proto.serializeLayout = function() {
    return JSON.stringify({tree_layout: {layout: JSON.stringify(this.getLayout())}});
  };

  proto.parentFor = function(node) {
    return $('#tree-view').orgchart('getRelatedNodes', node, 'parent');
  };

  proto.childrensFor = function(node) {
    return $('#tree-view').orgchart('getRelatedNodes', node, 'children');
  };

  proto.siblingsFor = function(node) {
    return $('#tree-view').orgchart('getRelatedNodes', node, 'siblings');
  };

  proto.siblingsIncludingMeFor = function(node) {
    var siblings = $('#tree-view').orgchart('getRelatedNodes', node, 'siblings');
    if (siblings.length > 0) {
      for (var i=0; i<siblings.length; i++) {
        // I always insert at the left when I am less than the compared value
        if (parseInt(node[0].id, 10) < parseInt(siblings[i].id, 10)) {
          siblings.splice(i, 0, node[0])
          return siblings;
        }
      }
      // The last element is inserted different because is inserted at the right
      if (parseInt(node[0].id, 10) > parseInt(siblings[siblings.length-1].id, 10)) {
        siblings.push(node[0]);
      }
    }
    return siblings;
  };


  proto.siblingFor = function(node, direction) {
    var siblings = this.siblingsIncludingMeFor(node);
    if (direction) {
      if (siblings) {
        var pos = siblings.toArray().findIndex(function(n) {
          return (n===node[0]);
        });
        if (direction == 'left') {
          if (pos>0) {
            return $(siblings[pos-1]);
          } else {
            return null;
          }          
        }
        if (direction == 'right') {
          if (pos=== siblings.length) {
            return null;
          } else {
            return $(siblings[pos+1]);
          }
        }
      }
      
    }
    return null;
  };

  proto.filterNotSlidedNodes = function(nodes, layout) {
    return $(nodes).filter(function(pos, node) {
      var out = false;
      for (var key in layout) {
        out = out || (layout[key].indexOf(node.id) >= 0);
      }
      return !out;
    });
  };

  proto.isVisibleNode = function(node) {
    return !(node.hasClass('slide-up') || node.hasClass('slide-down') || 
    node.hasClass('slide-left') || node.hasClass('slide-right'));
  };

  proto._applyLayoutAction = function($node, action) {
    if ($node && ($node.length>0)) {
      if (this.isVisibleNode($node)) {
        $('#tree-hierarchy').orgchart(action, $node);
      }
    }
  };

  proto.applyLayout = function(layout) {
    var id;
    var keys = ['slide-down', 'slide-up', 'slide-left', 'slide-right'];
    for (var j=0; j<keys.length; j++) {
      var key = keys[j];
      for (var i=0; i<layout[key].length; i++) {
        id = layout[key][i]
        var $node = $(document.getElementById(id));
        if (key == 'slide-down') {
          // We need to execute the action in a node currently displayed, that's why we need to filter
          // the list of nodes that will be hidden
          var $firstChildren = $(this.filterNotSlidedNodes(this.childrensFor($node), layout)[0]);
          this._applyLayoutAction($firstChildren, 'hideParent');
        }
        if (key == 'slide-up') {
          var $parent = this.parentFor($node);
          this._applyLayoutAction($parent, 'hideChildren');
        }
        if (key == 'slide-left') {
          var $sibling = this.siblingFor($node, 'left');
          this._applyLayoutAction($sibling, 'hideSiblings');
        }        
        if (key == 'slide-right') {
          var $sibling = this.siblingFor($node, 'right');
          this._applyLayoutAction($sibling, 'hideSiblings');
        }
      }
    }
    return true;
  };

  proto.saveUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },
      method: 'POST',
      url: SAVE_URL, 
      data: this.serializeLayout()
    }).then(
      $.proxy(this.onSaveUserConfig, this), 
      $.proxy(this.onErrorSaveUserConfig, this)
    );
  };

  proto.resetUserConfig = function() {
    this.deleteUserConfig().then($.proxy(this.loadTree, this, null));
  };

  proto.deleteUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },      
      method: 'DELETE',
      url: DELETE_URL
    }).then(
      $.proxy(this.onDeleteUserConfig, this), 
      $.proxy(this.onErrorDeleteUserConfig, this)
    );
  };

  proto.onDeleteUserConfig = function() { this.info('Tree layout deleted')};
  proto.onErrorDeleteUserConfig = function() { this.alert('Error while deleting tree layout')};

  proto.restoreUserConfig = function() {
    return $.ajax({
      headers : {
          'Accept' : 'application/json',
          'Content-Type' : 'application/json'
      },      
      method: 'GET',
      url: RESTORE_URL
    }).then(
      $.proxy(this.onRestoreUserConfig, this), 
      $.proxy(this.onErrorRestoreUserConfig, this)
    );
  };

})(jQuery);