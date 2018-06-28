require_relative '../../../spec_helper'
require_relative 'shared/include'
require 'set'

ruby_version_is "2.5" do
  describe "CharacterSet#===" do
    it_behaves_like :sorted_set_0_include, :===
  end
end
