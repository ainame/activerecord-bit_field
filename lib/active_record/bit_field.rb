# -*- coding: utf-8 -*-
require 'active_record/bit_field/version'
require 'active_support/concern'

module ActiveRecord
  module BitField
    extend ActiveSupport::Concern

    def bit_field_turn_bit_on_method(column, field)
      value = read_attribute(column)
      write_attribute(column, value | self.class.bit_field_get_column_mapper(column)[field.to_s])
      nil
    end

    def bit_field_turn_bit_off_method(column, field)
      value = read_attribute(column)
      if (value & self.class.bit_field_get_column_mapper(column)[field.to_s]) != 0
        write_attribute(column, value ^ self.class.bit_field_get_column_mapper(column)[field.to_s])
      end
      nil
    end

    def bit_field_inquire_method(column, field)
      (read_attribute(column) & self.class.bit_field_get_column_mapper(column)[field.to_s]) != 0
    end

    def bit_field_setter_method(column, field, bool)
      if bool
        bit_field_turn_bit_on_method(column, field)
      else
        bit_field_turn_bit_off_method(column, field)
      end
    end

    module ClassMethods
      # @param [Hash] args オプションを含めた引数のハッシュ、キーがカラム名値の配列がフィールド名になる
      # @option args [Boolean] :invret truthyな値を渡すとビットへのマッピング時にビットが0の状態を有効に1を無効にする
      def bit_field(args = {})
        destructed_args = args.to_a
        argument = destructed_args.shift
        options = destructed_args.to_h
        raise "can't find arguments" unless argument

        column, fields = argument
        bit_field_set_column_fields(column, fields.dup)

        mapper = bit_field_create_mapper(fields)
        bit_field_set_column_mapper(column, mapper)

        bit_field_orverride_getter_method(column, options)
        bit_field_define_setter_method(column, options)
        bit_field_define_fields_method(column, fields, options)

        fields.each do |field|
          bit_field_define_inquire_method(column, field, options)
          bit_field_define_enable_method(column, field, options)
          bit_field_define_disable_method(column, field, options)
        end
      end

      def bit_field_create_mapper(fields)
        fields.map.with_index.inject({}) do |map, (field, bit_shift)|
          map[field.to_s] = 1 << bit_shift
          map
        end
      end

      def bit_field_set_column_fields(column, fields)
        instance_variable_set("@_#{column}_fields", fields)
      end

      def bit_field_get_column_fields(column)
        instance_variable_get("@_#{column}_fields")
      end

      def bit_field_set_column_mapper(column, mapper)
        instance_variable_set("@_#{column}_mapper", mapper)
      end

      def bit_field_get_column_mapper(column)
        instance_variable_get("@_#{column}_mapper")
      end

      def bit_field_orverride_getter_method(column, options)
        unless options[:invert]
          define_method "#{column}" do
            self.class.bit_field_get_column_fields(column).reduce({}) do |mapping, field|
              mapping[field] = bit_field_inquire_method(column, field)
              mapping
            end
          end
        else
          define_method "#{column}" do
            self.class.bit_field_get_column_fields(column).reduce({}) do |mapping, field|
              mapping[field] = !bit_field_inquire_method(column, field)
              mapping
            end
          end
        end
      end

      def bit_field_define_setter_method(column, options)
        unless options[:invert]
          define_method "set_#{column}_field" do |field, value|
            bit_field_setter_method(column, field, value)
          end
        else
          define_method "set_#{column}_field" do |field, value|
            bit_field_setter_method(column, field, !value)
          end
        end
      end

      def bit_field_define_fields_method(column, fields, options)
        define_singleton_method "#{column}_fields" do
          bit_field_get_column_fields(column)
        end
      end

      def bit_field_define_inquire_method(column, field, options)
        unless options[:invert]
          define_method "#{field}?" do
            bit_field_inquire_method(column, field)
          end
        else
          define_method "#{field}?" do
            !bit_field_inquire_method(column, field)
          end
        end
      end

      def bit_field_define_enable_method(column, field, options)
        unless options[:invert]
          define_method "enable_#{column}_field" do |_field|
            bit_field_turn_bit_on_method(column, _field)
          end

          define_method "enable_#{field}" do
            bit_field_turn_bit_on_method(column, field)
          end
        else
          define_method "enable_#{column}_field" do |_field|
            bit_field_turn_bit_off_method(column, _field)
          end

          define_method "enable_#{field}" do
            bit_field_turn_bit_off_method(column, field)
          end
        end
      end

      def bit_field_define_disable_method(column, field, options)
        unless options[:invert]
          define_method "disable_#{column}_field" do |_field|
            bit_field_turn_bit_off_method(column, _field)
          end

          define_method "disable_#{field}" do
            bit_field_turn_bit_off_method(column, field)
          end
        else
          define_method "disable_#{column}_field" do |_field|
            bit_field_turn_bit_on_method(column, _field)
          end

          define_method "disable_#{field}" do
            bit_field_turn_bit_on_method(column, field)
          end
        end
      end
    end
  end
end
