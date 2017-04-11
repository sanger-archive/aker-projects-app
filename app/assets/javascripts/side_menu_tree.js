(function($,undefined) {
  function SideMenuTree() {
    MODULES.forEach($.proxy(function(module) {
      module.apply(this, arguments);
    }, this));
    this.attachHandlers();
  }

  window.SideMenuTree = SideMenuTree;

  var MODULES = [
    OrgChartTree
  ];  

  SideMenuTree.prototype = $.extend.call(this, SideMenuTree.prototype, OrgChartTree.prototype);

  var proto = SideMenuTree.prototype;

  proto.alert = function(msg) {
    $('#tree-hierarchy').prepend('<div class="alert alert-danger">'+msg+'</div>');
  }

  proto.attachHandlers = function() {
    this.attachSidebarHandlers();
    this.attachOrgChartHandlers();
  };

  proto.attachOrgChartHandlers = function() {
    $(document).ready($.proxy(this.loadTree, this));
    $(document).on('turbolinks:load', $.proxy(this.loadTree, this));
    $(document).ready($.proxy(this.attachMenuHandlers, this));
  };

  proto.attachSidebarHandlers = function() {
    var loadSidebar = $.proxy(this.loadSidebar, this)

    $(document).ready(loadSidebar);
    $('#tree-tab').on('show.bs.tab', $.proxy(function() {
      if (this.selectedNode() && this.selectedNode().attr('id')) {
        window.location.href='/nodes/'+this.selectedNode().attr('id');
      } else {
        this.loadSidebar(); 
      }
    }, this));
  };

  proto.unauthorizedRequest = function(promise, msg, status) {
    if (status === 'Unauthorized') {
      $('#tree-tab').html('');
      $('#side_menu_tree').html('');
      
    }
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
      $('#side_menu_tree')
    }).fail($.proxy(this.unauthorizedRequest, this));

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


  

}(jQuery))