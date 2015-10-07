require 'spec_helper'

describe AlexaVerifier do
  it 'has a version number' do
    expect(AlexaVerifier::VERSION).not_to be nil
  end

  describe AlexaVerifier do
    let(:cert_url) {
      'https://s3.amazonaws.com/echo.api/echo-api-cert-2.pem'
    }

    let(:invalid_cert_url) {
      cert_url.gsub(AlexaVerifier::VALID_CERT_HOSTNAME, 'notamazon.com')
    }

    let(:request) {
      '{"version":"1.0","session":{"new":true,"sessionId":"amzn1.echo-api.session.1ff7dcb7-2f6c-45e8-aace-55bc06a86b62","application":{"applicationId":"amzn1.echo-sdk-ams.app.a1692ae2-2e84-429a-b09c-6e08de725a60"},"user":{"userId":"amzn1.account.AHRI3B4LBO4N3PE62H32YWRVVLOQ"}},"request":{"type":"LaunchRequest","requestId":"amzn1.echo-api.request.35b5db84-66d0-4191-94c6-8d0d5fd0d41e","timestamp":"2015-08-02T20:50:21Z"}}'
    }

    let(:signature) {
      'lHjllpj6iB7K0n+f+Nn5PlJdKvCwUvJjAWwFic4AM+9y06HBU6F3SxqRsoGtw4xZJ8SFmBI2+LFsWRTexbMFn2ZeyDlLBkHSx1H+Sk8zVNGLrUMRSrLdUgybOLTFy7l0lvSefNrX4+/1UImlENxctoJqHs43KJ7JDPjCKM5k5ilF8epKT06x3Lv2JkQXUjnrjtgcgBwG4nCTQbwyY0zxj50VoMQtgeraNtgsbO1TXyD9JrZPbIH2UBzQ44pnVkpRBzgh5eCuDe1oFiHD862MHZ7OQz3E5L01+AbZFdB/jX2jcW5y/z6yIWNYkI8vLi35heErBNfHRiOyijTKtxX0Yw=='
    }

    let(:cert) { <<-CERT.strip }
-----BEGIN CERTIFICATE-----
MIIE3zCCA8egAwIBAgIQbTfn5JS6BSKTPV2PvZyKazANBgkqhkiG9w0BAQsFADB+
MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAd
BgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxLzAtBgNVBAMTJlN5bWFudGVj
IENsYXNzIDMgU2VjdXJlIFNlcnZlciBDQSAtIEc0MB4XDTE1MDYxOTAwMDAwMFoX
DTE1MTAzMTIzNTk1OVowbTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0
b24xEDAOBgNVBAcMB1NlYXR0bGUxGTAXBgNVBAoMEEFtYXpvbi5jb20sIEluYy4x
HDAaBgNVBAMME2VjaG8tYXBpLmFtYXpvbi5jb20wggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQChyE4rRD7njQDYqoulNQ4E7jt8ba5JdbGcF/1iW/WiXu+/
oHxg/YRdGofxhu/wNgzh5ew9etyDOHc2eEgy4N7vRtpe4aQnAPHGDj5G8991+4pr
h3zis0i0LiDDgghocJaIi1CKYoY1xs3ZsyHC8wsZOPM9M3fkXLpFTQVWGWbKU7LJ
V/KkrAOYJb6vsCAGSnYwmxhOwYkXdAeUry4bJIDC/28lF25NKjchGn98izOa2RMk
n8QF52wbXOWKxUE3t/u64WUWSC7QGk6+uqbZLvgDKxnOSEAKdeFkO9FycZFwA2GN
hSsjbnRQTTxzDw1rZNs5pAYjunH4dc4gmrDwEu7XAgMBAAGjggFoMIIBZDAeBgNV
HREEFzAVghNlY2hvLWFwaS5hbWF6b24uY29tMAkGA1UdEwQCMAAwDgYDVR0PAQH/
BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBhBgNVHSAEWjBY
MFYGBmeBDAECAjBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3ltY2IuY29tL2Nw
czAlBggrBgEFBQcCAjAZGhdodHRwczovL2Quc3ltY2IuY29tL3JwYTAfBgNVHSME
GDAWgBRfYM9hkFXfhEMUimAqsvV69EMY7zArBgNVHR8EJDAiMCCgHqAchhpodHRw
Oi8vc3Muc3ltY2IuY29tL3NzLmNybDBXBggrBgEFBQcBAQRLMEkwHwYIKwYBBQUH
MAGGE2h0dHA6Ly9zcy5zeW1jZC5jb20wJgYIKwYBBQUHMAKGGmh0dHA6Ly9zcy5z
eW1jYi5jb20vc3MuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBi8jVmsy2kjvYfs3e1
RMQsz/G8yCmuJrtS/RcAJjuppyW1pDdDsumvVE1/I+aJczLTihBDfuKG9y7799Lc
az2ZEiN8y+4jnWbS0uqeZqa7Gl9ghK59ffTVsESUFPw2rxX5JBKt8z/abxt4qSsw
QVJ6M1p0DKZoS2RB2HZDj/6vRiuI5rP9jG42fQO1ZiFz1mmSYBCu89WOBmr3xCRm
ulL2T0ICzP/s4RcYtlLwhAY4AAe5anLRaGLLt3B7wRoQiVcQy+aVSbS79N7GN7MM
I6G5Sg8vsPrqfRtLMEuTJy/bMbmzd/F8IboFLbVTVv2fn7/HQhkiSgOZBLkdub1U
fHOg
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFODCCBCCgAwIBAgIQUT+5dDhwtzRAQY0wkwaZ/zANBgkqhkiG9w0BAQsFADCB
yjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJp
U2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxW
ZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0
aG9yaXR5IC0gRzUwHhcNMTMxMDMxMDAwMDAwWhcNMjMxMDMwMjM1OTU5WjB+MQsw
CQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xHzAdBgNV
BAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxLzAtBgNVBAMTJlN5bWFudGVjIENs
YXNzIDMgU2VjdXJlIFNlcnZlciBDQSAtIEc0MIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAstgFyhx0LbUXVjnFSlIJluhL2AzxaJ+aQihiw6UwU35VEYJb
A3oNL+F5BMm0lncZgQGUWfm893qZJ4Itt4PdWid/sgN6nFMl6UgfRk/InSn4vnlW
9vf92Tpo2otLgjNBEsPIPMzWlnqEIRoiBAMnF4scaGGTDw5RgDMdtLXO637QYqzu
s3sBdO9pNevK1T2p7peYyo2qRA4lmUoVlqTObQJUHypqJuIGOmNIrLRM0XWTUP8T
L9ba4cYY9Z/JJV3zADreJk20KQnNDz0jbxZKgRb78oMQw7jW2FUyPfG9D72MUpVK
Fpd6UiFjdS8W+cRmvvW1Cdj/JwDNRHxvSz+w9wIDAQABo4IBYzCCAV8wEgYDVR0T
AQH/BAgwBgEB/wIBADAwBgNVHR8EKTAnMCWgI6Ahhh9odHRwOi8vczEuc3ltY2Iu
Y29tL3BjYTMtZzUuY3JsMA4GA1UdDwEB/wQEAwIBBjAvBggrBgEFBQcBAQQjMCEw
HwYIKwYBBQUHMAGGE2h0dHA6Ly9zMi5zeW1jYi5jb20wawYDVR0gBGQwYjBgBgpg
hkgBhvhFAQc2MFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93d3cuc3ltYXV0aC5jb20v
Y3BzMCgGCCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3ltYXV0aC5jb20vcnBhMCkG
A1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0xLTUzNDAdBgNVHQ4E
FgQUX2DPYZBV34RDFIpgKrL1evRDGO8wHwYDVR0jBBgwFoAUf9Nlp8Ld7LvwMAnz
Qzn6Aq8zMTMwDQYJKoZIhvcNAQELBQADggEBAF6UVkndji1l9cE2UbYD49qecxny
H1mrWH5sJgUs+oHXXCMXIiw3k/eG7IXmsKP9H+IyqEVv4dn7ua/ScKAyQmW/hP4W
Ko8/xabWo5N9Q+l0IZE1KPRj6S7t9/Vcf0uatSDpCr3gRRAMFJSaXaXjS5HoJJtG
QGX0InLNmfiIEfXzf+YzguaoxX7+0AjiJVgIcWjmzaLmFN5OUiQt/eV5E1PnXi8t
TRttQBVSK/eHiXgSgW7ZTaoteNTCLD0IX4eRnh8OsN4wUmSGiaqdZpwOdgyA8nTY
Kvi4Os7X1g8RvmurFPW9QaAiY4nxug9vKWNmLT+sjHLF+8fk1A/yO0+MKcc=
-----END CERTIFICATE-----
    CERT

    let(:verifier) {
      AlexaVerifier.build do |b|
        b.verify_timestamps = false
      end
    }

    before(:each) do
      stub_request(:get, cert_url).to_return(status: 200, body: cert)
      stub_request(:get, invalid_cert_url).to_return(status: 200, body: cert)
    end

    describe '#verify!' do
      it 'returns true for a valid signature' do
        expect(verifier.verify!(cert_url, signature, request)).to be(true)
      end

      it 'complains when cert URL is not https' do
        expect {
          verifier.verify!(cert_url.gsub('https', 'http'), signature, request)
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'complains when the cert is not hosted by Amazon' do
        expect {
          verifier.verify!(invalid_cert_url, signature, request)
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'complains when the path is not valid' do
        expect {
          verifier.verify!(cert_url.gsub('/echo.api/', '/not.echo.api/'), signature, request)
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'fails validation when signature does not match' do
        expect {
          verifier.verify!(cert_url, signature, '{}')
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'fails validation when cert cannot be downloaded' do
        stub_request(:get, cert_url).to_return(status: 404, body: 'Not found')
        expect {
          verifier.verify!(cert_url, signature, request)
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'fails verification for timestamps when enabled' do
        verifier = AlexaVerifier.build do |b|
          b.verify_timestamps = true
        end

        expect {
          verifier.verify!(cert_url, signature, request)
        }.to raise_error(AlexaVerifier::VerificationError)
      end

      it 'passes validation when both signature/timestamp validations are disabled' do
        verifier = AlexaVerifier.build do |b|
          b.verify_timestamps = false
          b.verify_signatures = false
        end

        expect(verifier.verify!(invalid_cert_url, 'invalid_signature', 'invalid_request')).to be(true)
      end
    end
  end
end
