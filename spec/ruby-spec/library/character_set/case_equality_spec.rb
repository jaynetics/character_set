require_relative '../shared/include'

ruby_version_is "2.5" do
  describe "CharacterSet#===" do
    it_behaves_like :sorted_set_include, CharacterSet, :===
  end
end
