///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Запуск тестирования через фреймворк xUnitFor1C
// 
//	oscript src/main.os xunit C:\projects\xUnitFor1C\Tests\Smoke --pathxunit C:\projects\xUnitFor1C\xddTestRunner.epf 
//		--reportsxunit "ГенераторОтчетаJUnitXML{build/junit.xml};ГенераторОтчетаAllureXML{build/allure.xml}"
//
// TODO добавить фичи для проверки команды тестирования xUnitFor1C
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать v8runner
#Использовать asserts

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     Запуск тестирования через фреймворк xUnitFor1C
		|     ";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().Тестирование_xUnitFor1C, 
		ТекстОписания);

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "testsPath", "Путь к каталогу или к файлу с тестами");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--pathxunit", 
			"[env RUNNER_PATHXUNIT] путь к внешней обработке, по умолчанию ищу в tools/xunitfor1c/xddtestrunner.epf");

	ОписаниеОтчетов = "    --reportsxunit параметры формирования отчетов в формате вида:";
	ОписаниеОтчетов  = ОписаниеОтчетов  + 
		"      ФорматВыводаОтчета{Путь к файлу отчета};ФорматВыводаОтчета{Путь к файлу отчета}...";
	ОписаниеОтчетов  = ОписаниеОтчетов  + 
		"      Пример: ГенераторОтчетаJUnitXML{build/junit.xml};ГенераторОтчетаAllureXML{build/allure.xml}";
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--reportsxunit", ОписаниеОтчетов);
	
	ОписаниеСтатуса = "    --xddExitCodePath путь к текстовому файлу, обозначающему статус выполнению.";
	ОписаниеСтатуса  = ОписаниеСтатуса  + "    Внутри файла строка-значение 0 (тесты пройдены), 1 (тесты не пройдены)";
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--xddExitCodePath", ОписаниеСтатуса);
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--xddConfig", "Путь к конфигурационному файлу xUnitFor1c");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
			"--reportxunit", "путь к каталогу с отчетом jUnit (устарел)");

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

	ЗапускатьТолстыйКлиент = ОбщиеМетоды.УказанПараметрТолстыйКлиент(ПараметрыКоманды["--ordinaryapp"], Лог);

	ПараметрыОтчетовXUnit = ПараметрыОтчетовXUnit(ПараметрыКоманды["--reportsxunit"], 
			ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--reportxunit"]));

	ПроверитьСуществованиеРодительскихКаталоговДляПутей(ПараметрыОтчетовXUnit);

	ЗапуститьТестироватьЮнит(
		ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["testsPath"]), ПараметрыОтчетовXUnit,
		ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--xddExitCodePath"]),
		ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--pathxunit"]), ЗапускатьТолстыйКлиент,
		ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--xddConfig"]), 
		ПараметрыКоманды["--ibname"], ПараметрыКоманды["--db-user"], ПараметрыКоманды["--db-pwd"],
		ПараметрыКоманды["--v8version"]);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

// Выполняем запуск тестов для xunit 
//
// Параметры:
//	ПутьВходящихДанных - <Строка> - Может принимать путь к каталогу, так и к файлу для тестирования
//	ВыходнойКаталогОтчета - <Строка> - Путь к каталогу с отчетом, по умолчанию пустой 
//  ПутьФайлаСтатусаТестирования - <Строка> - путь к файлу статуса тестирования
//  СтрокаПодключения - <Строка> - Строка подключения к БД
//  Пользователь - <Строка> - Пользователь
//  Пароль - <Строка> - Пароль для пользователя
//  ПутьКИнструментам - <Строка> - путь к инструментам, по умолчанию ./tools/xUnitFor1C/xddTestRunner.epf
//  ТолстыйКлиент - <Булево> - признак запуска толстого клиента
//  ВерсияПлатформы - <Строка> - Версия платформы
//
Процедура ЗапуститьТестироватьЮнит(Знач ПутьВходящихДанных, Знач ФормируемыеОтчеты,
										Знач ПутьФайлаСтатусаТестирования,
										Знач ПутьКИнструментам = "", Знач ТолстыйКлиент = Ложь, 
										Знач ПутьККонфигурационномуФайлу,
										Знач СтрокаПодключения, Знач Пользователь = "", Знач Пароль = "", 
										Знач ВерсияПлатформы="") 

	Лог.Информация("Выполняю тесты %1", ПутьВходящихДанных);
	Ожидаем.Что(СтрокаПодключения, "Ожидаем, что строка подключения к ИБ задана, а это не так").Заполнено();

	Конфигуратор = Новый УправлениеКонфигуратором();
		
	КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
	Конфигуратор.КаталогСборки(КаталогВременнойИБ);
	
	Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	Если НЕ ПустаяСтрока(ВерсияПлатформы) Тогда
		Конфигуратор.ИспользоватьВерсиюПлатформы(ВерсияПлатформы);
	КонецЕсли;

	Если Не ТолстыйКлиент Тогда
		ТонкийКлиент1С = Конфигуратор.ПутьКТонкомуКлиенту1С(Конфигуратор.ПутьКПлатформе1С());
		Конфигуратор.ПутьКПлатформе1С(ТонкийКлиент1С);
	КонецЕсли;
	
	Если ПустаяСтрока(ПутьКИнструментам) Тогда
		ПутьКИнструментам = "./tools/xUnitFor1C/xddTestRunner.epf";
	КонецЕсли;
	
	КлючЗапуска = """xddRun ЗагрузчикКаталога """""+ПутьВходящихДанных+""""";";
	
	Для каждого ПараметрыОтчета Из ФормируемыеОтчеты Цикл
		КлючЗапуска = КлючЗапуска + "xddReport " + ПараметрыОтчета.Ключ + " """"" + ПараметрыОтчета.Значение + """"";";
	КонецЦикла;

	Если Не ПустаяСтрока(ПутьККонфигурационномуФайлу) Тогда
		КлючЗапуска = КлючЗапуска + 
				СтрШаблон(" xddConfig """"%1"""" ; ", ПутьККонфигурационномуФайлу);
	КонецЕсли;

	Если Не ПустаяСтрока(ПутьФайлаСтатусаТестирования) Тогда
		КлючЗапуска = КлючЗапуска + 
				СтрШаблон(" xddExitCodePath ГенерацияКодаВозврата """"%1"""" ; ", ПутьФайлаСтатусаТестирования);
	КонецЕсли;

	КлючЗапуска = КлючЗапуска + "xddShutdown;""";
	
	Лог.Отладка(КлючЗапуска);
	
	ДополнительныеКлючи = " /Execute""" + ПутьКИнструментам + """ /TESTMANAGER ";
	Попытка
		Конфигуратор.ЗапуститьВРежимеПредприятия(КлючЗапуска, Истина, ДополнительныеКлючи);
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			Лог.Информация(Текст);
		КонецЕсли;

		//Проверим итоговый результат работы поведения
		Если Не ПустаяСтрока(ПутьФайлаСтатусаТестирования) Тогда
			Результат = ОбщиеМетоды.ПрочитатьФайлИнформации(ПутьФайлаСтатусаТестирования);
			Если СокрЛП(Результат) <> "0" Тогда
				ВызватьИсключение "Результат работы команды не равен 0 "+ Результат;
			КонецЕсли;
		КонецЕсли;
	Исключение
		Лог.Ошибка(Конфигуратор.ВыводКоманды());
		Лог.Ошибка(ОписаниеОшибки());
		ВызватьИсключение "ЗапуститьТестироватьЮнит";
	КонецПопытки;

	Лог.Информация("Выполнение тестов завершено");
		
КонецПроцедуры // ЗапуститьТестироватьЮнит()

Функция ПараметрыОтчетовXUnit(Знач ПереданныеПараметрыОтчетов, Знач ВыходнойКаталогОтчета = "")
	НаборПараметров = Новый Структура;

	Если Не ПустаяСтрока(ВыходнойКаталогОтчета) Тогда
		НаборПараметров.Вставить("ГенераторОтчетаJUnitXML", ВыходнойКаталогОтчета);
	КонецЕсли;

	Если Не ПустаяСтрока(ПереданныеПараметрыОтчетов) Тогда
		ПараметрыВыводаОтчетов = СтрРазделить(ПереданныеПараметрыОтчетов, ";");
		Для каждого ПараметрВывода Из ПараметрыВыводаОтчетов Цикл
			ПозицияОткрывающейСкобки = СтрНайти(ПараметрВывода, "{");
			ПозицияЗакрывающейСкобки = СтрНайти(ПараметрВывода, "}");
			
			ФорматВывода = СокрЛП(Лев(ПараметрВывода, ПозицияОткрывающейСкобки - 1));
			
			ПереданныйПуть = СокрЛП(Сред(ПараметрВывода, ПозицияОткрывающейСкобки + 1, 
							ПозицияЗакрывающейСкобки - ПозицияОткрывающейСкобки - 1));

			ПутьВывода = ОбщиеМетоды.ПолныйПуть(ПереданныйПуть);

			НаборПараметров.Вставить(ФорматВывода, ПутьВывода);
		КонецЦикла;
	КонецЕсли;
	
	Возврат НаборПараметров;
КонецФункции // ПараметрыОтчетовXUnit()

Процедура ПроверитьСуществованиеРодительскихКаталоговДляПутей(Знач НаборПараметров)
	ЕстьОшибка = Ложь;
	СообщениеОшибки = "Генерация отчетов тестирования невозможна, т.к. не существуют каталоги:";
	Для каждого КлючЗначение Из НаборПараметров Цикл
		Путь = КлючЗначение.Значение;
		Файл = Новый Файл(Путь);
		ОбъектКаталог = Новый Файл(Файл.Путь);
		Если Не ОбъектКаталог.Существует() Тогда
			ЕстьОшибка = Истина;
			СообщениеОшибки = СтрШаблон("%1	%2", СообщениеОшибки, ОбъектКаталог.ПолноеИмя);
		КонецЕсли;
	КонецЦикла;
	Если ЕстьОшибка Тогда
		ВызватьИсключение СообщениеОшибки;
	КонецЕсли;
КонецПроцедуры