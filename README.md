# Activerecord::BitField

[![Build Status](https://travis-ci.org/ainame/activerecord-bit_field.svg?branch=master)](https://travis-ci.org/ainame/activerecord-bit_field)

Activerecord::BitField provide a feature of mapping bit fileds to RDB table in ActiveRecord.
This is reinventing the wheel; see `See Also` section.

## Requirement

Ruby 2.1.0 or higher.
Because, this using Array#to_h.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-bit_field'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-bit_field

## Usage

At first, `require 'active_record/bit_field'` when don't using autoload.
Next, define the integer column to using management of fields.
Finaly, declare the bit_field in arbitrary models.

```ruby
class AddFilePermissionsTable < ActiveRecord::Migration
  def change
    create_table(:file_permissions) do |t|
      t.integer :file_id, null: false, default: 0 # you must specify `default: 0`
      t.integer :permission, null: false
    end
  end
end

...

class FilePermission < ActiveRecrod::Base
  include ActiveRecord::BitField

  # :read map to first bit, :write map to second, ....
  #
  # .. 0 0 0 0 | 0 0 0 0    <- permission column
  #                | | |
  #            +---+ | `-----+
  #            |     |       |
  #        execute write   read
  #
  bit_field permission: [:read, :write, :execute]
end

file_permission = FilePermission.new
file_permission.read? # => false in default

file_permission = FilePermission.create(file_id: 1, permission: 1) # `1` is the bit map value
file_permission.read? # => true
file_permission.write? # => false

file_permission.enable_write
file_permission.disable_read
file_permission.enable_execute
file_permission.save!

file_permission.permissin # => { read: false, write: true, execute: true }
```

### Options

ActiveRecord::BitField can easily realize default-true bit field.
In normaly, specify `DEFAULT 0` to fields column, then turn bit off(0) represent false
and turn bit on(1) represent true. If you want to use default-true bit field,
you maybe specify `DEFAULT 1` in table schema. But, when you want to add other field
in that column, how do it?

ActiveRecord::BitField ready `invert` option. If you provide true value with :invert key,
ActiveRecord::BitField invert dealing of bit state; turn bit off(0) represent true and turn bit on(1) represent false.

```ruby
class FilePermission < ActiveRecrod::Base
  include ActiveRecord::BitField

  bit_field permission: [:read, :write, :execute], invert: true
end

file_permisson = FilePermission.new
file_permisson.read? #=> true in default
```

## See Also

You can use other products in same needs.
This plugin don't have the select query each fields feature.
But, these have it.

* [pboling/flag_shih_tzu](https://github.com/pboling/flag_shih_tzu)
* [grosser/bitfields](https://github.com/grosser/bitfields)

## Contributing

1. Fork it ( https://github.com/ainame/activerecord-bit_field/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
