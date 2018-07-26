//
//  Structs.swift
//  NetSchool App
//
//  Created by Arthur on 16.07.2018.
//  Copyright © 2018 Руднев Кирилл. All rights reserved.
//
//////////////ИТОГОВЫЕ ОТМЕТКИ//////////////
struct TableMarks: Codable{
    let subject: String
    let period1: String
    let period2: String
    let period3: String
    let period4: String
    let year: String
    let exam: String
    let final: String
}
struct Marks: Codable {
    let table: [TableMarks]
}
//////////////СРЕДНИЙ БАЛЛ//////////////
struct TableOfMiddleMarks: Codable{
    let id: String
    let subject: String
    let mark_of_class: String
    let mark_of_student: String
}
struct MiddleMarks: Codable {
    let data: [TableOfMiddleMarks]
}
//////////////ДИНАМИКА СРЕДНЕГО БАЛЛА//////////////
struct DynamicMiddleMarksT: Codable{
    let data: [TableOfMiddleDynamicMarksT]
}
struct TableOfMiddleDynamicMarksT: Codable{
    let period: String
    let mark_of_class: String
    let mark_of_student: String
}
struct DynamicMiddleMarksSB: Codable{
    let data: [TableOfMiddleDynamicMarksSB]
}
struct TableOfMiddleDynamicMarksSB: Codable{
    let date: String
    let amount_of_student: String
    let mark_of_student: String
    let amount_of_class: String
    let mark_of_class: String
}

//////////////ОТЧЕТ ОБ УСПЕВАЕМОСТИ И ПОСЕЩАЕМОСТИ//////////////
struct SubjectsJourn: Codable{
    let name: String
    let marks: [String]
}
struct DaysJourn: Codable{
    let number: String
    let subjects: [SubjectsJourn]
}
struct MonthsJourn: Codable{
    let name: String
    let days: [DaysJourn]
}
struct AverageMarksJourn: Codable{
    let name: String
    let mark: String
}
struct TableJourn: Codable{
    let months: [MonthsJourn]
    let average_marks: [AverageMarksJourn]
}
struct BigJournal: Codable{
    let table: TableJourn
}
//////////////ОТЧЕТ ОБ УСПЕВАЕМОСТИ//////////////
struct TableWork: Codable{
    let type: String
    let theme: String
    let date: String
    let mark: String
}
struct Work: Codable{
    let work: [TableWork]
}
//////////////ОТЧЕТ О ДОСТУПЕ К КЛАССНОМУ ЖУРНАЛУ//////////////
struct JournalTable: Codable{
    let line: [JournalLine]
}
struct JournalLine: Codable{
    let class_number: String
    let lesson: String
    let date_time: String
    let user: String
    let info: String
    let period: String
    let type: String
}
//////////////ИНФОРМАЦИОННОЕ ПИСЬМО ДЛЯ РОДИТЕЛЕЙ//////////////
struct MarkInfo: Codable{
    let mark: String
    let count: String
}
struct TableForInfoForParents: Codable{
    let lesson: String
    let mark_info: [MarkInfo]
    let middle: String
    let final: String
}
struct InfoForParents: Codable{
    let data: [TableForInfoForParents]
}
