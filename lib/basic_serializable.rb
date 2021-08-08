# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/ClassLength
# rubocop: disable Metrics/CyclomaticComplexity
# rubocop: disable Metrics/PerceivedComplexity

require 'json'
require 'msgpack'
require 'yaml'

# mixin
module BasicSerializable
  # should point to a class; change to a different class
  # (e.g. MessagePack, JSON, YAML) to get a different serialization
  @@serializer = YAML

  def serialize_original
    # original serialize, works for the most part
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump obj
  end

  def serialize
    obj = {}

    instance_variables.map do |var|

      case var
      when :@board_contents
        obj[var] = instance_variable_get(var).map { |row| row.map { |piece| piece.nil? ? nil : piece.serialize } }
      when :@black || :@white
        obj[var] = instance_variable_get(var).map do |piece|
          piece.nil? ? nil : instance_variable_get(var)[piece[0]].serialize
        end
      else
        obj[var] = instance_variable_get(var)
      end
    end

    YAML.dump(obj)
  end

  def serialize_old
    obj = {}
    obj = serialize_child(obj)
    binding.pry unless obj.empty?
    instance_variables.map do |var|
      next if var == :@board_contents

      binding.pry if instance_variables.include?(:@board_contents)
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump obj
  end

  def serialize_complex
    obj = {}
    instance_variables.map do |var|
      case var
      when :@board_contents
        obj[var] = instance_variable_get(var).map { |row| row.map { |piece| piece.nil? ? nil : piece.serialize } }
      when :@black || :@white
        obj[var] = instance_variable_get(var).map do |piece|
          piece.nil? ? nil : instance_variable_get(var)[piece[0]].serialize
        end
      else
        obj[var] = instance_variable_get(var)
      end
      # if var == :@board_contents
      #   obj[var] = instance_variable_get(var).map { |row| row.map { |piece| piece.nil? ? nil : piece.serialize } }
      # elsif var == :@black || var == :@white
      #   binding.pry
      #   obj[var] = instance_variable_get(var).map do |piece|
      #     binding.pry
      #     piece.nil? ? nil : instance_variable_get(var)[piece[0]].serialize
      #   end
      #   binding.pry
      # else
      #   obj[var] = instance_variable_get(var)
      # end
    end

    @@serializer.dump obj
  end

  def unserialize(string)
    # obj = @@serializer.parse(string)
    # binding.pry
    obj = YAML.load string
    binding.pry
    obj.each_key do |key|
      # binding.pry
      instance_variable_set(key, obj[key])
    end
  end

  def serialize_child(obj)
    obj
  end

  def unserialize_child(obj)
    obj
  end
end

# rubocop: enable Metrics/PerceivedComplexity
# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
