require "htransform/version"

class HTransform

  ValueNotPresentError = Class.new(StandardError)

  class << self
    attr_reader :transform_block

    attr_reader :input_nest
    attr_reader :output_nest

    def convert(input_hash)
      new.convert(input_hash)
    end

    def transform(&trans_block)
      @transform_block = trans_block
    end
  end

  def initialize
    @output_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @rejected, @input_nest, @output_nest = [], [], []
    @inputs = Set.new
  end

  def convert(input)
    @input_hash = input_hash(input)
    instance_exec(&self.class.transform_block)
    Hash[@output_hash]
  end

  private

  def input_hash(input)
    unless input.is_a?(Hash)
      return input.to_hash if input.respond_to?(:to_hash)
      raise ArgumentError "object is not a Hash or does not respond to to_hash"
    end
    input
  end

  def record(*keys)
    keys.each{ |key| @inputs << key }
  end

  def recorded?(key)
    @inputs.include? key
  end

  def set_val(dst, val)

    dst = (@output_nest + [dst]).flatten unless @output_nest.empty?

    if dst.is_a? Array
      last_key = dst.pop
      dst.reduce(@output_hash) { |h,k| h[k] }[last_key] = val
    else
      @output_hash[dst] = val
    end
  end

  def get_val(src)
    return get_val!(src)
  rescue ValueNotPresentError
    return nil
  end

  def get_val!(src)

    src = (@input_nest + [src]).flatten unless @input_nest.empty?

    if src.is_a? Array
      src.reduce(@input_hash) { |h,k| h[k] }
    else
      if @input_hash.key?(src)
        @input_hash[src]
      else
        raise ValueNotPresentError
      end
    end
  end

  def key_present?(src)
    src = (@input_nest + [src]).flatten unless @input_nest.empty?
    if src.is_a? Array
      src.reduce(@input_hash) do |h, k|
        h[k].is_a?(Hash) ? h[k] : h.has_key?(k)
      end
    else
      @input_hash.key?(src)
    end
  end

  def rejected?(src)
    @rejected.include?(src)
  end

  def parse_options(options)
    from, to, via, default = nil

    via = options.delete :via
    default = options.delete :default

    from, to = if options.key? :from and options.key? :to
      [options[:from], options[:to]]
    else
      options.delete :from
      options.delete :to

      lazy_args = options.shift
      if lazy_args.is_a? Array and lazy_args.length == 2
        lazy_args
      end
    end

    [from, to, via, default]
  end

  def passthrough(*options)
    options.each do |k|
      begin
        input_value = get_val!(k)
        @rejected.delete(k)
        set_val(k, input_value)
      rescue ValueNotPresentError
      end
    end
  end

  def reject(*options)
    options.each { |k| @rejected << k }
  end

  def passthrough_remaining
    @input_hash.each_key do |key|
      passthrough(key) unless recorded?(key) || rejected?(key)
    end
  end

  def input_multiple(options)
    from, to, via, default = parse_options(options)
    via = lambda { |x| x.join(" ") } if via.nil?


    old_values = from.map{ |k| get_val(k) }
    new_value = if via.is_a? Proc
      via.call old_values
    elsif via.is_a? Symbol
      if methods.include? via.to_s or methods.include? via
        via_method = method(via)
        if via_method.arity != 1
          via_method.call(*old_values)
        else
          via_method.call(old_values)
        end
      else
        old_values.send(via)
      end
    end

    record(*from)
    set_val(to, new_value)
  end

  def input(options)
    from, to, via, default = parse_options(options)
    return if !key_present?(from) && default.nil?

    new_value = if get_val(from).nil? && !default.nil?
      default.respond_to?(:call) ? default.call : default
    elsif via.is_a? Proc
      via.call get_val(from)
    elsif via.is_a? Symbol
      if methods.include? via.to_s or methods.include? via
        via_method = method(via)
        if via_method.arity != 1
          method(via).call(*get_val(from))
        else
          method(via).call(get_val(from))
        end
      else
        get_val(from).send(via)
      end
    else
      get_val(from)
    end

    record(*from)
    set_val(to, new_value)
  end

  def insert(options)
    options.each { |key, value| set_val(key, value) }
  end

  def nested(options,  &trans_block)
    
    if options.is_a? Symbol
      options = {:key => options, :type => "output"}
    else
      options[:type] = "output" unless options.key? :type
    end

    if options[:type] == "output" or options[:type] == "input"
      type = options[:type]
      if options[:key]
        key = options[:key]
        nest_var = "@#{type}_nest"
        self.instance_variable_set(:"#{nest_var}", self.instance_variable_get(:"#{nest_var}") + [key].flatten)

        instance_exec(&trans_block)

        self.instance_variable_set(:"#{nest_var}", self.instance_variable_get(:"#{nest_var}") - [key].flatten)
      end
    end
  end

end
