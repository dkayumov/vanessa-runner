///////////////////////////////////////////////////////////////////
//
// Рекомендованная структура модуля точки входа приложения
//
///////////////////////////////////////////////////////////////////

#Использовать cmdline
#Использовать logos
#Использовать 1commands

#Использовать "."

///////////////////////////////////////////////////////////////////

Перем Лог;

///////////////////////////////////////////////////////////////////

Процедура Инициализация()
	Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ПараметрыСистемы.ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

	КаталогЛогов = ПолучитьКаталогЛогов();
	ИнициализироватьЛоги(КаталогЛогов);

	МенеджерКомандПриложения.РегистраторКоманд(ПараметрыСистемы);
	
КонецПроцедуры

Функция ПолучитьКаталогЛогов()
	Перем КаталогЛогов;
	Попытка 
		 КаталогЛогов = СокрЛП(ОбщиеМетоды.ЗапуститьПроцесс("git rev-parse --show-toplevel"));
	Исключение
		КаталогЛогов = ВременныеФайлы.НовоеИмяФайла(ПараметрыСистемы.ИмяПродукта());
		СоздатьКаталог(КаталогЛогов);
	КонецПопытки;  
	Возврат КаталогЛогов;
КонецФункции

Процедура ИнициализироватьЛоги(Знач КаталогЛогов)
	
	РежимРаботы = ПолучитьПеременнуюСреды("RUNNER_ENV");
	Если ЗначениеЗаполнено(РежимРаботы) И НРег(РежимРаботы) = "debug" Тогда
		УровеньЛога = УровниЛога.Отладка;
		Лог.УстановитьУровень(УровеньЛога);

		Аппендер = Новый ВыводЛогаВФайл();
		ИмяВременногоФайла = ОбщиеМетоды.ПолучитьИмяВременногоФайлаВКаталоге(КаталогЛогов, СтрШаблон("%1.log", ПараметрыСистемы.ИмяПродукта()));
		Аппендер.ОткрытьФайл(ИмяВременногоФайла);
		Лог.ДобавитьСпособВывода(Аппендер);

	КонецЕсли;

	Лог.УстановитьРаскладку(ЭтотОбъект);
	
КонецПроцедуры

Функция СоответствиеПеременныхОкруженияПараметрамКоманд()	
	СоответствиеПеременных = Новый Соответствие();

	СоответствиеПеременных.Вставить("RUNNER_IBCONNECTION", "--ibconnection");
	СоответствиеПеременных.Вставить("RUNNER_IBNAME", "--ibname");
	СоответствиеПеременных.Вставить("RUNNER_DBUSER", "--db-user");
	СоответствиеПеременных.Вставить("RUNNER_DBPWD", "--db-pwd");
	СоответствиеПеременных.Вставить("RUNNER_v8version", "--v8version");
	СоответствиеПеременных.Вставить("RUNNER_uccode", "--uccode");
	СоответствиеПеременных.Вставить("RUNNER_command", "--command");
	СоответствиеПеременных.Вставить("RUNNER_execute", "--execute");
	СоответствиеПеременных.Вставить("RUNNER_storage-user", "--storage-user");
	СоответствиеПеременных.Вставить("RUNNER_storage-pwd", "--storage-pwd");
	СоответствиеПеременных.Вставить("RUNNER_storage-ver", "--storage-ver");
	СоответствиеПеременных.Вставить("RUNNER_storage-name", "--storage-name");
	СоответствиеПеременных.Вставить("RUNNER_ROOT", "--root");
	СоответствиеПеременных.Вставить("RUNNER_WORKSPACE", "--workspace");
	СоответствиеПеременных.Вставить("RUNNER_PATHVANESSA", "--pathvanessa");
	СоответствиеПеременных.Вставить("RUNNER_PATHXUNIT", "--pathxunit");
	СоответствиеПеременных.Вставить("RUNNER_VANESSASETTINGS", "--vanessasettings");
	СоответствиеПеременных.Вставить("RUNNER_NOCACHEUSE", "--nocacheuse");
	СоответствиеПеременных.Вставить("RUNNER_LOCALE", "--locale");
	СоответствиеПеременных.Вставить("RUNNER_LANGUAGE", "--language");
	
	Возврат Новый ФиксированноеСоответствие(СоответствиеПеременных);
КонецФункции

Функция УстановитьКаталогТекущегоПроекта(Знач Путь)
	Рез = "";
	Если ПустаяСтрока(Путь) Тогда
		Попытка
			Команда = Новый Команда;
			Команда.УстановитьСтрокуЗапуска("git rev-parse --show-toplevel");
			Команда.УстановитьПравильныйКодВозврата(0);
			Команда.Исполнить();
			Рез = СокрЛП(Команда.ПолучитьВывод());
			// Рез = СокрЛП(ЗапуститьПроцесс("git rev-parse --show-toplevel"));
		Исключение
		КонецПопытки;
	Иначе
		Рез = Путь;
	КонецЕсли;
	Возврат Рез;
КонецФункции // УстановитьКаталогТекущегоПроекта()

Функция ПолучитьПарсерКоманднойСтроки()
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();

	МенеджерКомандПриложения.ЗарегистрироватьКоманды(Парсер);
	
	Возврат Парсер;
	
КонецФункции // ПолучитьПарсерКоманднойСтроки

Функция ВыполнениеКоманды()
	
	ПараметрыЗапуска = РазобратьАргументыКоманднойСтроки();
	
	Если ПараметрыЗапуска = Неопределено ИЛИ ПараметрыЗапуска.Количество() = 0 Тогда
		
		ВывестиВерсию();
		Лог.Ошибка("Некорректные аргументы командной строки");
		МенеджерКомандПриложения.ПоказатьСправкуПоКомандам();
		Возврат МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения;
		
	КонецЕсли;
	
	Команда = "";
	ЗначенияПараметров = Неопределено;
	
	Если ТипЗнч(ПараметрыЗапуска) = Тип("Структура") Тогда
		
		// это команда
		Команда				= ПараметрыЗапуска.Команда;
		ЗначенияПараметров	= ПараметрыЗапуска.ЗначенияПараметров;

		Лог.Отладка("Выполняю команду продукта %1", Команда);
		
	ИначеЕсли ЗначениеЗаполнено(ПараметрыСистемы.ИмяКомандыПоУмолчанию()) Тогда
		
		// это команда по-умолчанию
		Команда				= ПараметрыСистемы.ИмяКомандыПоУмолчанию();
		ЗначенияПараметров	= ПараметрыЗапуска;

		Лог.Отладка("Выполняю команду продукта по умолчанию %1", Команда);
		
	Иначе
		
		ВызватьИсключение "Некорректно настроено имя команды по-умолчанию.";
		
	КонецЕсли;
	
	Если Команда <> ПараметрыСистемы.ИмяКомандыВерсия() Тогда
		ВывестиВерсию();
	КонецЕсли;

	ДополнитьЗначенияПараметров(Команда, ЗначенияПараметров);
	
	Возврат МенеджерКомандПриложения.ВыполнитьКоманду(Команда, ЗначенияПараметров);
	
КонецФункции // ВыполнениеКоманды()

Процедура ДополнитьЗначенияПараметров(Знач Команда, ЗначенияПараметров)
	
	ТекущийКаталогПроекта = УстановитьКаталогТекущегоПроекта(ЗначенияПараметров["--root"]);

	ПараметрыСистемы.КорневойПутьПроекта = ТекущийКаталогПроекта;

	ПутьКФайлуНастроекПоУмолчанию = ОбъединитьПути(ТекущийКаталогПроекта, ОбщиеМетоды.ИмяФайлаНастроек());

	НастройкиИзФайла = ОбщиеМетоды.ПрочитатьНастройкиФайлJSON(ТекущийКаталогПроекта, 
			ЗначенияПараметров["--settings"], ПутьКФайлуНастроекПоУмолчанию);

	ЗначенияПараметровНизкийПриоритет = Новый Соответствие;

	Если НастройкиИзФайла.Количество() > 0 Тогда 
		ОбщиеМетоды.ДополнитьАргументыИзФайлаНастроек(Команда, ЗначенияПараметровНизкийПриоритет, НастройкиИзФайла);
	КонецЕсли;
	
	СоответствиеПеременных = СоответствиеПеременныхОкруженияПараметрамКоманд();

	ОбщиеМетоды.ЗаполнитьЗначенияИзПеременныхОкружения(ЗначенияПараметровНизкийПриоритет, СоответствиеПеременных);

	ОбщиеМетоды.ДополнитьСоответствиеСУчетомПриоритета(ЗначенияПараметров, ЗначенияПараметровНизкийПриоритет);

	// на случай переопределения этой настройки повторная установка
	УстановитьКаталогТекущегоПроекта(ЗначенияПараметров["--root"]);

	ДобавитьДанныеПодключения(ЗначенияПараметров);
	
КонецПроцедуры

Процедура ДобавитьДанныеПодключения(ЗначенияПараметров)
	СтрокаПодключения = ЗначенияПараметров["--ibconnection"];
	ИмяБазы = ЗначенияПараметров["--ibname"];

	Если ЗначениеЗаполнено(СтрокаПодключения) И ЗначениеЗаполнено(ИмяБазы) Тогда
		ВызватьИсключение СтрШаблон("Запрещено одновременно задавать ключи %1 и %2", "--ibconnection", "--ibname");
	КонецЕсли;

	Если ЗначениеЗаполнено(СтрокаПодключения) Тогда
		ЗначенияПараметров.Вставить("--ibname", СтрокаПодключения);
	Иначе
		ЗначенияПараметров.Вставить("--ibconnection", ИмяБазы);

		Если ЗначениеЗаполнено(ИмяБазы) Тогда
			Лог.Предупреждение("------------------------------------------------------------------");
			Лог.Предупреждение("Параметр --ibname устарел. Используйте --ibconnection вместо него!");
			Лог.Предупреждение("------------------------------------------------------------------");
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ЗначенияПараметров["--ibname"]) Тогда
		ЗначенияПараметров.Вставить("--ibname", 
						ОбщиеМетоды.ПереопределитьПолныйПутьВСтрокеПодключения(ЗначенияПараметров["--ibname"]));

		ИсходнаяСтрокаПодключения = ЗначенияПараметров["--ibname"];

		НоваяСтрокаПодключения = МенеджерСпискаБаз.ПолучитьСтрокуПодключенияСКэшем(
						ИсходнаяСтрокаПодключения, 
						ЗначенияПараметров["--nocacheuse"]);

		ЗначенияПараметров.Вставить("--ibname", НоваяСтрокаПодключения);
		ЗначенияПараметров.Вставить("--ibconnection", ИсходнаяСтрокаПодключения);

	КонецЕсли;


	ЗначенияПараметров.Вставить("ДанныеПодключения", ДанныеПодключения(ЗначенияПараметров));
КонецПроцедуры

Функция ДанныеПодключения(ЗначенияПараметров)
	СтруктураПодключения = Новый Структура;
	
	// здесь может находиться и имя базы и строка подключения
	СтруктураПодключения.Вставить("СтрокаПодключения", ЗначенияПараметров["--ibname"]);
	
	// здесь может находиться только строка подключения в виде пути к базе
	СтруктураПодключения.Вставить("ПутьБазы", ЗначенияПараметров["--ibconnection"]); 
	
	СтруктураПодключения.Вставить("Пользователь", ЗначенияПараметров["--db-user"]);
	СтруктураПодключения.Вставить("Пароль", ЗначенияПараметров["--db-pwd"]);
	СтруктураПодключения.Вставить("КодЯзыка", ЗначенияПараметров["--language"]);
	СтруктураПодключения.Вставить("КодЯзыкаСеанса", ЗначенияПараметров["--locale"]);

	Рез = Новый Структура;
	Для каждого КлючЗначение Из СтруктураПодключения Цикл
		Значение = КлючЗначение.Значение;
		Если Значение = Неопределено Тогда
			Значение = "";
		КонецЕсли;
		Рез.Вставить(КлючЗначение.Ключ, Значение);
	КонецЦикла;

	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции // ДанныеПодключения(ЗначенияПараметров)

Процедура ВывестиВерсию()
	
	Сообщить(СтрШаблон("%1 v%2", ПараметрыСистемы.ИмяПродукта(), ПараметрыСистемы.ВерсияПродукта()));
	
КонецПроцедуры // ВывестиВерсию()

Функция РазобратьАргументыКоманднойСтроки()
	
	Парсер = ПолучитьПарсерКоманднойСтроки();
	Возврат Парсер.Разобрать(АргументыКоманднойСтроки);
	
КонецФункции // РазобратьАргументыКоманднойСтроки

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

///////////////////////////////////////////////////////////////////

Инициализация();

Попытка
		
	КодВозврата = ВыполнениеКоманды();
	
	ВременныеФайлы.Удалить();
	
	ЗавершитьРаботу(КодВозврата);
		
Исключение
		
	Лог.КритичнаяОшибка(ОписаниеОшибки());
	ВременныеФайлы.Удалить();

	ЗавершитьРаботу(МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения);
		
КонецПопытки;
