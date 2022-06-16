require "date"

class MeteoserviceForecast
  # Массив строк для облачности, описанный на сайте метеосервиса
  CLOUDINESS = %w(Ясно Малооблачно Облачно Пасмурно).freeze
  # Массив строк для времени суток, описанный на сайте метеосервиса
  TOD = %w(ночь утро день вечер).freeze

  # В конструктор передаем хэш-набор параметров, которые будем выводить на экран
  def initialize(params)
    @date = params[:date]
    @time_of_day = params[:time_of_day]
    @min_temp = params[:min_temp]
    @max_temp = params[:max_temp]
    @max_wind = params[:max_wind]
    @clouds_index = params[:clouds_index]
  end

  # Метод класса, который считывает все параметры из xml и создает объект данного класса со считанными параметрами
  def self.from_xml(node)
    day = node.attributes['day']
    month = node.attributes['month']
    year = node.attributes['year']

    new(
      date: Date.parse("#{day}.#{month}.#{year}"),
      time_of_day: TOD[node.attributes['tod'].to_i],
      min_temp: node.elements['TEMPERATURE'].attributes['min'].to_i,
      max_temp: node.elements['TEMPERATURE'].attributes['max'].to_i,
      max_wind: node.elements['WIND'].attributes['max'],
      clouds_index: node.elements['PHENOMENA'].attributes['cloudiness'].to_i
    )
  end

  # Метод возвращает дату прогноза погоды - сегодня, завтра, или дата в числовом формате
  def date
    # Смотрим, что за дату мы получили с сайта
    return "Сегодня" if today?
    return "Завтра" if tomorrow?

    @date.strftime("%d.%m.%Y")
  end

  # Проверка, соответствует ли дата из xml текущему дню
  def today?
    @date == Date.today
  end

  # Проверка, соответствует ли дата из xml завтрашнему дню
  def tomorrow?
    @date == (Date.today + 1)
  end

  # Метод формирует строку диапазона температур со знаками + или -
  def temperature_range_string
    "#{sprintf('%+d', @min_temp)}..#{sprintf('%+d', @max_temp)}"
  end

  # Метод выводит информацию о погоде на экран
  def to_s
    puts
    result = "#{date}, #{@time_of_day}\n"
    result << "#{temperature_range_string}, ветер #{@max_wind} м/с, #{CLOUDINESS[@clouds_index]}"

    result
  end

  # Не нарушаем авторские права, метод выводит источник информации о погоде со ссылкой на сайт
  def self.copyright
    puts
    puts "Предоставлено Meteoservice.ru"
    puts "https://www.meteoservice.ru/"
  end
end
