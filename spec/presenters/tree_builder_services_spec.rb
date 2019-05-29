describe TreeBuilderServices do
  subject { TreeBuilderServices.new("x", "y", {}, false) }

  let(:root_srv) { FactoryBot.create(:service, :display => true, :retired => false) }
  let!(:reti_srv) { FactoryBot.create(:service, :service => root_srv, :display => true, :retired => true) }

  before do
    login_as FactoryBot.create(:user)
    allow(User).to receive(:server_timezone).and_return("UTC")

    FactoryBot.create(:service, :service => root_srv, :display => true, :retired => false)
    FactoryBot.create(:service, :service => root_srv, :display => true, :retired => false)
  end

  describe '#x_get_tree_roots' do
    it 'returns the four root nodes' do
      root_nodes = subject.send(:x_get_tree_roots, false, {})

      expect(root_nodes).to match [
        a_hash_including(:id => 'asrv'),
        a_hash_including(:id => 'rsrv'),
        a_hash_including(:id => 'global'),
        a_hash_including(:id => 'my')
      ]
    end
  end

  describe '#x_get_tree_custom_kids' do
    it 'returns the root service node for active services' do
      root_services = subject.send(:x_get_tree_custom_kids, {:id => 'asrv'}, false, {})
      expect(root_services).to match [root_srv]
    end

    it 'returns the retired child service node for retired services' do
      root_services = subject.send(:x_get_tree_custom_kids, {:id => 'rsrv'}, false, {})
      expect(root_services).to match [reti_srv]
    end
  end

  describe '#x_get_tree_nested_services' do
    it 'returns the ancestry kids of a service' do
      child_nodes = subject.send(:x_get_tree_nested_services, root_srv, false)

      expect(child_nodes.length).to eq(2)
    end
  end
end
