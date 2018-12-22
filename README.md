# Activerecord::BitField

[![Build Status](https://travis-ci.org/ainame/activerecord-bit_field.svg?branch=master)](https://travis-ci.org/ainame/activerecord-bit_field)

Activerecord::BitField provides a feature of mapping bit fileds to RDB table in ActiveRecord.
This is sort of reinventing the wheel. See `See Also` section.

## Requirement

Ruby 2.1.0 or higher.
This lib is using Array#to_h.

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

0. Put `require 'active_record/bit_field'` if you don't use autoload
1. Define the integer column to using management of fields and create a migration file
2. Declare the bit_field in arbitrary models

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

ActiveRecord::BitField can achieve default-true bit field easily.
Normally, developers specify `DEFAULT 0` to fields column, then "0" bit is supposed to represent `false` and "1" bit is supposed to represent `true`. If you want to use a single bit field which is true by default in a single column, perhaps, you may need to specify `DEFAULT 1` in the table schema. Then there would be a problem. What if you want to add additional fields to that existing column? How can we prepare default values for rest of new bit fields?

`ActiveRecord::BitField` provides `invert` option. If you set `true` value with "invert" key, `ActiveRecord::BitField` deals with bit state oppositely; "0" bit behaves `true` and "1" bit behaves false.

```ruby
class FilePermission < ActiveRecrod::Base
  include ActiveRecord::BitField

  bit_field permission: [:read, :write, :execute], invert: true
end

file_permisson = FilePermission.new
file_permisson.read? #=> true in default
```

## See Also

You can use other products in the same need. This plugin doesn't have the select query each fields feature, but these have it.

* [pboling/flag_shih_tzu](https://github.com/pboling/flag_shih_tzu)
* [grosser/bitfields](https://github.com/grosser/bitfields)

## Contributing

1. Fork it ( https://github.com/ainame/activerecord-bit_field/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
