# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_existence}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tanel Suurhans", "Tarmo Lehtpuu"]
  s.date = %q{2011-06-15}
  s.description = %q{A library for validating model association existence.}
  s.email = ["tanel.suurhans@perfectline.ee", "tarmo.lehtpuu@perfectline.ee"]
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown"]
  s.homepage = %q{http://github.com/perfectline/validates_existence/tree/master}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Validates Rails model belongs_to association existence.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
