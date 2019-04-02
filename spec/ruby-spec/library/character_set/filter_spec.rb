require_relative '../shared/select'

ruby_version_is "2.6" do
  describe "CharacterSet#filter!" do
    it_behaves_like :sorted_set_select_bang, CharacterSet, :filter!
  end
end
