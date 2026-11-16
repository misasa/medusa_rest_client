require 'spec_helper'

module MedusaRestClient
  describe BoxRoot do
    before do
      setup
      WebMock.reset!
    end

    describe "new" do
      it { expect(BoxRoot.new).to be_an_instance_of(BoxRoot) }
      it { expect(BoxRoot.new).to be_a_kind_of(Box) }     
    end

    describe ".entries" do
      subject { BoxRoot.entries }
      #let(:box_root){ BoxRoot.new }

      it { 
        expect(BoxRoot).to receive(:boxes).and_return([])
        expect(BoxRoot).to receive(:specimens).and_return([])       
        subject
      }

    end
    
    describe "parent" do

      let(:box){ BoxRoot.new }
      before do
        box
      end
      it { expect(box.parent).to be_nil}


    end

    describe "box" do

      let(:box){ BoxRoot.new}
      before do
        box
      end
      it { expect(box.box).to be_nil}

    end

  end
end