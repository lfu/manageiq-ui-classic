class TreeBuilderBelongsToVat < TreeBuilderBelongsToHac
  def blue?(object)
    return false unless object.parent.present?
    object.parent.name == 'vm' &&
      object.parent.parent.present? &&
      object.parent.parent.kind_of?(Datacenter) ||
      blue?(object.parent)
  end

  def override(node, object, _pid, options)
    node[:cfmeNoClick] = true
    node[:checkable] = options[:checkable_checkboxes] if options.key?(:checkable_checkboxes)
    if [ExtManagementSystem, EmsCluster, Datacenter].any? { |klass| object.kind_of?(klass) }
      node[:hideCheckbox] = true
    end
    if object.kind_of?(EmsFolder)
      if blue?(object)
        node[:icon] = ActionController::Base.helpers.image_path("100/blue_folder.png")
      else
        node[:hideCheckbox] = true
      end
      node[:select] = options.key?(:selected) && options[:selected].include?("EmsFolder_#{object[:id]}")
    end
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:id_prefix => 'vat_')
  end

  def x_get_tree_datacenter_kids(parent, count_only)
    kids = []
    parent.folders.each do |child|
      next unless child.kind_of?(EmsFolder)
      next if child.name == "host"
      if child.name == "vm"
        kids.concat(child.folders_only)
      else
        kids.push(child)
      end
    end
    count_only_or_objects(count_only, kids)
  end
end
