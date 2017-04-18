(function($,undefined) {
  function SideMenu() {
    this.attachHandlers();
  }

  window.SideMenu = SideMenu;

  var proto = SideMenu.prototype;

  proto.attachHandlers = function() {
    this.loadSidebar();
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




}(jQuery))