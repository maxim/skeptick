module Skeptick
  def geometry(options = {})
    result = ''

    result << if options[:size]
      options[:size]
    else
      if options[:width] && options[:height]
        "#{options[:width]}x#{options[:height]}"
      elsif options[:width]
        "#{options[:width]}x"
      elsif options[:height]
        "x#{options[:height]}"
      else
        ''
      end
    end

    if options[:left] || options[:top]
      left = '%+d' % (options[:left] || 0)
      top  = '%+d' % (options[:top]  || 0)
      result << "#{left}#{top}"
    end

    result << '%' if options[:percentage]
    result << '!' if options[:exact]
    result << '<' if options[:expand_only]
    result << '>' if options[:shrink_only]

    result
  end
end
