# -*- encoding : utf-8 -*-
module Rails
  module Generators
    class ModelGenerator < NamedBase #metagenerator
      "Teste"
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      hook_for :orm, :required => true
    end
  end
end

