module WellActually
  class Mounter
    attr_reader :klass, :overwrite, :attributes

    BLANK_RE = defined?(String::BLANK_RE) ? String::BLANK_RE : /\A[[:space:]]*\z/

    def initialize(klass:, overwrite:, attributes:)
      raise ArgumentError.new("overwrite must be a symbol") unless overwrite.is_a?(Symbol)
      raise ArgumentError.new("attributes must be an array of symbols") unless attributes.is_a?(Array) && attributes.all?{|a| a.is_a?(Symbol)}
      @klass = klass
      @overwrite = overwrite
      @attributes = attributes.uniq
    end

    def mount
      klass.class_variable_set(:@@well_actually_attributes, attributes.map{|_attr| _attr.to_s})
      klass.class_variable_set(:@@well_actually_overwrite, overwrite)

      klass.send(:define_singleton_method, :well_actually_attributes) do
        self.class_variable_get(:@@well_actually_attributes)
      end

      klass.send(:define_method, :well_actually_attributes) do
        self.class.well_actually_attributes
      end

      klass.send(:define_singleton_method, :well_actually_overwrite) do
        self.class_variable_get(:@@well_actually_overwrite)
      end

      klass.send(:define_method, :well_actually_overwrite) do
        self.public_send(self.class.well_actually_overwrite)
      end

      klass.send(:define_method, :well_actually?) do
        !!self.instance_variable_get(:@well_actually)
      end

      klass.send(:define_method, :well_actually) do
        self.clone.tap do |actually|
          actually.readonly! if actually.respond_to?(:readonly!)
          actually.instance_variable_set(:@well_actually, true)
          self.send(:well_actually_overwrite_safe).each do |_attr, _value|
            if actually.respond_to?(:"#{_attr}=")
              actually.public_send(:"#{_attr}=", _value)
            else
              actually.instance_variable_set(:"@#{_attr}", _value)
            end
          end
        end
      end

      klass.send(:define_method, :well_actually_overwrite_safe) do
        (self.well_actually_overwrite || {}).select do |key, value|
          self.well_actually_attributes.include?(key) && !value.nil? && (!value.is_a?(String) || !value.match(BLANK_RE))
        end
      end
    end
  end
end
