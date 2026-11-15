require 'spec_helper'

module MedusaRestClient
  describe Record do
    describe ".instantiate_record" do
      subject { Record.instantiate_record(data)}
      let(:data){ {"datum_type" => "Surface", "datum_attributes" => {"id" => 1, "name" => "hoge"}} }
      it {
        expect(subject).to be_an_instance_of(MedusaRestClient::Surface) 
      }
      context "with real data" do
        let(:data){ {"datum_type" => "Surface", "datum_attributes" => {"id" => 86,"name" => "surface MCS-202004","layers" => [[215,"s85-12C14N-int"],[214,"s85-12C12C-int"],[212,"s85-16O1H-int"],[211,"s85-Si28-int"],[239,"XRAY-Cs"],[238,"XRAY-Au"],[237,"XRAY-Ti"],[236,"XRAY-Si"],[235,"XRAY-S"],[234,"XRAY-P"],[233,"XRAY-O"],[232,"XRAY-Ni"],[231,"XRAY-Na"],[230,"XRAY-Mn"],[229,"XRAY-Mg"],[228,"XRAY-K"],[227,"XRAY-Fe"],[226,"XRAY-F"],[225,"XRAY-Cr"],[224,"XRAY-Cl"],[223,"XRAY-Ca"],[222,"XRAY-C"],[210,"XRAY-Al"],[209,"XRAY-BSE"],[187,"COMP"],[190,"COMPx1000"],[189,"TOPO"],[188,"OPT"]]}} }
        it {
          expect(subject).to be_an_instance_of(MedusaRestClient::Surface) 
        }  
      end
    end

    describe ".find" do
      subject{ Record.find(global_id, opts) } 
      let(:global_id){ '0000-001' }
      let(:opts){ {} }
      let(:body){
        #'{"id":354100,"datum_id":86,"datum_type":"Surface","datum_attributes":{"id":86,"name":"surface hoge"}}'
        File.open('./spec/fixtures/files/surface.json') do |file|
          file.read
        end
      }
      let(:obj){ FactoryBot.remote(:stone)}
      before do
        obj
        stub_request(:get, %r|/records/#{global_id}.json|).to_return(:body => body, :status => ["200", "Ok"])
      end

      it {
        subject 
        expect(WebMock).to have_requested(:get, %r|/records/#{global_id}.json|)
      }
    end

    describe ".download_casteml" do
      subject{ Record.download_casteml(global_id, opts) } 
      let(:filename){ global_id + ".pml"}
      let(:global_id){ '0000-001' }
      let(:opts){ {} }
      let(:obj){ FactoryBot.remote(:stone)}
      before do
        obj
        stub_request(:get, %r|/records/#{global_id}/casteml|).to_return(:body => nil, :status => ["200", "Ok"])
      end

      it {
        subject 
        expect(WebMock).to have_requested(:get, %r|/records/#{global_id}/casteml|)
      }

      after do
        File.unlink(filename)
      end
    end

    describe ".download" do
      subject{ Record.download_single(global_id, opts)}
      let(:filename){ global_id + ".json"}
      let(:global_id){ '0000-001' }
      let(:opts){ {} }
      before do
        #obj
        stub_request(:get, %r|/records/#{global_id}.json|).to_return(:body => FactoryBot.remote(:stone).to_json, :status => ["200", "Ok"])
#       Record.download_single(arg, opts)
      end

      it { 
        subject
        expect(WebMock).to have_requested(:get, %r|/records/#{global_id}.json|)
      # expect(File.exists?(filename)).to be_truthy
      }

      after do
        File.unlink(filename)
      end
    end

    describe ".box?" do

      context "with root path" do
        subject{ Record.box?(arg) }
        let(:arg){ '/' }
        let(:obj){ FactoryBot.remote(:box) }
        before do
          allow(Record).to receive(:find_by_id_or_path).and_return(obj)
        end
        it { 
          expect(Record).to receive(:find_by_id_or_path).with(arg).and_return(obj)
          subject 
        }

      end

      context "with box's global_id" do
        subject{ Record.box?(arg) }
        let(:arg){ '0000-001' }
        let(:obj){ FactoryBot.remote(:box) }
        it { 
          expect(Record).to receive(:find_by_id_or_path).with(arg).and_return(obj)
          subject 
        }

      end

      context "with box's path" do
        subject{ Record.box?(arg) }
        let(:arg){ '/A/B/C' }
        let(:obj){ FactoryBot.remote(:box) }
        before do
          allow(Record).to receive(:find_by_id_or_path).and_return(obj)
        end
        it { 
          expect(subject).to be_truthy
        }

      end

      context "with stone's global_id" do
        subject{ Record.box?(arg) }
        let(:arg){ '0000-001' }
        let(:obj){ FactoryBot.remote(:stone) }
        before do
          allow(Record).to receive(:find_by_id_or_path).with(arg).and_return(obj)
        end
        it { expect(subject).not_to be_truthy }

      end

    end

    describe "entries" do

      context "with global_id" do
        subject{ Record.entries(arg) }
        let(:arg){ '0000-001' }
        let(:obj){ FactoryBot.remote(:box) }
        before do
          allow(Record).to receive(:find_by_id_or_path).with(arg).and_return([])
        end

        it { expect(subject).to be_an_instance_of(Array) }

      end

    end


  end
end
