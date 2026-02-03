# frozen_string_literal: true

require "spec_helper"
require "openssl"

RSpec.describe Rbinter do
  it "has a version number" do
    expect(Rbinter::VERSION).not_to be nil
  end

  describe Rbinter::Client do
    let(:client_id) { "fake_client_id" }
    let(:client_secret) { "fake_client_secret" }
    
    # Generate a dummy cert/key for testing
    let(:key) { OpenSSL::PKey::RSA.new(2048) }
    let(:cert) do
      c = OpenSSL::X509::Certificate.new
      c.version = 2
      c.serial = 1
      c.subject = OpenSSL::X509::Name.parse("/CN=Test")
      c.issuer = c.subject
      c.public_key = key.public_key
      c.not_before = Time.now
      c.not_after = Time.now + 3600
      c.sign(key, OpenSSL::Digest::SHA256.new)
      c
    end

    before do
      Rbinter.configure do |config|
        config.client_id = client_id
        config.client_secret = client_secret
        config.certificate = cert.to_pem
        config.private_key = key.to_pem
      end
    end

    let(:client) { Rbinter::Client.new }
    let(:base_url) { "https://cdpj.partners.bancointer.com.br" }

    describe "#create_boleto" do
      let(:boleto_params) do
        {
          seuNumero: "12345",
          valorNominal: 100.0,
          dataVencimento: "2024-12-31",
          pagador: {
            cpfCnpj: "12345678909",
            nome: "Diego Selzlein",
            email: "diego@example.com",
            telefone: "999999999",
            cep: "85800000",
            numero: "123",
            complemento: "Casa"
          }
        }
      end

      it "authenticates and creates a boleto" do
        # Mock Auth Request
        stub_request(:post, "#{base_url}/oauth/v2/token")
          .with(
            body: {
              "client_id" => client_id,
              "client_secret" => client_secret,
              "grant_type" => "client_credentials",
              "scope" => "boleto-cobranca.read boleto-cobranca.write"
            }
          )
          .to_return(
            status: 200,
            body: File.read("spec/fixtures/auth_token.json"),
            headers: { "Content-Type" => "application/json" }
          )

        # Mock Boleto Request
        stub_request(:post, "#{base_url}/cobranca/v2/boletos")
          .with(
            body: boleto_params.to_json,
            headers: {
              "Authorization" => "Bearer mocked_access_token_123",
              "Content-Type" => "application/json"
            }
          )
          .to_return(
            status: 200,
            body: File.read("spec/fixtures/create_boleto_response.json"),
            headers: { "Content-Type" => "application/json" }
          )

        response = client.create_boleto(boleto_params)

        expect(response["nossoNumero"]).to eq("005999929292")
        expect(response["status"]).to eq("AGUARDANDO_PAGAMENTO")
      end

      it "raises error on auth failure" do
        stub_request(:post, "#{base_url}/oauth/v2/token")
          .to_return(status: 401, body: "Unauthorized")

        expect { client.create_boleto(boleto_params) }.to raise_error(Rbinter::AuthenticationError)
      end
    end
  end
end
