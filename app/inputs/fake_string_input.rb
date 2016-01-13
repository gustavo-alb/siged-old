class FakeStringInput < SimpleForm::Inputs::StringInput

  # Creates a basic input without reading any value from object
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.text_field_tag(attribute_name, nil, merged_input_options)
  end # method

  def merge_wrapper_options(options, wrapper_options)
    if wrapper_options
      options.merge(wrapper_options) do |_, oldval, newval|
        if Array === oldval
          oldval + Array(newval)
        end
      end
    else
      options
    end
  end # method

end # class
