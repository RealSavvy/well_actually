require "spec_helper"

RSpec.shared_examples "basic tests" do |sufix|
  it "well_actually instances are flagged as such and don't flag original instances as well_actually?" do
    expect(dog.well_actually?).to eql false
    expect(dog_actually.well_actually?).to eql true
    expect(dog.well_actually?).to eql false
  end

  it "overwritten attributes take precedence" do
    expect(dog_actually.name).to eql "Raymond"+sufix
  end

  it "allows for listed attributes to be overwritten" do
    dog.public_send(overwrite_attribute)["name"] = "Ray"
    expect(dog_actually.name).to eql "Ray"+sufix
  end

  it "a nil overwritten value should result in the actual value" do
    dog.public_send(overwrite_attribute)["name"] = nil
    expect(dog_actually.name).to eql "Radar"+sufix
  end

  it "an int attribute overwrite will always be transformed to an int" do
    dog.public_send(overwrite_attribute)["age"] = "9"
    expect(dog_actually.age).to eql 9
  end

  it "a boolean attribute overwrite will always be transformed to a boolean and false value will overwrite" do
    dog.public_send(overwrite_attribute)["show"] = false
    expect(dog_actually.show).to eql false
  end

  it "a time attribute overwrite will always be transformed to a time" do
    dog.public_send(overwrite_attribute)["birthday"] = birthday_overwrite.iso8601
    expect(dog_actually.birthday).to eql birthday_overwrite
  end

  it "an attribute not in well_actually declartion will not be overwritten if overwrite is set form init" do
    expect(dog_actually.breed).to eql "Korgi"+sufix
  end

  it "an attribute not in well_actually declartion will not be overwritten after setting overwrite" do
    dog.public_send(overwrite_attribute)["breed"] = "Cat!!~!FOOBAR"
    expect(dog_actually.breed).to eql "Korgi"+sufix
  end

  it "a blank string overwritten value should be ignored" do
    dog.public_send(overwrite_attribute)["name"] = ""
    expect(dog_actually.name).to eql "Radar"+sufix
  end

  it "a overwrite being nil instead of a hash doesn't cause an error" do
    expect(dog_no_overwrite.well_actually.name).to eql "Radar"+sufix
  end

  if defined?(ActiveSupport)
    it "well_actually instances are read only and do not cause the original instances to become read only" do
      expect(dog.readonly?).to eql false
      expect(dog_actually.readonly?).to eql true
      expect(dog.readonly?).to eql false
    end
  end
end

RSpec.describe WellActually do
  it "has a version number" do
    expect(WellActually::VERSION).not_to be nil
  end

  let(:inherits_from_class) do
    defined?(ActiveRecord::Base) ? [ActiveRecord::Base] : []
  end

  let(:overwrite_attribute) do
    :overwrite
  end

  let(:base_class) do
    klass = Class.new(*inherits_from_class)
    klass.class_eval %Q{
      attr_accessor :#{overwrite_attribute}
      if defined?(ActiveRecord::Base)
        self.table_name = "dogs"
      else
        attr_accessor :name
        attr_reader   :breed
        attr_reader   :age
        attr_reader   :show
        attr_reader   :birthday

        def initialize(#{overwrite_attribute}:nil, name: nil, breed: nil, age: nil, show: nil, birthday: nil)
          self.public_send(:"#{overwrite_attribute}=", #{overwrite_attribute})
          @name = name
          @breed = breed
          self.age = age
          self.show = show
          self.birthday = birthday
        end

        def age= value
          @age = value.to_i
        end

        def show= value
          @show = !!value
        end

        def birthday= value
          @birthday = (value.respond_to?(:to_time) ? value.to_time : DateTime.iso8601(value.to_s).to_time)
        end
      end

      extend WellActually
      well_actually overwrite: :#{overwrite_attribute}, attributes: [:name, :age, :show, :birthday]
    }
    klass
  end

  let(:dog_attributes) do
    {name: "Radar", breed: "Korgi", age: 10, show: true, birthday: Time.new(2010,1,1)}
  end

  let(:birthday_overwrite) do
    Time.new(2011,1,1)
  end

  let(:dog_overwrite) do
    {overwrite_attribute => {"name" => "Raymond", "breed" => "Foobar"}}
  end

  let(:dog) do
    dog_klass.new(dog_attributes.merge(dog_overwrite))
  end

  let(:dog_actually) do
    dog.well_actually
  end

  let(:dog_no_overwrite) do
    dog_klass.new(dog_attributes)
  end

  context "when used from a base class" do
    let(:dog_klass) do
      base_class
    end

    include_examples "basic tests", ""
  end

  context "when used from a child class" do
    let(:dog_klass) do
      klass = Class.new(base_class)
      klass.class_eval do
        def name
          "#{super} Dog"
        end

        def breed
          "#{super} Dog"
        end
      end
      klass
    end

    include_examples "basic tests", " Dog"
  end

  context "overwrite_attribute is :foobar" do
    let(:dog_klass) do
      base_class
    end

    let(:overwrite_attribute) do
      :foobar
    end

    include_examples "basic tests", ""
  end
end
