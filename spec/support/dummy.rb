ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

class DummySchema < ActiveRecord::Migration
  def change
    create_table :dummies do |t|
      t.integer :flags, default: 0, null: false
    end

    create_table :dummy_inverts do |t|
      t.integer :flags, default: 0, null: false
    end
  end
end

ActiveRecord::Migration.suppress_messages do
  DummySchema.migrate(:up)
end

class Dummy < ActiveRecord::Base
  include ActiveRecord::BitField
  bit_field flags: [:aaa, :bbb, :ccc]
end

class DummyInvert < ActiveRecord::Base
  include ActiveRecord::BitField
  bit_field flags: [:aaa, :bbb, :ccc], invert: true
end
