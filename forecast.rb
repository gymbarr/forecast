# подключаем либы для работы с сетью и XML
require "net/http"
require "uri"
require "rexml/document"
require_relative "lib/meteoservice_forecast"

# Сформируем адрес запроса с сайта метеосервиса
#
# 25346 - Воложин
uri = URI.parse('https://xml.meteoservice.ru/export/gismeteo/point/25346.xml')

# Отправляем HTTP-запрос по указанному адресу и записываем ответ в переменную
# response.
response = Net::HTTP.get_response(uri)

# Из тела ответа (body) формируем XML документ с помощью REXML парсера
doc = REXML::Document.new(response.body)

# Получаем имя города из XML, город лежит в ноде REPORT/TOWN
city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

puts city_name

# Перебираем в цикле все элементы FORECAST
# каждый такой элемент хранит информацию о погоде для определенного времени суток (утро, день, вечер, ночь)
doc.root.elements.each('REPORT/TOWN/FORECAST') do |element|
  # Считываем данные из xml и создает объект класса MeteoserviceForecast
  forecast = MeteoserviceForecast.from_xml(element)

  # Выводим информацию об объекте, в котором уже сформированы строки с параметрами для вывода на экран
  puts forecast
end

puts MeteoserviceForecast.copyright


