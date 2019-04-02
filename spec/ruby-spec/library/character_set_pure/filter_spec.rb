require_relative '../shared/select'

ruby_version_is "2.6" do
  describe "CharacterSet::Pure#filter!" do
    it_behaves_like :sorted_set_select_bang, CharacterSet::Pure, :filter!
  end
end
