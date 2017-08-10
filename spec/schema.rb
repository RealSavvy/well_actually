ActiveRecord::Schema.define do
  self.verbose = false

  create_table :dogs, :force => true do |t|
    t.string   :type
    t.string   :name
    t.string   :breed
    t.integer  :age
    t.boolean  :show
    t.datetime :birthday
    t.string   :owner
    t.timestamps null: false
  end

  create_table :empties, :force => true do |t|
    t.string :anything_to_not_conflict_with_dog
    t.timestamps null: false
  end
end
