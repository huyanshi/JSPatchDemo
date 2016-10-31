defineClass('JSPatchDome.TestViewController',{
            tableView_numberOfRowsInSection:function(tableView,section){
            return 10
            },
            tableView_didSelectRowAtIndexPath:function(tableView,indexPath){
            var row = indexPath.row
            var alertView = require('UIAlertView').alloc().init();
            alertView.setMessage('点击了第行');
            alertView.addButtonWithTitle('OK');
            alertView.show();
            }
            })