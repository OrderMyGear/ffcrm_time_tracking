module TimeRecordsHelper
  include UsersHelper

  def user_select_for_current_user(asset, users, myself)
    user_options = user_options_for_select(users, myself)
    select(asset, :assigned_to, user_options,
           { :include_blank => t(:unassigned), :selected => myself.id },
           { :style         => "width:160px",
             :class => 'select2'              })
  end

  def time_record_project_select(options = {})
    options[:selected] ||= @time_record.project_id || (@project && @project.id) || 0
    selected_projects = Project.my.where(id: options[:selected]).to_a
    projects = selected_projects# (selected_projects + Project.my.limit(25)).compact.uniq

    select_tag('time_record[project_id]', options_from_collection_for_select(projects, :id, :name, options),
      { :"data-placeholder" => t(:select_a_project), :"data-url" => auto_complete_projects_path(format: 'json'),
        style: "width:155px; display:none;", class: 'ajax_chosen_1', include_blank: t(:no_project_assigned) })
  end

  def section_without_select(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to_inline(create_id, create_url, :related => dom_id(related), :text => t(create_id)), :class => "subtitle_tools")
    html << content_tag(:div, t(assets), :class => :subtitle, :id => "create_#{asset}_title")
    html << content_tag(:div, "", :class => :remote, :id => create_id, :style => "display:none;")
  end
end