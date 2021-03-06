///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать fs
#Использовать v8runner

Перем Лог;
Перем КорневойПутьПроекта;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     инициализируем пустую базу данных для выполнения необходимых тестов.
		|     указываем путь к исходниками с конфигурацией,
		|     указываем версию платформы, которую хотим использовать,
		|     и получаем по пути build\ib готовую базу для тестирования.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().ИнициализацияОкружения, ТекстОписания);
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src", "Путь к папке исходников");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--dt", "Путь к файлу с dt выгрузкой");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--dev", "Признак dev режима, создаем и загружаем автоматом структуру конфигурации");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--storage", "Признак обновления из хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-name", "Строка подключения к хранилище");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user", "Пользователь хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd", "Пароль");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-ver",	"Номер версии, по умолчанию берем последнюю");
	
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	ИнициализироватьБазуДанных(ПараметрыКоманды["--src"], ПараметрыКоманды["--dt"],
					ДанныеПодключения.ПутьБазы, ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль,, 
					ПараметрыКоманды["--v8version"], ПараметрыКоманды["--dev"], ПараметрыКоманды["--storage"], 
					ПараметрыКоманды["--storage-name"], ПараметрыКоманды["--storage-user"], ПараметрыКоманды["--storage-pwd"],
					ПараметрыКоманды["--storage-ver"], ПараметрыКоманды["--nocacheuse"], ДанныеПодключения.КодЯзыка);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

Процедура ИнициализироватьБазуДанных(Знач ПутьКSRC="", Знач ПутьКDT="", Знач СтрокаПодключения="", Знач Пользователь="", Знач Пароль="",
										Знач КлючРазрешенияЗапуска = "", Знач ВерсияПлатформы="", Знач РежимРазработчика = Ложь, 
										Знач РежимОбновленияХранилища = Ложь, Знач СтрокаПодключенияХранилище = "", Знач ПользовательХранилища="", Знач ПарольХранилища="",
										Знач ВерсияХранилища="", Знач НеДобавлятьВСписокБаз = Ложь, Знач КодЯзыка = "") 
	Перем БазуСоздавали;
	БазуСоздавали = Ложь;                                    
	ТекущаяПроцедура = "Запускаем инициализацию";

	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;
	
	Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());

	Если ПустаяСтрока(СтрокаПодключения) Тогда

		КаталогБазы = ОбъединитьПути(КорневойПутьПроекта, ?(РежимРазработчика = Истина, "./build/ibservice", "./build/ib"));
		СтрокаПодключения = "/F""" + КаталогБазы + """";
	КонецЕсли;

	Лог.Отладка("ИнициализироватьБазуДанных СтрокаПодключения:"+СтрокаПодключения);

	Если Лев(СтрокаПодключения,2)="/F" Тогда
		КаталогБазы = ОбщиеМетоды.УбратьКавычкиВокругПути(Сред(СтрокаПодключения,3, СтрДлина(СтрокаПодключения)-2));
		Лог.Отладка("Нашли каталог базы для удаления <%1> ", КаталогБазы);

		ФайлБазы = Новый Файл(КаталогБазы);
		Если ФайлБазы.Существует() Тогда 
			Лог.Отладка("Удаляем файл "+ФайлБазы.ПолноеИмя);
			УдалитьФайлы(ФайлБазы.ПолноеИмя, ПолучитьМаскуВсеФайлы());
		КонецЕсли;
		СоздатьКаталог(ФайлБазы.ПолноеИмя);
		МенеджерКонфигуратора.Инициализация(
			СтрокаПодключения, "", "",
			ВерсияПлатформы, КлючРазрешенияЗапуска,
			КодЯзыка
			);
		
		Конфигуратор = МенеджерКонфигуратора.УправлениеКонфигуратором();
		СоздатьФайловуюБазу(Конфигуратор, ФайлБазы.ПолноеИмя, ,);
		БазуСоздавали = Истина;
		Лог.Информация("Создали базу данных для " + СтрокаПодключения);
	КонецЕсли;

	//При первичной инициализации опускаем указание пользователя и пароля, т.к. их еще нет.
	МенеджерКонфигуратора.Инициализация(
		СтрокаПодключения, "", "",
		ВерсияПлатформы, КлючРазрешенияЗапуска,
		КодЯзыка
		);
	
	Конфигуратор = МенеджерКонфигуратора.УправлениеКонфигуратором();
	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ПолучитьИмяВременногоФайла("log"));
	Если Не ПустаяСтрока(ПутьКDT) Тогда
		ПутьКDT = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКDT)).ПолноеИмя;
		Лог.Информация("Загружаем dt "+ ПутьКDT);
		Если БазуСоздавали = Истина Тогда 
			Попытка 
				Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьКDT);
			Исключение
				Лог.Ошибка("Не удалось загрузить:"+ОписаниеОшибки());
			КонецПопытки;
		Иначе
			Попытка
				Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
				Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьКDT);    
			Исключение
				Лог.Ошибка("Не удалось загрузить:"+ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;

	//Базу создали, пользователей еще нет.
	Если БазуСоздавали И ПустаяСтрока(ПутьКDT) Тогда
		Конфигуратор.УстановитьКонтекст(СтрокаПодключения, "", "");
		Пользователь = "";
		Пароль = "";
	Иначе
		Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	КонецЕсли;
	
	Если Не ПустаяСтрока(ПутьКSRC) Тогда
		Лог.Информация("Запускаю загрузку конфигурации из исходников");

		ПутьКSRC = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКSRC)).ПолноеИмя;
		СписокФайлов = "";
		МенеджерКонфигуратора.СобратьИзИсходниковТекущуюКонфигурацию(ПутьКSRC, СписокФайлов, Ложь);

	КонецЕсли;

	Попытка

		Если РежимОбновленияХранилища = Истина Тогда
			Лог.Информация("Обновляем из хранилища");
			МенеджерКонфигуратора.ЗапуститьОбновлениеИзХранилища(
				СтрокаПодключенияХранилище, ПользовательХранилища, ПарольХранилища, 
				ВерсияХранилища);
		КонецЕсли;

		Если РежимРазработчика = Ложь Тогда 
			МенеджерКонфигуратора.ОбновитьКонфигурациюБазыДанных();
		КонецЕсли;
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();

	Если НЕ НеДобавлятьВСписокБаз Тогда

		ДопДанныеСпискаБаз = Новый Структура;
		ДопДанныеСпискаБаз.Вставить("RootPath", КорневойПутьПроекта);
		Попытка
			Если ЗначениеЗаполнено(ВерсияПлатформы) Тогда 
				ДопДанныеСпискаБаз.Вставить("Version", ВерсияПлатформы);
			КонецЕсли;
			МенеджерСпискаБаз.ДобавитьБазуВСписокБаз(СтрокаПодключения,
					Новый Файл(КорневойПутьПроекта).ИмяБезРасширения,
					ДопДанныеСпискаБаз);
		Исключение
			Лог.Ошибка("Добавление базы в список "+ОписаниеОшибки());
		КонецПопытки;

	КонецЕсли;

	Лог.Информация("Инициализация завершена");
	
КонецПроцедуры //ИнициализироватьБазуДанных

Процедура СоздатьФайловуюБазу(Конфигуратор, Знач КаталогБазы, Знач ПутьКШаблону="",
	Знач ИмяБазыВСписке="", Знач КодЯзыка = "") //Экспорт
	Лог.Отладка("Создаю файловую базу "+КаталогБазы);

	ФС.ОбеспечитьКаталог(КаталогБазы);
	УдалитьФайлы(КаталогБазы, "*.*");

	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("CREATEINFOBASE");
	ПараметрыЗапуска.Добавить("File="""+КаталогБазы+"""");
	ПараметрыЗапуска.Добавить("/Out""" +Конфигуратор.ФайлИнформации() + """");
	Если ЗначениеЗаполнено(КодЯзыка) Тогда
		ПараметрыЗапуска.Добавить("/L"+СокрЛП(КодЯзыка));
	КонецЕсли;
	
	Если ИмяБазыВСписке <> "" Тогда
		ПараметрыЗапуска.Добавить("/AddInList"""+ ИмяБазыВСписке + """");
	КонецЕсли;
	Если ПутьКШаблону<> "" Тогда
		ПараметрыЗапуска.Добавить("/UseTemplate"""+ ПутьКШаблону + """");
	КонецЕсли;

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из ПараметрыЗапуска Цикл
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		Если Лев(Параметр,2) <> "/P" и Лев(Параметр,25) <> "/ConfigurationRepositoryP" Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;
	КонецЦикла;

	Приложение = "";
	Приложение = Конфигуратор.ПутьКПлатформе1С();
	Если Найти(Приложение, " ") > 0 Тогда 
		Приложение = ОбщиеМетоды.ОбернутьПутьВКавычки(Приложение);
	КонецЕсли;
	Приложение = Приложение + " "+СтрокаЗапуска;
	Попытка
		ОбщиеМетоды.ЗапуститьПроцесс(Приложение);    
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	РезультатСообщение = ОбщиеМетоды.ПрочитатьФайлИнформации(Конфигуратор.ФайлИнформации());
	Если СтрНайти(РезультатСообщение, "успешно завершено") = 0 Тогда
		ВызватьИсключение "Результат работы не успешен: " + Символы.ПС + РезультатСообщение; 
	КонецЕсли;


КонецПроцедуры
