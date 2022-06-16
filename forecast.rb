# подключаем либы для работы с сетью и XML
require "net/http"
require "uri"
require "rexml/document"
require_relative "lib/meteoservice_forecast"

TOWNS_INDEXES = {
  "Воложин" => 25346,
  "Минск" => 34,
  "Брест" => 2895,
  "Гродно" => 2896,
  "Витебск" => 2897,
  "Могилев" => 35,
  "Гомель" => 2900
}

choices = TOWNS_INDEXES.keys
choice = -1

until choice >= 1 && choice <= choices.size # пока юзер не выбрал правильно
  puts "Погоду для какого города Вы хотите узнать?"
  # выводим заново массив возможных городов
  choices.each.with_index(1) do |town, index|
    puts "#{index}. #{town}"
  end
  choice = gets.chomp.to_i
end

# Индекс города, выбранного пользователем
town_index = TOWNS_INDEXES[choices[choice - 1]]

# Сформируем адрес запроса с сайта метеосервиса
uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/#{town_index}.xml")

# Отправляем HTTP-запрос по указанному адресу и записываем ответ в переменную
# response.
response = Net::HTTP.get_response(uri)

# Из тела ответа (body) формируем XML документ с помощью REXML парсера
doc = REXML::Document.new(response.body)

# Получаем имя города из XML, город лежит в ноде REPORT/TOWN
city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

puts
puts city_name

# Перебираем в цикле все элементы FORECAST
# каждый такой элемент хранит информацию о погоде для определенного времени суток (утро, день, вечер, ночь)
doc.root.elements.each('REPORT/TOWN/FORECAST') do |element|
  # Считываем данные из xml, создает объект класса MeteoserviceForecast
  # и выводим информацию об объекте, в котором уже сформированы строки с параметрами для вывода на экран
  puts MeteoserviceForecast.from_xml(element)
end

puts MeteoserviceForecast.copyright

