module WellActually
  class Mounter
    attr_reader :klass, :overwrites, :attributes

    BLANK_RE = defined?(String::BLANK_RE) ? String::BLANK_RE : /\A[[:space:]]*\z/

    def initialize(klass:, overwrites: nil, overwrite: nil, attributes:)
      overwrites = overwrite || overwrites
      raise ArgumentError.new("overwrite must be a symbol or an array of symbols") unless overwrites.is_a?(Symbol) || (overwrites.is_a?(Array) && overwrites.all?{|a| a.is_a?(Symbol)})
      raise ArgumentError.new("attributes must be an array of symbols") unless attributes.is_a?(Array) && attributes.all?{|a| a.is_a?(Symbol)}
      @klass = klass
      @overwrites = overwrites
      @attributes = attributes.uniq
    end

    def mount
      klass.class_variable_set(:@@well_actually_attributes, attributes.map{|_attr| _attr.to_s})
      klass.class_variable_set(:@@well_actually_overwrites, [*overwrites])

      klass.send(:define_singleton_method, :well_actually_attributes) do
        self.class_variable_get(:@@well_actually_attributes)
      end

      klass.send(:define_method, :well_actually_attributes) do
        self.class.well_actually_attributes
      end

      klass.send(:define_singleton_method, :well_actually_overwrites) do
        self.class_variable_get(:@@well_actually_overwrites)
      end

      klass.send(:define_method, :well_actually_overwrites) do
        self.class.well_actually_overwrites.map do |overwrite|
          self.public_send(overwrite)
        end.reduce({}) do |result, overwrite|
          result.merge(overwrite || {}) do |key, v1, v2|
            v1 = nil unless self.well_actually_overwrite_value_check(key, v1)
            v2 = nil unless self.well_actually_overwrite_value_check(key, v2)
            v1.nil? ? v2 : v1
          end
        end
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
        (self.well_actually_overwrites || {}).select do |key, value|
          self.well_actually_overwrite_value_check(key, value)
        end
      end

      klass.send(:define_method, :well_actually_overwrite_value_check) do |key, value|
        self.well_actually_attributes.include?(key) && !value.nil? && (!value.is_a?(String) || !value.match(BLANK_RE))
      end
    end
  end
end
