# Rbinter

Ruby wrapper for Banco Inter API (BolePix). Designed for EasyLemon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbinter', path: 'path/to/rbinter' # Until published
```

## Usage

Configure the gem with your Inter credentials (mTLS required):

```ruby
Rbinter.configure do |config|
  config.client_id = "YOUR_CLIENT_ID"
  config.client_secret = "YOUR_CLIENT_SECRET"
  config.certificate = "path/to/certificate.crt" # Or OpenSSL::X509::Certificate object
  config.private_key = "path/to/private.key"     # Or OpenSSL::PKey::RSA object
  config.environment = :production
end
```

### Create a Boleto (BolePix)

```ruby
client = Rbinter::Client.new

params = {
  seuNumero: "12345", # Unique ID in your system
  valorNominal: 100.0,
  dataVencimento: "2024-12-31",
  numDiasAgenda: 0, # Write it immediately
  pagador: {
    cpfCnpj: "12345678909",
    tipoPessoa: "FISICA",
    nome: "Cliente Exemplo",
    endereco: "Rua Teste",
    numero: "123",
    bairro: "Centro",
    cidade: "São Paulo",
    uf: "SP",
    cep: "01001000"
  }
}

response = client.create_boleto(params)
puts response["nossoNumero"]
puts response["linhaDigitavel"]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
