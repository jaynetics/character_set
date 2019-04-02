require_relative '../shared/include'

ruby_version_is "2.5" do
  describe "CharacterSet::Pure#===" do
    it_behaves_like :sorted_set_include, CharacterSet::Pure, :===
  end
end
