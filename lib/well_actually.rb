require "well_actually/version"
require "well_actually/mounter"

module WellActually
  def well_actually(options={})
    Mounter.new(options.merge(klass: self)).mount
  end
end
