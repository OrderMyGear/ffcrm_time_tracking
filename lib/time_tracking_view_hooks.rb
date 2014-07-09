class TimeTrackingViewHooks < FatFreeCRM::Callback::Base

 insert_before :show_account_bottom do |view, context|
   view.render(:partial => 'time_records/list', locals: { object: view.instance_variable_get(:@account) })
 end

 insert_before :show_project_bottom do |view, context|
   view.render(:partial => 'time_records/list', locals: { object: view.instance_variable_get(:@project) })
 end

 def auto_complete(controller, context = {})
   klass = controller.send(:klass)
   exclude_ids = controller.send(:auto_complete_ids_to_exclude, controller.params[:related])
   search_params = { :id_not_in => exclude_ids }
   if (scope = controller.params[:scope])
     model, id  = scope.split('_')
     if (related = model.classify.constantize.my.find_by_id(id))
       search_params.merge!("#{model}_id_eq" => related.id)
     end
   end
   klass.my.text_search(context[:query]).search(search_params).result.limit(10)
 end
end
