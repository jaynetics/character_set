require_relative '../../../spec_helper'
require_relative 'shared/select'
require 'set'

ruby_version_is "2.6" do
  describe "CharacterSet::Pure#filter!" do
    it_behaves_like :sorted_set_1_select_bang, :filter!
  end
end
