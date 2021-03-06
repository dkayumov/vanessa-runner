# language: ru

Функционал: Проверка запуска и работы vanessa behavior
	Как Разработчик/Инженер по тестированию
	Я Хочу иметь возможность автоматической проверки запуска Ванессы
    Чтобы удостовериться в качестве подготовленной конфигурации

Контекст:
    Допустим я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    И Я копирую каталог "feature" из каталога "tests/fixtures" проекта в подкаталог "build" рабочего каталога
    И Я копирую файл "пауза.feature" из каталога "tests/fixtures/feature" проекта в подкаталог "./build/feature" рабочего каталога
    И Я копирую файл "vb-conf.json" из каталога "tests/fixtures/feature" проекта в подкаталог "./" рабочего каталога
    И Я копирую файл "env.json" из каталога "tests/fixtures/feature" проекта в подкаталог "./" рабочего каталога
    Допустим файл "env.json" существует
    И файл "./vb-conf.json" существует
    И файл "./build/feature/пауза.feature" существует
    И Я очищаю параметры команды "oscript" в контексте 

    
Сценарий: Запуск тестирования vanessa с паузой.
    Допустим Я очищаю параметры команды "oscript" в контексте 
    
    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os vanessa" для команды "oscript"
    И Я добавляю параметр "--ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--vanessasettings ./vb-conf.json" для команды "oscript"
    И Я добавляю параметр "--workspace ./build" для команды "oscript"
    Когда Я выполняю команду "oscript"
    # И Я сообщаю вывод команды "oscript"
    Тогда Вывод команды "oscript" содержит
    | Тестирование поведения завершено|

    И Код возврата команды "oscript" равен 0
    
