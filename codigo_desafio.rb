require 'rest-client'
require 'json'
require 'digest/sha1'
require 'faraday'

def obtem_dado_criptografado
	my_token = File.read('c:\projetos\desafio_codenation\my_token.txt')
	response = RestClient.get('https://api.codenation.dev/v1/challenge/dev-ps/generate-data', params: {token: my_token})

	escreve_arquivo = File.new('c:\projetos\desafio_codenation\answer.json', 'w')
	escreve_arquivo.write (response)
	escreve_arquivo.close
end


def descriptografa_desafio
	sequencia_caracteres = "abcdefghijklmnopqrstuvwxyz"
	json_criptografado = JSON.parse(File.read 'c:\projetos\desafio_codenation\answer.json')
	texto_criptografado =  (json_criptografado["cifrado"])
	texto_descriptografado = ''
	(texto_criptografado.each_char.map { |caracter| String(caracter)}).each do |lista_char|
		texto_descriptografado << " " if lista_char == " "
		texto_descriptografado << "." if lista_char == "."
		if sequencia_caracteres.index(lista_char) != nil
			texto_descriptografado << sequencia_caracteres[sequencia_caracteres.index(lista_char) - json_criptografado['numero_casas']]
		end
	end
	texto_descriptografado
end

def gravando_dados(texto_descriptografado)
	arquivo_json = JSON.parse(File.read 'c:\projetos\desafio_codenation\answer.json')
	sha1_descriptografado = Digest::SHA1.hexdigest texto_cifrado
	arquivo_json['decifrado'] = texto_descriptografado
	arquivo_json['resumo_criptografico'] = sha1_descriptografado
	escreve_arquivo = File.new 'c:\projetos\desafio_codenation\answer.json', 'w'
	escreve_arquivo.write arquivo_json
	escreve_arquivo.close
end	

def envia_arquivo
	my_token = File.read('c:\projetos\desafio_codenation\my_token.txt')
	#request = RestClient::Request.new(
	#	method: :post,
	#	:url => 'https://api.codenation.dev/v1/challenge/dev-ps/submit-solution',
	#	:params => {token: my_token},
	#	:multipart => true,
	#	:payload => {"answer": File.new("answer.json", "rb")}
	#)

	conn = Faraday.new('https://api.codenation.dev/v1/challenge/dev-ps/submit-solution') do |f|
		f.request:multipart
		f.request:url_encoded
		f.adapter:net_http
	end

	connection = Faraday.new(url: "https://api.codenation.dev/v1/challenge/dev-ps/submit-solution") do |faraday|
              faraday.request :multipart
              faraday.request :url_encoded
              faraday.adapter :net_http
            end
	request_data = { file: Faraday::UploadIO.new('answer.json', 'answer') }

	response = connection.post("?token=#{my_token}") do |request|
	#request = Ff::Api::RequestHeaders.set(request, self.api_options)
	request.headers['content-type'] = 'multipart/form-data; boundary=-----------RubyMultipartPost'
	request.body = request_data
	end


	#payload = {jsonPart:Faraday::UploadIO.new("answer.json", 'answer')}
	#payload = {Faraday::FilePart.new(File.open('answer.json'), 'file', File.basename('answer'))}

	#response = conn.post("https://api.codenation.dev/v1/challenge/dev-ps/submit-solution?token=#{my_token}", payload[:file_with_name])
	#response = request.execute
	puts response.body
end

#obtem_dado_criptografado
#gravando_dados(descriptografa_desafio)
envia_arquivo